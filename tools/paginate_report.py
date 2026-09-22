"""Fill the page numbers in the contents, tables and figures lists.

The lists at the front of each deliverable are written by hand in markdown, so
they cannot know what page anything lands on. This script measures it: build the
Word document, export it to PDF through Word itself, find the page each heading
and each caption starts on, and write those numbers back into the markdown.

Writing the numbers in can move the text slightly, so the measurement is
repeated until two consecutive rounds agree.

Usage:

    python tools/paginate_report.py                  # update markdown, docx and PDF
    python tools/paginate_report.py --check          # fail if the numbers are stale
    python tools/paginate_report.py report           # one deliverable only

Requires Microsoft Word, pdfplumber, and the same toolchain as
`tools/build_docx_deliverables.py`.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

import pdfplumber

REPO_ROOT = Path(__file__).resolve().parents[1]

MAX_ROUNDS = 4

CONTENTS_HEADER = "| Section | Title | Page |"
SUBJECT_HEADER = "| Section | Subject | Page |"
TABLES_HEADER = "| Table | Title | Section | Page |"
FIGURES_HEADER = "| Figure | Title | Section | Page |"


@dataclass(frozen=True)
class Target:
    key: str
    source: str
    docx: str
    headers: tuple[str, ...]

    @property
    def source_path(self) -> Path:
        return REPO_ROOT / self.source

    @property
    def docx_path(self) -> Path:
        return REPO_ROOT / self.docx

    @property
    def pdf_path(self) -> Path:
        return self.docx_path.with_suffix(".pdf")


TARGETS = (
    Target(
        key="report",
        source="docs/paper/conferencecheck-paper.md",
        docx="docs/deliverables/ConferenceCheck Final Report.docx",
        headers=(CONTENTS_HEADER, TABLES_HEADER, FIGURES_HEADER),
    ),
    Target(
        key="validation",
        source="docs/validation_report.md",
        docx="docs/deliverables/ConferenceCheck Validation Report.docx",
        headers=(SUBJECT_HEADER,),
    ),
)

# `wdExportFormatPDF`. Fields are updated first so the footer page numbers and
# anything else field-driven are current in the exported file.
EXPORT = """
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
try {{
  $doc = $word.Documents.Open('{docx}', $false, $true)
  $doc.Fields.Update() | Out-Null
  $doc.ExportAsFixedFormat('{pdf}', 17)
  $doc.Close(0)
}} finally {{
  $word.Quit()
}}
"""


def strip_emphasis(cell: str) -> str:
    return cell.replace("**", "").replace("`", "").strip()


def heading_key(section: str, title: str) -> str:
    """The text the heading is expected to start with in the rendered document."""
    if not section:
        return title
    if section.startswith("Appendix ") or len(section) == 1 and section.isalpha():
        # The appendix rows carry the full heading in their title cell already.
        return title
    return f"{section}. {title}" if "." not in section else f"{section} {title}"


def page_index(pages: list[str], key: str, exact: bool) -> int | None:
    """First page carrying `key` as a line of its own, or as a line prefix.

    Headings are matched exactly. A prefix match would find the contents list
    first, because a row there renders as the heading text followed by its page
    number. Captions are matched on the prefix, since the caption continues past
    the label.

    A heading too long for one line is set over two or three, so each line is
    also tested joined to the lines that follow it.
    """
    wanted = re.sub(r"\s+", " ", key).casefold()
    for number, text in enumerate(pages, start=1):
        lines = text.split("\n")
        for position, line in enumerate(lines):
            for span in (1, 2, 3):
                joined = " ".join(lines[position:position + span])
                candidate = re.sub(r"\s+", " ", joined).strip().casefold()
                if candidate == wanted or (not exact and candidate.startswith(wanted)):
                    return number
    return None


def read_pages(pdf_path: Path) -> list[str]:
    with pdfplumber.open(str(pdf_path)) as document:
        return [page.extract_text() or "" for page in document.pages]


def export_pdf(target: Target, pdf_path: Path) -> None:
    script = EXPORT.format(
        docx=str(target.docx_path).replace("'", "''"),
        pdf=str(pdf_path).replace("'", "''"),
    )
    subprocess.run(
        ["powershell", "-NoProfile", "-NonInteractive", "-Command", script],
        check=True,
        capture_output=True,
    )


def build_docx(target: Target) -> None:
    subprocess.run(
        [sys.executable, str(REPO_ROOT / "tools/build_docx_deliverables.py"), target.key],
        check=True,
        cwd=REPO_ROOT,
        capture_output=True,
    )


def table_rows(lines: list[str], header: str) -> tuple[int, int]:
    """Index range of the data rows under `header`, separator row excluded."""
    start = lines.index(header) + 2
    end = start
    while end < len(lines) and lines[end].startswith("|"):
        end += 1
    return start, end


def collect_keys(target: Target, lines: list[str]) -> list[tuple[int, str, bool]]:
    """Row index, lookup key and match mode for every entry in the lists."""
    keys: list[tuple[int, str, bool]] = []

    for header in target.headers:
        start, end = table_rows(lines, header)
        if header in (CONTENTS_HEADER, SUBJECT_HEADER):
            for index in range(start, end):
                cells = [cell.strip() for cell in lines[index].strip("|").split("|")]
                keys.append((index, heading_key(strip_emphasis(cells[0]), strip_emphasis(cells[1])), True))
            continue
        label = "Table" if header == TABLES_HEADER else "Figure"
        for index in range(start, end):
            cells = [cell.strip() for cell in lines[index].strip("|").split("|")]
            keys.append((index, f"{label} {strip_emphasis(cells[0])}.", False))

    return keys


def write_pages(lines: list[str], resolved: dict[int, str]) -> list[str]:
    updated = list(lines)
    for index, page in resolved.items():
        cells = [cell.strip() for cell in updated[index].strip("|").split("|")]
        cells[-1] = page
        updated[index] = "| " + " | ".join(cells) + " |"
    return updated


def measure(target: Target, pdf_path: Path, lines: list[str]) -> tuple[dict[int, str], list[str]]:
    pages = read_pages(pdf_path)
    resolved: dict[int, str] = {}
    missing: list[str] = []
    for index, key, exact in collect_keys(target, lines):
        found = page_index(pages, key, exact)
        if found is None:
            missing.append(key)
            resolved[index] = ""
        else:
            resolved[index] = str(found)
    return resolved, missing


def paginate(target: Target, check: bool) -> int:
    text = target.source_path.read_text(encoding="utf-8")
    for header in target.headers:
        if header not in text:
            raise SystemExit(f"list header not found in {target.source}: {header}")

    original = text
    with tempfile.TemporaryDirectory() as workdir:
        probe = Path(workdir) / "probe.pdf"
        for round_number in range(1, MAX_ROUNDS + 1):
            build_docx(target)
            export_pdf(target, probe)
            lines = target.source_path.read_text(encoding="utf-8").split("\n")
            resolved, missing = measure(target, probe, lines)
            if missing:
                raise SystemExit("could not locate in the rendered document:\n  " + "\n  ".join(missing))

            updated = write_pages(lines, resolved)
            if updated == lines:
                print(f"{target.key}: page numbers stable after {round_number} round(s)")
                break
            if check:
                target.source_path.write_text(original, encoding="utf-8")
                print(f"{target.key}: page numbers are stale; run tools/paginate_report.py")
                return 1
            target.source_path.write_text("\n".join(updated), encoding="utf-8")
        else:
            raise SystemExit(f"{target.key}: page numbers did not settle in {MAX_ROUNDS} rounds")

    build_docx(target)
    export_pdf(target, target.pdf_path)
    print(f"wrote {target.pdf_path.relative_to(REPO_ROOT)}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("keys", nargs="*", choices=[item.key for item in TARGETS] + [[]])
    parser.add_argument("--check", action="store_true", help="report staleness instead of writing")
    arguments = parser.parse_args()

    selected = arguments.keys or [item.key for item in TARGETS]
    status = 0
    for target in TARGETS:
        if target.key in selected:
            status |= paginate(target, arguments.check)
    return status


if __name__ == "__main__":
    sys.exit(main())
