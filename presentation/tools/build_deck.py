"""Build an editable .pptx from a deck source folder (HTML slides + deck.css).

Usage:
  python presentation/tools/build_deck.py --source presentation/week1/source \
      --out presentation/week1/week1-deck.pptx --fonts <folder with the .ttf files> \
      [--edge "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"]

HOW IT WORKS (why the result looks like the HTML):
  1. Every slide is rendered at 1920x1080 in headless Edge with the real
     fonts (Syne, DM Sans) and deck.css.
  2. extract.js measures each box, text run, table, line and image and
     writes them as JSON into the page.
  3. build_pptx.js (pptxgenjs) redraws them as native, editable
     PowerPoint shapes, text boxes and tables, with the speaker notes.

Needs once: `npm install` in presentation/tools (pptxgenjs), Python 3, Edge.
Fonts are not in the repo (licence and size); pass the folder that holds
Syne-400/700.ttf, DMSans-400/500/700.ttf and JetBrainsMono-400/700.ttf
from Google Fonts.
"""
import argparse, html, json, pathlib, re, subprocess, tempfile

TOOLS = pathlib.Path(__file__).parent

EXTRA_CSS = """
body{margin:0;background:#888;}
.slide{position:relative;width:1920px;height:1080px;overflow:hidden;}
section{position:absolute;inset:0;box-sizing:border-box;}
aside{display:none;}
x-connector{display:block;flex:none;}
table{border-collapse:collapse;}
th,td{border:2px solid #CFC9BE;padding:12px 18px;text-align:left;vertical-align:top;}
th{background:#F1EEE8;font-weight:700;}
section.statement .eyebrow{color:var(--on-dark);}
.code p{font-family:'Consolas','JetBrains Mono',monospace;font-variant-ligatures:none;}
"""
FONTS = {"Syne": [(400, "Syne-400"), (700, "Syne-700")],
         "DM Sans": [(400, "DMSans-400"), (500, "DMSans-500"), (700, "DMSans-700")],
         "JetBrains Mono": [(400, "JetBrainsMono-400"), (700, "JetBrainsMono-700")]}


def page(source, fonts):
    deck = json.loads((source / "deck.json").read_text(encoding="utf-8"))
    faces = "".join(f"@font-face{{font-family:'{fam}';font-weight:{w};src:url('{(fonts / (f + '.ttf')).as_uri()}');}}\n"
                    for fam, files in FONTS.items() for w, f in files)
    slides = ""
    for sid in deck["order"]:
        body = (source / "slides" / f"{sid}.html").read_text(encoding="utf-8")
        # Relative image paths are relative to the source folder.
        body = re.sub(r'src="(?!file:|https?:|/)([^"]+)"',
                      lambda m: f'src="{(source / m.group(1)).resolve().as_uri()}"', body)
        slides += f'<div class="slide">{body}</div>\n'
    css = (source / "deck.css").read_text(encoding="utf-8")
    js = (TOOLS / "extract.js").read_text(encoding="utf-8")
    return deck, (f"<!doctype html><html><head><meta charset='utf-8'><style>{faces}{css}{EXTRA_CSS}</style></head>"
                  f"<body>{slides}<pre id='out'></pre><script>{js}</script></body></html>")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--fonts", required=True)
    ap.add_argument("--edge", default=r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")
    a = ap.parse_args()
    source, fonts, out = pathlib.Path(a.source).resolve(), pathlib.Path(a.fonts).resolve(), pathlib.Path(a.out).resolve()
    deck, doc = page(source, fonts)
    with tempfile.TemporaryDirectory() as tmp:
        tmp = pathlib.Path(tmp)
        (tmp / "extract.html").write_text(doc, encoding="utf-8")
        # Own profile folder: with a normal Edge window open, headless Edge
        # otherwise hands the job to that window and prints nothing.
        dom = subprocess.run([a.edge, "--headless=new", "--disable-gpu", "--allow-file-access-from-files",
                              f"--user-data-dir={tmp / 'profile'}",
                              "--virtual-time-budget=15000", "--window-size=1920,1080", "--dump-dom",
                              (tmp / "extract.html").as_uri()], capture_output=True, text=True, encoding="utf-8").stdout
        layout = json.loads(html.unescape(re.search(r'<pre id="out">(.*?)</pre>', dom, re.S).group(1)))
        (tmp / "layout.json").write_text(json.dumps(layout), encoding="utf-8")
        subprocess.run(["node", str(TOOLS / "build_pptx.js"), str(tmp / "layout.json"), str(source / "deck.json"), str(out)],
                       check=True, cwd=TOOLS)
    print(f"{len(deck['order'])} slides -> {out}")


if __name__ == "__main__":
    main()
