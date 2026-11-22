// Build week1-deck.pptx from layout.json (positions measured in a 1920x1080 browser render).
const fs = require('fs');
const path = require('path');
const pptxgen = require('pptxgenjs');

const [, , layoutPath, deckJsonPath, outPath] = process.argv;
const layout = JSON.parse(fs.readFileSync(layoutPath, 'utf8'));
const deck = JSON.parse(fs.readFileSync(deckJsonPath, 'utf8'));

const PX = 1 / 144;        // 1920 px = 13.333 in
const PT = 0.5;            // 1 px = 0.5 pt at this scale
const WIDTH_SLACK = 1.04;  // PowerPoint wraps a little earlier than Chrome

const pres = new pptxgen();
pres.layout = 'LAYOUT_WIDE';
pres.title = deck.title;
pres.author = 'Noob Dev';
pres.theme = { headFontFace: 'Syne', bodyFontFace: 'DM Sans' };

// Sections from the deck outline.
const sectionAt = {};
for (const s of Object.values(deck.sections)) sectionAt[s.start] = s.description.split(':')[0].split(' (')[0];
let currentSection = null;

const in_ = v => +(v * PX).toFixed(4);

function runsFor(paras, it, extra = {}) {
  const out = [];
  paras.forEach((p, pi) => {
    if (!p.length) p = [{ text: '', font: 'DM Sans', size: 30, color: '23262B' }];
    p.forEach((r, ri) => {
      const o = {
        fontFace: r.font, fontSize: +(r.size * PT).toFixed(1), bold: !!r.bold, italic: !!r.italic,
        color: r.color || '23262B', align: it.align, lineSpacing: +(it.lineHeight * PT).toFixed(1),
        paraSpaceBefore: 0, paraSpaceAfter: 0, ...extra,
      };
      if (r.spacing) o.charSpacing = +(r.spacing * PT).toFixed(1);
      if (ri === p.length - 1 && pi < paras.length - 1) o.breakLine = true;
      out.push({ text: r.text, options: o });
    });
  });
  return out;
}

function addBox(slide, b) {
  const s = b.sides;
  const uniform = s.every(x => x.w === s[0].w && x.color === s[0].color && x.style === s[0].style);
  const shapeType = b.radius > 0 ? pres.shapes.ROUNDED_RECTANGLE : pres.shapes.RECTANGLE;
  const opts = { x: in_(b.x), y: in_(b.y), w: in_(b.w), h: in_(b.h) };
  if (b.radius > 0) opts.rectRadius = Math.min(in_(b.radius), in_(Math.min(b.w, b.h) / 2));
  opts.fill = b.fill ? { color: b.fill } : { type: 'none' };
  if (uniform && s[0].w > 0 && s[0].style !== 'none' && s[0].color) {
    opts.line = { color: s[0].color, width: +(s[0].w * PT).toFixed(2), dashType: s[0].style === 'dashed' ? 'dash' : 'solid' };
  } else {
    opts.line = { type: 'none' };
  }
  slide.addShape(shapeType, opts);
  if (!uniform) {
    const segs = [[b.x, b.y, b.w, 0, s[0]], [b.x + b.w, b.y, 0, b.h, s[1]], [b.x, b.y + b.h, b.w, 0, s[2]], [b.x, b.y, 0, b.h, s[3]]];
    for (const [x, y, w, h, side] of segs) {
      if (side.w > 0 && side.color && side.style !== 'none')
        slide.addShape(pres.shapes.LINE, { x: in_(x), y: in_(y), w: in_(w), h: in_(h), line: { color: side.color, width: +(side.w * PT).toFixed(2) } });
    }
  }
}

function addText(slide, it) {
  const extra = {};
  let x = it.x, w = it.w;
  if (it.list) {
    x -= it.indent; w += it.indent;
    extra.bullet = it.list === 'number' ? { type: 'number', numberStartAt: it.index, indent: +(it.indent * PT).toFixed(1) }
                                       : { indent: +(it.indent * PT).toFixed(1) };
  }
  // Right-aligned text grows to the left; others grow to the right.
  const grow = w * (WIDTH_SLACK - 1);
  if (it.align === 'right') x -= grow; else if (it.align === 'center') x -= grow / 2;
  slide.addText(runsFor(it.paras, it, extra), {
    x: in_(x), y: in_(it.y), w: in_(w + grow), h: in_(Math.max(it.h, it.lineHeight)),
    margin: 0, valign: 'top', isTextBox: true, fit: 'none', wrap: true,
  });
}

function addTable(slide, t) {
  const colW = t.rows[0].cells.map(c => in_(c.w));
  const rows = t.rows.map(r => r.cells.map(c => ({
    text: runsFor(c.paras, c),
    options: {
      fill: c.fill ? { color: c.fill } : undefined,
      border: [0, 1, 2, 3].map(() => ({ type: 'solid', pt: +(c.border.w * PT).toFixed(2), color: c.border.color || 'CFC9BE' })),
      margin: c.pad.map(p => +(p * PT).toFixed(1)),
      valign: 'top', align: c.align,
    },
  })));
  slide.addTable(rows, { x: in_(t.x), y: in_(t.y), w: in_(t.w), colW, rowH: t.rows.map(r => in_(r.h)) });
}

function addLine(slide, l) {
  const line = { color: l.color || '23262B', width: +(l.width * PT).toFixed(2), endArrowType: 'triangle' };
  if (l.head === 'both') line.beginArrowType = 'triangle';
  slide.addShape(pres.shapes.LINE, { x: in_(l.x), y: in_(l.y), w: in_(l.w), h: 0, line });
}

for (const s of layout.slides) {
  if (sectionAt[s.id]) { currentSection = sectionAt[s.id]; pres.addSection({ title: currentSection }); }
  const slide = pres.addSlide(currentSection ? { sectionTitle: currentSection } : {});
  slide.background = { color: s.bg || 'FBFAF7' };
  for (const it of s.items) {
    if (it.kind === 'box') addBox(slide, it);
    else if (it.kind === 'text') addText(slide, it);
    else if (it.kind === 'table') addTable(slide, it);
    else if (it.kind === 'line') addLine(slide, it);
    else if (it.kind === 'image') slide.addImage({ path: decodeURIComponent(it.src.replace('file:///', '')), x: in_(it.x), y: in_(it.y), w: in_(it.w), h: in_(it.h), altText: it.alt });
  }
  if (s.notes) slide.addNotes(s.notes);
}

pres.writeFile({ fileName: outPath }).then(f => console.log('wrote', f));
