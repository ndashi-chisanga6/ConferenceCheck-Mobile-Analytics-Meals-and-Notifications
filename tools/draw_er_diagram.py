"""Draw the entity-relationship diagram for the report from the schema.

Entities, keys and relationships follow database/migrations/
2026_07_06_000001_create_conferencecheck_tables.php. Laravel's own framework
tables (cache, jobs, sessions, passkeys, tokens) are left out.

Usage:  python tools/draw_er_diagram.py
Writes: docs/er-diagram.png
"""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "er-diagram.png"

NAVY = "#192D4B"
TINT = "#EEF2F7"
KEY = "#0B7A6F"

# name: (x, y, [attributes]); laid out on a 4 x 4 grid with "events" in the
# middle so that every related pair of tables sits side by side.
COLS = (0.5, 4.9, 9.3, 13.7)
ROWS = (7.3, 4.8, 2.3, -0.2)
ENTITIES = {
    "device_tokens": (COLS[0], ROWS[0], ["PK id", "FK user_id", "token (unique)"]),
    "event_users": (COLS[1], ROWS[0], ["PK id", "FK event_id", "FK user_id", "unique (event, user)"]),
    "notifications": (COLS[2], ROWS[0], ["PK id", "FK event_id", "FK sent_by", "target_type, status"]),
    "notification_recipients": (COLS[3], ROWS[0], ["PK id", "FK notification_id", "FK user_id, attendee_id", "delivery status"]),
    "users": (COLS[0], ROWS[1], ["PK id", "email (unique)", "role"]),
    "events": (COLS[1], ROWS[1], ["PK id", "FK created_by", "name, venue, dates"]),
    "meal_categories": (COLS[2], ROWS[1], ["PK id", "FK event_id", "window, status"]),
    "event_sessions": (COLS[0], ROWS[2], ["PK id", "FK event_id", "capacity"]),
    "attendees": (COLS[1], ROWS[2], ["PK id", "FK event_id, user_id", "ticket_code (unique)", "qr_token (unique)"]),
    "meal_vouchers": (COLS[2], ROWS[2], ["PK id", "FK attendee_id", "FK meal_category_id", "qr_token (unique)", "unique (attendee, category)"]),
    "meal_redemptions": (COLS[3], ROWS[2], ["PK id", "FK meal_voucher_id (unique)", "redeemed_by, device_id", "deletes restricted"]),
    "session_attendance": (COLS[0], ROWS[3], ["PK id", "FK session_id", "FK attendee_id", "unique (session, attendee)"]),
    "check_ins": (COLS[1], ROWS[3], ["PK id", "FK event_id, attendee_id", "unique (event, attendee)"]),
}

W, H = 3.2, 2.05

# (from, to, label[, far end]): "1" side first; the far end is "N" unless given
RELATIONS = [
    ("users", "events", "creates"),
    ("events", "event_users", "has staff"),
    ("users", "event_users", ""),
    ("events", "attendees", "registers"),
    ("attendees", "check_ins", "checks in"),
    ("events", "meal_categories", "offers"),
    ("attendees", "meal_vouchers", "holds"),
    ("meal_categories", "meal_vouchers", "issues"),
    ("meal_vouchers", "meal_redemptions", "redeemed", "0..1"),
    ("events", "event_sessions", "runs"),
    ("event_sessions", "session_attendance", "records"),
    ("attendees", "session_attendance", "attends"),
    ("events", "notifications", "sends"),
    ("notifications", "notification_recipients", "delivered to"),
    ("users", "device_tokens", "registers"),
]


def centre(name):
    x, y, _ = ENTITIES[name]
    return x + W / 2, y + H / 2


def edge_point(name, towards):
    """Where the line from this box's centre towards `towards` leaves the box."""
    cx, cy = centre(name)
    tx, ty = towards
    dx, dy = tx - cx, ty - cy
    if dx == 0 and dy == 0:
        return cx, cy
    sx = (W / 2) / abs(dx) if dx else float("inf")
    sy = (H / 2) / abs(dy) if dy else float("inf")
    s = min(sx, sy)
    return cx + dx * s, cy + dy * s


fig, ax = plt.subplots(figsize=(13.0, 8.6), dpi=170)
ax.set_xlim(0.2, 17.2)
ax.set_ylim(-0.4, 9.5)
ax.axis("off")

for a, b, label, *far in RELATIONS:
    pa = edge_point(a, centre(b))
    pb = edge_point(b, centre(a))
    ax.annotate("", xy=pb, xytext=pa, arrowprops=dict(arrowstyle="-", color="#8A96A8", lw=1.3))
    # cardinality marks near each end
    for (px, py), (qx, qy), mark in ((pa, pb, "1"), (pb, pa, far[0] if far else "N")):
        ax.text(px + (qx - px) * 0.12, py + (qy - py) * 0.12 + 0.12, mark, fontsize=10.5,
                color=KEY, fontweight="bold", ha="center", va="center", family="Times New Roman")
    if label:
        mx, my = (pa[0] + pb[0]) / 2, (pa[1] + pb[1]) / 2
        if abs(pa[1] - pb[1]) < 1e-6:
            my -= 0.24  # below a horizontal line, clear of the cardinality marks
        ax.text(mx, my, label, fontsize=9.5, color="#4A5566", ha="center", va="center",
                family="Times New Roman", style="italic",
                bbox=dict(boxstyle="round,pad=0.15", fc="white", ec="none"))

for name, (x, y, attrs) in ENTITIES.items():
    ax.add_patch(FancyBboxPatch((x, y), W, H, boxstyle="round,pad=0.02,rounding_size=0.08",
                                fc=TINT, ec=NAVY, lw=1.4))
    ax.add_patch(FancyBboxPatch((x, y + H - 0.42), W, 0.42, boxstyle="round,pad=0.02,rounding_size=0.08",
                                fc=NAVY, ec=NAVY, lw=1.4))
    ax.text(x + W / 2, y + H - 0.21, name, color="white", fontsize=12.5, fontweight="bold",
            ha="center", va="center", family="Times New Roman")
    for i, attr in enumerate(attrs):
        colour = KEY if attr.startswith(("PK", "FK")) or "unique" in attr else "#232323"
        ax.text(x + 0.1, y + H - 0.68 - i * 0.3, attr, fontsize=10.5, color=colour,
                ha="left", va="center", family="Times New Roman")

fig.savefig(OUT, bbox_inches="tight", facecolor="white")
print(f"wrote {OUT.relative_to(ROOT)}")
