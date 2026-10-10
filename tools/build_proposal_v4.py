"""Make proposal v4 from v3 with the three changes the supervisor asked for on
submission 118: an evaluation objective, the two corrected literature claims,
and a dated account of remaining work. Nothing else in v3 is changed.

Usage:  python tools/build_proposal_v4.py
Writes: docs/Project_proposal_Ndashi_v4.docx (export the PDF from Word)
"""

import copy
from pathlib import Path

from docx import Document
from docx.shared import Pt

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'docs' / 'Project_proposal_Ndashi_v3.docx'
TARGET = ROOT / 'docs' / 'Project_proposal_Ndashi_v4.docx'

doc = Document(SOURCE)


def find(start):
    matches = [p for p in doc.paragraphs if p.text.strip().startswith(start)]
    assert len(matches) == 1, (start, len(matches))
    return matches[0]


def set_text(paragraph, text):
    runs = paragraph.runs
    runs[0].text = text
    for run in runs[1:]:
        run.text = ''


def replace_in(paragraph, old, new):
    assert old in paragraph.text, old[:60]
    set_text(paragraph, paragraph.text.replace(old, new))


def insert_after(paragraph, text, like=None):
    like = like or paragraph
    new = copy.deepcopy(like._p)
    paragraph._p.addnext(new)
    from docx.text.paragraph import Paragraph
    added = Paragraph(new, paragraph._parent)
    set_text(added, text)
    return added


# cover: the version and the date it was resubmitted
date = find('28/03/26')
insert_after(date, '28/03/26 (version 4, resubmitted 10/10/26)')
set_text(date, '')
date._p.getparent().remove(date._p)

# ask 1: an evaluation objective
docs_objective = find('6. To produce comprehensive technical documentation')
set_text(docs_objective, '7. To produce comprehensive technical documentation and a publication-ready paper.')
evaluation = copy.deepcopy(docs_objective._p)
docs_objective._p.addprevious(evaluation)
from docx.text.paragraph import Paragraph
set_text(Paragraph(evaluation, docs_objective._parent),
         '6. To evaluate redemption correctness, scan latency, dashboard freshness, notification '
         'delivery and export correctness against the Table 3 targets and a manual baseline.')

# ask 2: the two literature claims, in every place they appear
intro = find('Quick Response (QR) codes provide a mature')
replace_in(intro,
           'and QR-based attendance systems have been shown to reduce both processing time and '
           'recording error relative to manual registers [3].',
           'and QR-based attendance has been proposed as a way to reclaim the lecture time that '
           'manual registers consume [3].')
replace_in(intro,
           'provide reliable, low-latency delivery of updates to mobile devices at no marginal cost [6],',
           'exist to send messages to mobile devices reliably [6], within the delivery guarantees '
           'Section 2 sets out,')

masalha = find('Masalha and Hirzallah [3] evaluated')
replace_in(masalha,
           'Masalha and Hirzallah [3] evaluated a QR-based attendance system in a university setting and '
           'found substantial reductions in per-person processing time and in recording errors relative '
           'to manual registers, but also identified the central weakness of naive QR attendance:',
           'Masalha and Hirzallah [3] propose a QR-based attendance system for a university setting, '
           'motivated by the time manual registers consume. Their paper describes and analyses the '
           'design but reports no experiment and no measured comparison against a manual register, so '
           'it is not evidence of how much time or error such a system saves. Its analysis does '
           'identify the central weakness of naive QR attendance:')

firebase = find("For attendee communication, Google's Firebase Cloud Messaging documentation [6]")
replace_in(firebase,
           "Google's Firebase Cloud Messaging documentation [6] describes a store-and-forward push "
           'architecture with per-device registration tokens; delivery is best-effort,',
           "Google's Firebase Cloud Messaging documentation describes a push architecture in which each "
           'app instance has its own registration token [16], and states that a message accepted for '
           'delivery may be delayed or not delivered [17]; delivery is therefore best-effort,')

baseline = find('Baseline comparison. The voucher module')
replace_in(baseline,
           'are measured for both conditions, following the comparative approach used in prior QR '
           'attendance evaluations [3].',
           'are measured for both conditions. No prior QR attendance study reports such a measured '
           'comparison; [3] proposes one design without measuring it, so this comparison is this '
           "project's own.")

flutter_ref = find('[15] Google, "Flutter documentation,"')
r17 = insert_after(flutter_ref, '[17] Google, "Understanding message delivery," Firebase Documentation, 2025. '
                   '[Online]. Available: https://firebase.google.com/docs/cloud-messaging/understand-delivery')
r16 = insert_after(flutter_ref, '[16] Google, "FCM architectural overview," Firebase Documentation, 2025. '
                   '[Online]. Available: https://firebase.google.com/docs/cloud-messaging/fcm-architecture')

# ask 3: a dated account of remaining work, as Section 10
references = find('10. References')
set_text(references, '11. References')


def heading_before(anchor, text, level_like):
    new = copy.deepcopy(level_like._p)
    anchor._p.addprevious(new)
    para = Paragraph(new, anchor._parent)
    set_text(para, text)
    return para


body_like = find('Several limitations of the proposed design are acknowledged.')


def body_before(anchor, text):
    new = copy.deepcopy(body_like._p)
    anchor._p.addprevious(new)
    para = Paragraph(new, anchor._parent)
    set_text(para, text)
    return para


def table_before(anchor, rows, widths=None):
    table = doc.add_table(rows=len(rows), cols=len(rows[0]))
    table.style = doc.tables[0].style
    for r, row in enumerate(rows):
        for c, value in enumerate(row):
            cell = table.cell(r, c)
            cell.text = value
            for run in cell.paragraphs[0].runs:
                run.font.size = Pt(9)
                run.font.bold = r == 0
    # the proposal's own tables carry their borders directly, not from a style
    from docx.oxml import OxmlElement
    from docx.oxml.ns import qn
    borders = OxmlElement('w:tblBorders')
    for edge in ('top', 'left', 'bottom', 'right', 'insideH', 'insideV'):
        line = OxmlElement(f'w:{edge}')
        line.set(qn('w:val'), 'single')
        line.set(qn('w:sz'), '4')
        line.set(qn('w:color'), '000000')
        borders.append(line)
    table._tbl.tblPr.append(borders)
    anchor._p.addprevious(table._tbl)
    return table


heading_before(references, '10. Remaining Work', references)
body_before(references,
            'This account is dated from the resubmission on 10 October 2026, not from the cover date. '
            'It answers the comments on submissions 116 (final report), 117 (validation document) and '
            '118 (this proposal). The milestone tags in the repository were created in September and mark '
            'representative commits, so each completed item below links its own commit and evidence; '
            'docs/remaining_work.md in the repository gives the commit and test for every item.')
body_before(references, 'Table 6. Work completed since the comments, with its evidence.')
table_before(references, [
    ('Date', 'Item', 'Evidence'),
    ('07/10/26', 'Authorisation: attendees open only their own vouchers, reports are organiser only, '
                 'notifications are readable only by their recipients, and four related fixes',
     'Negative tests expecting 403 in tests/Feature/ConferenceApiTest.php; commits a6596e8 to 85b529c'),
    ('09/10/26', 'Redemption record protected from edits and cascading deletes; 409 instead of 500 when '
                 'the unique constraint refuses a scan; locks on session and check-in scans; chunked '
                 'exports; Firebase demo mode never recorded as delivery',
     'Feature tests; commits da5a91d to ab206f4'),
    ('09-10/10/26', 'Offline replay keeps recoverable failures and no longer overwrites a scan queued '
                    'during replay', 'mobile/test/scan_replay_test.dart and scan_replay_restart_test.dart; '
                                     'commits 3387288, 6ebc456, 33d3c89'),
    ('10/10/26', 'Concurrent redemption on PostgreSQL behind five server processes, with the row lock '
                 'and unique constraint each removed as controls',
     'tools/concurrency-results.json; commit e9aab32'),
    ('10/10/26', 'All four CSV exports checked against direct SQL on rows and totals; evaluation rerun',
     'tools/evaluation-results.json; commit 907f237'),
    ('10/10/26', 'Dashboard freshness measured by injecting check-ins and timing their appearance',
     'tools/freshness-results.json; commit 094e5e1'),
    ('10/10/26', 'Report and validation document corrected and rebuilt, with a per-criterion status table',
     'docs/deliverables/; commits 19c14e1 to b4617f8'),
])
body_before(references, 'Table 7. Work still to be done.')
table_before(references, [
    ('Item', 'Due'),
    ('Upload this proposal (v4) to the Project Proposal slot', '10/10/26'),
    ('Upload the corrected final report and validation document, with the final commit tagged '
     'final-resubmission', '10/10/26'),
    ('Push delivery measured across a fleet of devices, a timed capacity alert, and the manual '
     'baseline: not possible within the project and stated as limitations in the final report', 'Not scheduled'),
])

doc.save(TARGET)
print('wrote', TARGET)
