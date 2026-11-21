"""Draw the shared data model (EER) as PNGs in the deck's style.

Usage: python presentation/diagrams/make_eer.py --edge "<msedge.exe>" --fonts "<folder with Syne-700.ttf, DMSans-400.ttf, DMSans-700.ttf>"

Writes three versions so each week can light up its own tables:
  eer-all.png    both cases coloured (Week 1, "one app, one data model")
  eer-week2.png  Case 1 tables lit, the rest grey (Week 2)
  eer-week3.png  Case 2 tables lit, the rest grey (Week 3)

Source of truth for tables, keys and relationships: sql/00_schema.sql.
"""
import argparse, pathlib, subprocess, tempfile

HERE = pathlib.Path(__file__).parent
W, H = 1664, 800
BW = 350                      # box width
COLS = [4, 440, 876, 1304]    # x of each column
INK, MUTED, LINE, CARD = "#23262B", "#4B5058", "#C9C3B8", "#FFFDF9"
ORANGE, ORANGE_SOFT = "#C2410C", "#FCE7DA"
BLUE, BLUE_SOFT = "#1D4ED8", "#DCE6FB"
GREY_TEXT = "#A8A29A"

# name: (x, y, group, [(column, tag)])   tag: PK / FK / UK / ""
TABLES = {
    "CUSTOMERS":    (COLS[0], 0,   "core",  [("customer_id", "PK"), ("nic", "UK"), ("full_name", ""), ("city, branch", "")]),
    "POLICIES":     (COLS[1], 0,   "core",  [("policy_id", "PK"), ("policy_no", "UK"), ("customer_id", "FK"), ("policy_type, status", "")]),
    "VEHICLES":     (COLS[2], 0,   "case1", [("vehicle_id", "PK"), ("reg_no", "UK"), ("policy_id", "FK"), ("make, model, year", "")]),
    "KB_DOCUMENTS": (COLS[3], 0,   "case2", [("doc_id", "PK"), ("title", ""), ("doc_type", ""), ("body  CLOB", "")]),
    "CALLS":        (COLS[0], 430, "case2", [("call_id", "PK"), ("customer_id", "FK"), ("transcript  CLOB", ""), ("ai_intent, ai_reply", "")]),
    "CLAIMS":       (COLS[1], 430, "case1", [("claim_id", "PK"), ("claim_no", "UK"), ("policy_id", "FK"), ("vehicle_id", "FK"), ("estimate_id", "FK"), ("status", "")]),
    "ESTIMATES":    (COLS[2], 430, "case1", [("estimate_id", "PK"), ("image  BLOB", ""), ("extracted_json  JSON", ""), ("check_results  JSON", ""), ("review_status", ""), ("claim_id", "FK")]),
    "KB_CHUNKS":    (COLS[3], 430, "case2", [("chunk_id", "PK"), ("doc_id", "FK"), ("chunk_text  CLOB", ""), ("embedding  VECTOR", "")]),
}
# (from, to, label at from end, label at to end, from side, to side)
RELS = [
    ("CUSTOMERS", "POLICIES", "1", "N", "right", "left"),
    ("POLICIES", "VEHICLES", "1", "N", "right", "left"),
    ("CUSTOMERS", "CALLS", "1", "N", "bottom", "top"),
    ("POLICIES", "CLAIMS", "1", "N", "bottom", "top"),
    ("VEHICLES", "CLAIMS", "1", "N", "bottom", "top"),
    ("CLAIMS", "ESTIMATES", "1", "1", "right", "left"),
    ("KB_DOCUMENTS", "KB_CHUNKS", "1", "N", "bottom", "top"),
]
HEAD, ROW = 56, 38


def box_h(name):
    return HEAD + 14 + ROW * len(TABLES[name][3])


def anchor(name, side):
    x, y, _, _ = TABLES[name]
    h = box_h(name)
    return {"right": (x + BW, y + 40), "left": (x, y + 40), "bottom": (x + BW / 2, y + h),
            "top": (x + BW / 2, y)}[side]


def colours(group, lit):
    if group == "core":
        return INK, CARD, INK
    if lit is None or group == lit:
        return (ORANGE, ORANGE_SOFT, ORANGE) if group == "case1" else (BLUE, BLUE_SOFT, BLUE)
    return LINE, "#F4F2EE", GREY_TEXT


def svg(lit):
    out = [f"<svg xmlns='http://www.w3.org/2000/svg' width='{W}' height='{H}' viewBox='0 0 {W} {H}'>"]
    for a, b, la, lb, sa, sb in RELS:
        x1, y1 = anchor(a, sa)
        x2, y2 = anchor(b, sb)
        dim = lit and all(TABLES[t][2] not in ("core", lit) for t in (a, b) if TABLES[t][2] != "core") and \
            any(TABLES[t][2] not in ("core", lit) for t in (a, b))
        col = LINE if dim else INK
        if (a, b) == ("VEHICLES", "CLAIMS"):   # elbow through the gap between the rows
            x1, x2 = TABLES[a][0] + 70, TABLES[b][0] + BW - 70
            path = f"M{x1},{y1} V{y1 + 120} H{x2} V{y2}"
        else:
            path = f"M{x1},{y1} L{x2},{y2}"
        out.append(f"<path d='{path}' fill='none' stroke='{col}' stroke-width='3'/>")
        for (x, y, s, lab) in ((x1, y1, sa, la), (x2, y2, sb, lb)):
            dx = {"right": 14, "left": -26, "bottom": 10, "top": 10}[s]
            dy = {"right": -10, "left": -10, "bottom": 28, "top": -12}[s]
            out.append(f"<text x='{x + dx}' y='{y + dy}' font-family='DM Sans' font-weight='700' font-size='24' fill='{col}'>{lab}</text>")
    for name, (x, y, group, cols) in TABLES.items():
        stroke, fill, title = colours(group, lit)
        h = box_h(name)
        text = INK if title != GREY_TEXT else GREY_TEXT
        out.append(f"<rect x='{x}' y='{y}' width='{BW}' height='{h}' rx='14' fill='{fill}' stroke='{stroke}' stroke-width='3'/>")
        out.append(f"<line x1='{x}' y1='{y + HEAD}' x2='{x + BW}' y2='{y + HEAD}' stroke='{stroke}' stroke-width='2'/>")
        out.append(f"<text x='{x + 22}' y='{y + 38}' font-family='Syne' font-weight='700' font-size='28' fill='{title}'>{name}</text>")
        for i, (c, tag) in enumerate(cols):
            cy = y + HEAD + 36 + i * ROW
            if tag:
                out.append(f"<text x='{x + 22}' y='{cy}' font-family='DM Sans' font-weight='700' font-size='20' fill='{title}'>{tag}</text>")
            out.append(f"<text x='{x + 70}' y='{cy}' font-family='DM Sans' font-size='24' fill='{text}'>{c}</text>")
    out.append("</svg>")
    return "".join(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--edge", required=True)
    ap.add_argument("--fonts", required=True)
    a = ap.parse_args()
    f = pathlib.Path(a.fonts)
    faces = "".join(f"@font-face{{font-family:'{fam}';font-weight:{w};src:url('{(f / fn).as_uri()}');}}"
                    for fam, w, fn in [("Syne", 700, "Syne-700.ttf"), ("DM Sans", 400, "DMSans-400.ttf"), ("DM Sans", 700, "DMSans-700.ttf")])
    for name, lit in (("eer-all", None), ("eer-week2", "case1"), ("eer-week3", "case2")):
        html = f"<!doctype html><html><head><meta charset='utf-8'><style>{faces}body{{margin:0;background:#FBFAF7}}</style></head><body>{svg(lit)}</body></html>"
        with tempfile.TemporaryDirectory() as tmp:
            p = pathlib.Path(tmp) / "eer.html"
            p.write_text(html, encoding="utf-8")
            subprocess.run([a.edge, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--allow-file-access-from-files",
                            "--virtual-time-budget=3000", f"--window-size={W},{H}", f"--screenshot={HERE / (name + '.png')}", p.as_uri()],
                           check=True, capture_output=True)
        print("wrote", name + ".png")


if __name__ == "__main__":
    main()
