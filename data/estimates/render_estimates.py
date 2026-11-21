"""Render the synthetic garage-estimate images and their truth JSON from data/spec.py.

Usage:
  python data/estimates/render_estimates.py --edge "<path to msedge.exe>" --hand-font "<path to Caveat .ttf>" [E01 E03 ...]

WHY generated, not drawn by hand: the images, the truth JSON and the seed data
come from one spec, so a change (for example during the "break the AI"
challenge) is one edit and one re-run.

Kinds:
  clean              printed estimate
  handwritten_total  printed lines, total written by hand and WRONG on purpose
  skewed_photo       photo of the page: rotated, perspective, uneven light, noise
  stamped            rubber stamp printed over part of the text
  fuel_bill          not an estimate at all (the extraction should say OTHER)
"""
import argparse, json, pathlib, random, subprocess, sys, tempfile

from PIL import Image, ImageEnhance, ImageFilter

HERE = pathlib.Path(__file__).parent
sys.path.insert(0, str(HERE.parent))
import spec  # noqa: E402

W, H = 900, 1200


def money(v):
    return f"{v:,.2f}"


def estimate_html(e, hand_font):
    rows = "".join(
        f"<tr><td>{i + 1}</td><td>{d}</td><td class='r'>{q}</td><td class='r'>{money(p)}</td><td class='r'>{money(q * p)}</td></tr>"
        for i, (d, q, p) in enumerate(e["items"]))
    v = spec.vehicle(e["reg"]) if e["reg"] else None
    items_sum = sum(q * p for _, q, p in e["items"])
    if e["kind"] == "handwritten_total":
        total_cell = f"<td class='r hand'>{e['written_total']:,}/-</td>"
    else:
        total_cell = f"<td class='r'><b>{money(items_sum)}</b></td>"
    stamp = ""
    if e["kind"] == "stamped":
        stamp = (f"<div class='stamp'>RECEIVED<br><span>{e['garage'].upper()}</span><br>30 OCT 2026</div>")
    return f"""<!doctype html><html><head><meta charset='utf-8'><style>
@font-face{{font-family:Hand;src:url('{pathlib.Path(hand_font).as_uri()}');}}
body{{margin:0;width:{W}px;height:{H}px;background:#fff;font-family:Arial,sans-serif;color:#1d1d1d;position:relative}}
.pg{{padding:56px 60px}}
h1{{font-size:34px;margin:0;letter-spacing:1px}} .sub{{font-size:17px;color:#444;margin-top:6px}}
.title{{margin:28px 0 18px;font-size:24px;font-weight:bold;border-top:3px solid #1d1d1d;border-bottom:1px solid #1d1d1d;padding:8px 0}}
.meta{{display:grid;grid-template-columns:1fr 1fr;gap:6px 30px;font-size:17px;margin-bottom:22px}}
table{{width:100%;border-collapse:collapse;font-size:17px}}
th,td{{border:1px solid #777;padding:8px 10px;text-align:left}} th{{background:#eee}}
.r{{text-align:right}} .tot td{{font-size:19px}}
.tot td.hand{{font-family:Hand;font-size:44px;color:#1a2a8a;transform:rotate(-3deg)}}
.foot{{margin-top:40px;font-size:16px;color:#444;display:flex;justify-content:space-between}}
.stamp{{position:absolute;left:300px;top:430px;width:330px;transform:rotate(-14deg);border:6px double rgba(190,20,40,.75);
  color:rgba(190,20,40,.72);font-size:40px;font-weight:bold;text-align:center;padding:10px;border-radius:14px;line-height:1.2}}
.stamp span{{font-size:20px}}
</style></head><body><div class='pg'>
<h1>{e['garage'].upper()}</h1>
<div class='sub'>{e['town']}, Sri Lanka &middot; Tel {e['phone']}</div>
<div class='title'>REPAIR ESTIMATE</div>
<div class='meta'><div>Estimate No: <b>{e['est_no']}</b></div><div>Date: {e['date'][8:]}/{e['date'][5:7]}/{e['date'][:4]}</div>
<div>Vehicle No: <b>{e['reg']}</b></div><div>Make / Model: {v[2] + ' ' + v[3] if v else '-'}</div>
<div>Insurer: Lanka Shield Assurance</div><div>Prepared by: Service Advisor</div></div>
<table><tr><th>#</th><th>Description</th><th class='r'>Qty</th><th class='r'>Unit (LKR)</th><th class='r'>Amount (LKR)</th></tr>
{rows}
<tr class='tot'><td></td><td colspan='3'><b>TOTAL (LKR)</b></td>{total_cell}</tr></table>
<div class='foot'><div>Valid for 30 days. Parts subject to availability.</div><div>________________<br>Authorised signature</div></div>
</div>{stamp}</body></html>"""


def fuel_html(e):
    d, q, p = e["items"][0]
    return f"""<!doctype html><html><head><meta charset='utf-8'><style>
body{{margin:0;width:{W}px;height:{H}px;background:#fff;font-family:'Courier New',monospace;color:#222}}
.r{{width:520px;margin:80px auto;padding:30px;border:1px dashed #999;font-size:22px;line-height:1.6;text-align:center}}
.l{{text-align:left}} hr{{border:0;border-top:2px dashed #999}}
</style></head><body><div class='r'><b>{e['garage'].upper()}</b><br>{e['town']}<br>Tel {e['phone']}<hr>
<div class='l'>{e['est_no']}<br>Date: {e['date']} 08:42<br>Pump: 04<br><br>{d}<br>Rate LKR 306.00 / L</div><hr>
<div class='l'><b>TOTAL LKR {money(p)}</b><br>Paid: CASH</div><hr>Thank you. Drive safely.</div></body></html>"""


def render(html, edge, out_png):
    with tempfile.TemporaryDirectory() as tmp:
        f = pathlib.Path(tmp) / "page.html"
        f.write_text(html, encoding="utf-8")
        subprocess.run([edge, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--allow-file-access-from-files",
                        "--virtual-time-budget=4000", f"--window-size={W},{H}", f"--screenshot={out_png}", f.as_uri()],
                       check=True, capture_output=True)


def photo_effect(img, seed):
    """Make a scan look like a phone photo: rotate, perspective, light falloff, noise."""
    rnd = random.Random(seed)
    bg = Image.new("RGB", (W + 240, H + 240), (96, 84, 70))       # wooden desk
    bg.paste(img, (120, 120))
    bg = bg.rotate(rnd.uniform(5, 8), resample=Image.BICUBIC, fillcolor=(96, 84, 70))
    w, h = bg.size
    d = 60
    bg = bg.transform((w, h), Image.QUAD, (d, 0, 0, h, w, h - d // 2, w - d // 3, 0), resample=Image.BICUBIC)
    shade = Image.linear_gradient("L").resize((w, h)).rotate(35, expand=False)
    bg = Image.composite(bg, ImageEnhance.Brightness(bg).enhance(0.86), shade)
    bg = bg.filter(ImageFilter.GaussianBlur(0.8))
    noise = Image.effect_noise((w, h), 18).convert("RGB")
    return Image.blend(bg, noise, 0.06).resize((W, int(W * h / w)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--edge", required=True)
    ap.add_argument("--hand-font", required=True)
    ap.add_argument("ids", nargs="*")
    a = ap.parse_args()
    (HERE / "truth").mkdir(exist_ok=True)
    for e in spec.ESTIMATES:
        if a.ids and e["id"] not in a.ids:
            continue
        html = fuel_html(e) if e["kind"] == "fuel_bill" else estimate_html(e, a.hand_font)
        png = HERE / f"{e['id']}.png"
        render(html, a.edge, png)
        img = Image.open(png).convert("RGB")
        if e["kind"] == "skewed_photo":
            img = photo_effect(img, e["id"])
        jpg = HERE / f"{e['id']}.jpg"
        img.save(jpg, "JPEG", quality=72, optimize=True)
        png.unlink()
        (HERE / "truth" / f"{e['id']}.json").write_text(json.dumps(spec.truth(e), indent=2), encoding="utf-8")
        print(e["id"], e["kind"], f"{jpg.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
