"""Rebuild the Word deliverables from their markdown sources.

Each deliverable is rendered from its markdown by pandoc, then given the
formatting Word needs and pandoc does not supply: visible table rules, column
widths sized to their contents, captions held with what they label, and a page
number in the footer.

Usage:

    python tools/build_docx_deliverables.py              # rebuild all
    python tools/build_docx_deliverables.py report       # rebuild one

Requires pandoc on PATH and python-docx.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path

from docx import Document
from docx.shared import Inches, Pt, Twips
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn as _qn
from docx.oxml import OxmlElement

REPO_ROOT = Path(__file__).resolve().parents[1]

CAPTION_PATTERN = re.compile(r"^(Table|Figure) [A-D]?\d+\.")

AUTHOR = "Ndashi Bwalya Chisanga"

# Tall phone screenshots are capped at this height so a figure and its caption
# stay on one page. Large enough that the on-screen text a figure exists to show
# is still readable in print, which at 4 inches it was not.
MAX_FIGURE_HEIGHT = Inches(6.5)

# A heading no longer than this is given room to sit on a single line; a value
# no longer than this is never allowed to break across lines.
HEADING_ON_ONE_LINE = 16
UNBREAKABLE_TOKEN = 16

# Width of the widest character in the body face, in twips, plus the left and
# right cell margins. Sizing to the widest character rather than the average is
# what stops a word being broken through the middle.
CHAR_TWIPS = 130
CELL_PADDING = 260
BODY_POINTS = 11
MIN_TABLE_POINTS = 8


@dataclass(frozen=True)
class Deliverable:
    key: str
    source: str
    target: str
    title: str

    @property
    def source_path(self) -> Path:
        return REPO_ROOT / self.source

    @property
    def target_path(self) -> Path:
        return REPO_ROOT / self.target


DELIVERABLES = (
    Deliverable(
        key="report",
        source="docs/paper/conferencecheck-paper.md",
        target="docs/deliverables/ConferenceCheck Final Report.docx",
        title=(
            "Fraud-Resistant Meal Voucher Redemption and Real-Time Operational Analytics "
            "for Conference Management: Design and Evaluation of ConferenceCheck Mobile"
        ),
    ),
    Deliverable(
        key="validation",
        source="docs/validation_report.md",
        target="docs/deliverables/ConferenceCheck Validation Report.docx",
        title="ConferenceCheck Mobile: Analytics, Meals and Notifications: Validation Report",
    ),
)


def render(deliverable: Deliverable, workdir: Path) -> Path:
    rendered = workdir / "rendered.docx"
    subprocess.run(
        [
            "pandoc",
            str(deliverable.source_path),
            "--from=gfm",
            "--to=docx",
            # The document's own title line becomes the Word title, so the
            # numbered sections written as `##` render as Heading 1.
            "--shift-heading-level-by=-1",
            # Figures are written relative to the markdown file so they resolve
            # on GitHub; pandoc runs from the repository root, so it needs the
            # source's own directory on the resource path to find them.
            f"--resource-path={deliverable.source_path.parent}",
            f"--output={rendered}",
        ],
        check=True,
        cwd=REPO_ROOT,
    )
    return rendered


# Eighths of a point. The outer rules are the weight a printed table needs to
# read as a table; the row separators are deliberately light so a long appendix
# table stays legible without turning into a grid.
# Siblings that must follow `tblBorders` inside `tblPr`.
BORDERS_PRECEDE = ("shd", "tblLayout", "tblCellMar", "tblLook", "tblCaption", "tblDescription")

_OUTER_RULE = "8"
_ROW_RULE = "2"
_ROW_RULE_COLOUR = "BFBFBF"


def _border(tag: str, size: str, colour: str) -> OxmlElement:
    element = OxmlElement(f"w:{tag}")
    element.set(_qn("w:val"), "single")
    element.set(_qn("w:sz"), size)
    element.set(_qn("w:space"), "0")
    element.set(_qn("w:color"), colour)
    return element


def rule_tables(path: Path) -> None:
    """Give the `Table` style a full grid.

    Pandoc's table style carries a header underline of width zero, so every
    table renders as spaced text with no lines at all. Replace it with a ruled
    box and a line between every row and every column, so a table reads as a
    table rather than as columns of text that happen to line up.
    """
    document = Document(str(path))
    style = document.styles["Table"].element

    table_properties = style.find(_qn("w:tblPr"))
    if table_properties is None:
        table_properties = OxmlElement("w:tblPr")
        style.insert(0, table_properties)

    for existing in table_properties.findall(_qn("w:tblBorders")):
        table_properties.remove(existing)

    borders = OxmlElement("w:tblBorders")
    borders.append(_border("top", _OUTER_RULE, "auto"))
    borders.append(_border("left", _OUTER_RULE, "auto"))
    borders.append(_border("bottom", _OUTER_RULE, "auto"))
    borders.append(_border("right", _OUTER_RULE, "auto"))
    borders.append(_border("insideH", _ROW_RULE, _ROW_RULE_COLOUR))
    borders.append(_border("insideV", _ROW_RULE, _ROW_RULE_COLOUR))
    # `tblBorders` has a fixed position among its siblings. Word tolerates it
    # out of order when reading, then silently drops it the next time the
    # document is saved, so the rules would disappear as soon as anyone opened
    # the file.
    anchor = next((child for child in table_properties
                   if child.tag.split("}")[1] in BORDERS_PRECEDE), None)
    if anchor is None:
        table_properties.append(borders)
    else:
        anchor.addprevious(borders)

    for conditional in style.findall(_qn("w:tblStylePr")):
        if conditional.get(_qn("w:type")) != "firstRow":
            continue
        cell_properties = conditional.find(_qn("w:tcPr"))
        if cell_properties is None:
            continue
        for existing in cell_properties.findall(_qn("w:tcBorders")):
            cell_properties.remove(existing)
        cell_borders = OxmlElement("w:tcBorders")
        cell_borders.append(_border("bottom", _OUTER_RULE, "auto"))
        cell_properties.insert(0, cell_borders)

    document.save(str(path))


def fit_images(path: Path) -> int:
    """Cap figure height so a screenshot does not consume a whole page.

    A phone screenshot is far taller than it is wide, and pandoc sizes an image
    to the column width, which for a 1080x2400 capture would run well past the
    bottom of the page. Each image is scaled to a maximum height instead, with
    its aspect ratio preserved, so the figure sits with its caption.
    """
    document = Document(str(path))
    changed = 0
    for shape in document.inline_shapes:
        if shape.height <= MAX_FIGURE_HEIGHT:
            continue
        ratio = shape.width / shape.height
        shape.height = MAX_FIGURE_HEIGHT
        shape.width = int(MAX_FIGURE_HEIGHT * ratio)
        changed += 1
    if changed:
        document.save(str(path))
    return changed


def repeat_header_rows(path: Path) -> int:
    """Repeat each table's header row when the table runs over a page break."""
    document = Document(str(path))
    changed = 0
    for table in document.tables:
        if not table.rows:
            continue
        properties = table.rows[0]._tr.get_or_add_trPr()
        if properties.find(_qn("w:tblHeader")) is not None:
            continue
        header = OxmlElement("w:tblHeader")
        header.set(_qn("w:val"), "true")
        properties.append(header)
        changed += 1
    document.save(str(path))
    return changed


def align_captions(path: Path) -> int:
    """Left-align table and figure captions and keep them with what they label.

    A caption is held on one page and kept with the paragraph that follows, so
    it can neither split across a page break nor be left stranded at the foot of
    a page while its table starts on the next one.
    """
    document = Document(str(path))
    changed = 0
    for paragraph in document.paragraphs:
        text = paragraph.text.lstrip()
        if not CAPTION_PATTERN.match(text):
            continue
        paragraph.alignment = WD_ALIGN_PARAGRAPH.LEFT
        paragraph.paragraph_format.keep_together = True
        paragraph.paragraph_format.keep_with_next = True
        changed += 1
    document.save(str(path))
    return changed


def fit_tables(path: Path) -> int:
    """Size table columns to their contents.

    Pandoc gives every column the same width, so a table holding one long text
    column and several short ones squeezes the short headings until they wrap
    mid-word. Width is shared out in proportion to the longest cell in each
    column, with a floor wide enough for the longest unbreakable word in the
    heading so a heading never wraps on its own account.
    """
    document = Document(str(path))
    section = document.sections[0]
    page_width = section.page_width if section.page_width is not None else 7772400
    left_margin = section.left_margin if section.left_margin is not None else 914400
    right_margin = section.right_margin if section.right_margin is not None else 914400
    available = int((page_width - left_margin - right_margin) / 635)

    adjusted = 0
    for table in document.tables:
        columns = len(table.columns)
        if not columns:
            continue

        longest = [0] * columns
        floors = [0] * columns
        for row_number, row in enumerate(table.rows):
            for index, cell in enumerate(row.cells[:columns]):
                text = cell.text.strip()
                longest[index] = max(longest[index], len(text))
                if not text:
                    continue
                if row_number == 0:
                    # Keep a short heading on one line rather than breaking it
                    # between its words.
                    floors[index] = max(floors[index], len(text) if len(text) <= HEADING_ON_ONE_LINE else 0)
                # A value such as 210.5 ms must not be split; a long identifier
                # such as `session_duplicate_rejection` may wrap.
                tokens = [len(part) for part in text.split() if len(part) <= UNBREAKABLE_TOKEN]
                floors[index] = max(floors[index], max(tokens, default=0))

        floor_widths = [max(word, 4) * CHAR_TWIPS + CELL_PADDING for word in floors]
        demanded = sum(floor_widths)

        shrink = 1.0
        if demanded > available:
            # The columns cannot all have the room their longest word needs.
            # Give each the same share of what it asked for and set the table in
            # smaller type, so the same words still fit on a line rather than
            # being broken through the middle.
            shrink = available / demanded
            floor_widths = [int(width * shrink) for width in floor_widths]

        weights = [max(value, 1) for value in longest]
        total = sum(weights)
        widths = [max(int(available * weight / total), floor) for weight, floor in zip(weights, floor_widths)]

        overflow = sum(widths) - available
        while overflow > 0:
            slack = [(widths[i] - floor_widths[i], i) for i in range(columns)]
            room, index = max(slack)
            if room <= 0:
                break
            take = min(room, overflow)
            widths[index] -= take
            overflow -= take

        size = Pt(max(MIN_TABLE_POINTS, BODY_POINTS * shrink)) if shrink < 1 else None
        for row in table.rows:
            for cell in row.cells:
                for paragraph in cell.paragraphs:
                    paragraph.alignment = WD_ALIGN_PARAGRAPH.LEFT
                    if size is not None:
                        for run in paragraph.runs:
                            run.font.size = size

        grid = table._tbl.find(_qn("w:tblGrid"))
        if grid is None or len(grid) != columns:
            continue
        for column, width in zip(grid, widths):
            column.set(_qn("w:w"), str(width))
        for row in table.rows:
            for cell, width in zip(row.cells[:columns], widths):
                cell.width = Twips(width)
        adjusted += 1

    document.save(str(path))
    return adjusted


def add_page_numbers(path: Path) -> None:
    """Put a centred `PAGE` field in the footer of every section."""
    document = Document(str(path))
    namespace = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

    for section in document.sections:
        section.footer.is_linked_to_previous = False
        footer = section.footer
        paragraph = footer.paragraphs[0] if footer.paragraphs else footer.add_paragraph()
        for run in list(paragraph.runs):
            run._element.getparent().remove(run._element)
        paragraph.alignment = 1  # centred

        run = paragraph.add_run()
        for tag, attributes, text in (
            ("fldChar", {"fldCharType": "begin"}, None),
            ("instrText", {"space": "preserve"}, " PAGE "),
            ("fldChar", {"fldCharType": "end"}, None),
        ):
            element = OxmlElement(f"w:{tag}")
            for key, value in attributes.items():
                prefix = "xml" if key == "space" else "w"
                uri = "http://www.w3.org/XML/1998/namespace" if key == "space" else namespace
                element.set(f"{{{uri}}}{key}", value)
            if text is not None:
                element.text = text
            run._element.append(element)

    document.save(str(path))


def set_properties(path: Path, title: str) -> None:
    """Name the author on the document itself.

    Pandoc leaves the core properties empty, so Word shows the account that last
    opened the file as its author. Setting them here means the author travels
    with the document rather than with whoever's machine rendered it.
    """
    document = Document(str(path))
    core = document.core_properties
    core.author = AUTHOR
    core.last_modified_by = AUTHOR
    core.title = title
    document.save(str(path))


def build(deliverable: Deliverable) -> None:
    deliverable.target_path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as raw:
        rendered = render(deliverable, Path(raw))
        deliverable.target_path.write_bytes(rendered.read_bytes())
    rule_tables(deliverable.target_path)
    fitted = fit_tables(deliverable.target_path)
    headers = repeat_header_rows(deliverable.target_path)
    figures = fit_images(deliverable.target_path)
    captions = align_captions(deliverable.target_path)
    add_page_numbers(deliverable.target_path)
    set_properties(deliverable.target_path, deliverable.title)
    size = deliverable.target_path.stat().st_size
    print(f"wrote {deliverable.target} ({size:,} bytes, {fitted} table(s) fitted, "
          f"{headers} header row(s) set to repeat, {figures} figure(s) fitted, "
          f"{captions} caption(s) aligned)")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "keys",
        nargs="*",
        choices=[item.key for item in DELIVERABLES] + [[]],
        help="deliverables to rebuild; default is all of them",
    )
    args = parser.parse_args()
    selected = args.keys or [item.key for item in DELIVERABLES]
    for deliverable in DELIVERABLES:
        if deliverable.key in selected:
            build(deliverable)
    return 0


if __name__ == "__main__":
    sys.exit(main())
