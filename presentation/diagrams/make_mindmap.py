"""Draw the shared data model as a mind map (presentation/diagrams/mindmap.png).

Usage: python presentation/diagrams/make_mindmap.py --edge "<msedge.exe>" --fonts "<folder with Syne-700.ttf, DMSans-400.ttf, DMSans-700.ttf>"

WHY a mind map next to the EER: the EER shows keys; the mind map shows the
story. The room remembers "person, policy, car, estimate, claim" before
they remember foreign keys. Same 8 tables as sql/00_schema.sql.
"""
import argparse, pathlib, subprocess, tempfile

HERE = pathlib.Path(__file__).parent
W, H = 1664, 640    # wide and short: it fills a slide at full width
INK, MUTED, CARD = "#23262B", "#4B5058", "#FFFDF9"
ORANGE, ORANGE_SOFT = "#C2410C", "#FCE7DA"
BLUE, BLUE_SOFT = "#1D4ED8", "#DCE6FB"
LW, LH = 370, 96    # leaf box size
PILL_W = 280

CENTER = (832, 330)
BRANCHES = {
    # key: (x, y, colour, soft, title lines)
    "core":  (832, 152, INK, CARD, ["Who is the", "customer?"]),
    "case1": (525, 330, ORANGE, ORANGE_SOFT, ["Case 1 · Week 2", "A garage estimate"]),
    "case2": (1139, 330, BLUE, BLUE_SOFT, ["Case 2 · Week 3", "A phone call"]),
}
LEAVES = [
    # (branch, x, y, table, hook)
    ("core", 362, 2, "CUSTOMERS", "The person, known by NIC."),
    ("core", 932, 2, "POLICIES", "Life or motor cover."),
    ("case1", 2, 160, "VEHICLES", "The car on a motor policy."),
    ("case1", 2, 275, "ESTIMATES", "Photo, AI reading, checks."),
    ("case1", 2, 390, "CLAIMS", "What we pay. Checked only."),
    ("case2", 1292, 160, "KB_DOCUMENTS", "Product sheets, branches."),
    ("case2", 1292, 275, "KB_CHUNKS", "Small pieces with vectors."),
    ("case2", 1292, 390, "CALLS", "The call and its AI labels."),
]


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;")


def curve(x1, y1, x2, y2, col, width=4, dash=""):
    mx = (x1 + x2) / 2
    d = f"M{x1},{y1} C{mx},{y1} {mx},{y2} {x2},{y2}" if abs(x2 - x1) > abs(y2 - y1) else \
        f"M{x1},{y1} C{x1},{(y1 + y2) / 2} {x2},{(y1 + y2) / 2} {x2},{y2}"
    dash_attr = f" stroke-dasharray='{dash}'" if dash else ""
    return f"<path d='{d}' fill='none' stroke='{col}' stroke-width='{width}' stroke-linecap='round'{dash_attr}/>"


def svg():
    o = [f"<svg xmlns='http://www.w3.org/2000/svg' width='{W}' height='{H}' viewBox='0 0 {W} {H}'>"]
    cx, cy = CENTER
    # Links: centre -> branch -> leaf (drawn first so boxes sit on top).
    for key, (bx, by, col, soft, _) in BRANCHES.items():
        o.append(curve(cx, cy, bx, by, col, 6))
    for br, lx, ly, _, _ in LEAVES:
        bx, by, col, _, _ = BRANCHES[br]
        tx = lx + LW if lx < bx else lx            # attach to the near side of the leaf
        ty = ly + LH / 2
        if br == "core":
            tx, ty = (lx + LW, ly + LH / 2) if lx < bx else (lx, ly + LH / 2)
        o.append(curve(bx, by, tx, ty, col, 4))
    # The thread between the two cases: the call asks about the claim.
    o.append(f"<path d='M{2 + LW / 2},{390 + LH} C{2 + LW / 2},590 {1292 + LW / 2},590 {1292 + LW / 2},{390 + LH}' fill='none' stroke='{INK}' stroke-width='3' stroke-dasharray='10 9'/>")
    o.append(f"<text x='832' y='625' text-anchor='middle' font-family='DM Sans' font-weight='700' font-size='26' fill='{INK}'>"
             "the caller in Week 3 asks about the claim from Week 2</text>")
    # Centre.
    o.append(f"<ellipse cx='{cx}' cy='{cy}' rx='158' ry='66' fill='{INK}'/>")
    o.append(f"<text x='{cx}' y='{cy - 6}' text-anchor='middle' font-family='Syne' font-weight='700' font-size='30' fill='#F6F2EA'>Lanka Shield</text>")
    o.append(f"<text x='{cx}' y='{cy + 28}' text-anchor='middle' font-family='DM Sans' font-size='22' fill='#C9C3B8'>one app, 8 tables</text>")
    # Branch nodes.
    for key, (bx, by, col, soft, lines) in BRANCHES.items():
        w = PILL_W
        o.append(f"<rect x='{bx - w / 2}' y='{by - 44}' width='{w}' height='88' rx='44' fill='{col}'/>")
        for i, line in enumerate(lines):
            o.append(f"<text x='{bx}' y='{by - 8 + i * 30}' text-anchor='middle' font-family='{'DM Sans' if i == 0 else 'Syne'}' "
                     f"font-weight='700' font-size='{22 if i == 0 else 24}' fill='#FFFDF9'>{esc(line)}</text>")
    # Leaves.
    for br, lx, ly, table, hook in LEAVES:
        _, _, col, soft, _ = BRANCHES[br]
        o.append(f"<rect x='{lx}' y='{ly}' width='{LW}' height='{LH}' rx='16' fill='{soft}' stroke='{col}' stroke-width='3'/>")
        o.append(f"<text x='{lx + 22}' y='{ly + 38}' font-family='Syne' font-weight='700' font-size='28' fill='{col}'>{table}</text>")
        o.append(f"<text x='{lx + 22}' y='{ly + 76}' font-family='DM Sans' font-size='24' fill='{INK}'>{esc(hook)}</text>")
    o.append("</svg>")
    return "".join(o)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--edge", required=True)
    ap.add_argument("--fonts", required=True)
    a = ap.parse_args()
    f = pathlib.Path(a.fonts)
    faces = "".join(f"@font-face{{font-family:'{fam}';font-weight:{w};src:url('{(f / fn).as_uri()}');}}"
                    for fam, w, fn in [("Syne", 700, "Syne-700.ttf"), ("DM Sans", 400, "DMSans-400.ttf"), ("DM Sans", 700, "DMSans-700.ttf")])
    html = f"<!doctype html><html><head><meta charset='utf-8'><style>{faces}body{{margin:0;background:#FBFAF7}}</style></head><body>{svg()}</body></html>"
    with tempfile.TemporaryDirectory() as tmp:
        p = pathlib.Path(tmp) / "mm.html"
        p.write_text(html, encoding="utf-8")
        subprocess.run([a.edge, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--allow-file-access-from-files",
                        "--virtual-time-budget=3000", f"--window-size={W},{H}", f"--screenshot={HERE / 'mindmap.png'}", p.as_uri()],
                       check=True, capture_output=True)
    print("wrote mindmap.png")


if __name__ == "__main__":
    main()
