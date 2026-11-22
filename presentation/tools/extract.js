// Walk each rendered slide and record what PowerPoint needs to redraw it.
function hex(c) {
  const m = c.match(/rgba?\(([^)]+)\)/);
  if (!m) return null;
  const p = m[1].split(',').map(s => parseFloat(s));
  if (p.length === 4 && p[3] === 0) return null;
  return p.slice(0, 3).map(v => Math.round(v).toString(16).padStart(2, '0')).join('').toUpperCase();
}
const TEXT_TAGS = new Set(['P', 'H1', 'H2', 'H3', 'LI', 'TD', 'TH']);

function runStyle(el) {
  const cs = getComputedStyle(el);
  return {
    font: cs.fontFamily.split(',')[0].replace(/['"]/g, '').trim(),
    size: parseFloat(cs.fontSize),
    bold: parseInt(cs.fontWeight) >= 600,
    italic: cs.fontStyle === 'italic',
    color: hex(cs.color),
    upper: cs.textTransform === 'uppercase',
    spacing: parseFloat(cs.letterSpacing) || 0,
  };
}

function collectRuns(node, out) {
  for (const ch of node.childNodes) {
    if (ch.nodeType === 3) {
      let t = ch.textContent.replace(/[ \t\n\r]+/g, ' ');
      if (!t) continue;
      const st = runStyle(ch.parentElement);
      if (st.upper) t = t.toUpperCase();
      out.push(Object.assign({ text: t }, st));
    } else if (ch.nodeType === 1) {
      if (ch.tagName === 'BR') out.push({ br: true });
      else collectRuns(ch, out);
    }
  }
  return out;
}

function trimRuns(runs) {
  // Trim spaces at paragraph edges, as the browser does.
  const paras = [[]];
  for (const r of runs) { if (r.br) paras.push([]); else paras[paras.length - 1].push(r); }
  for (const p of paras) {
    if (p.length) { p[0].text = p[0].text.replace(/^ +/, ''); p[p.length - 1].text = p[p.length - 1].text.replace(/ +$/, ''); }
  }
  return paras.map(p => p.filter(r => r.text.length));
}

function textItem(el, base) {
  const cs = getComputedStyle(el);
  const r = el.getBoundingClientRect();
  const pl = parseFloat(cs.paddingLeft) + parseFloat(cs.borderLeftWidth);
  const pr = parseFloat(cs.paddingRight) + parseFloat(cs.borderRightWidth);
  const pt = parseFloat(cs.paddingTop) + parseFloat(cs.borderTopWidth);
  const pb = parseFloat(cs.paddingBottom) + parseFloat(cs.borderBottomWidth);
  const lh = cs.lineHeight === 'normal' ? parseFloat(cs.fontSize) * 1.2 : parseFloat(cs.lineHeight);
  const it = {
    kind: 'text', x: r.left - base.left + pl, y: r.top - base.top + pt,
    w: r.width - pl - pr, h: r.height - pt - pb,
    align: ({ right: 'right', center: 'center', end: 'right' })[cs.textAlign] || 'left',
    lineHeight: lh, paras: trimRuns(collectRuns(el, [])),
  };
  if (el.tagName === 'LI') {
    const list = el.parentElement;
    it.list = list.tagName === 'OL' ? 'number' : 'bullet';
    it.index = [...list.children].indexOf(el) + 1;
    it.indent = parseFloat(getComputedStyle(list).paddingLeft);
  }
  return it;
}

function boxItem(el, base) {
  const cs = getComputedStyle(el);
  const r = el.getBoundingClientRect();
  const sides = ['Top', 'Right', 'Bottom', 'Left'].map(s => ({
    w: parseFloat(cs['border' + s + 'Width']) || 0,
    color: hex(cs['border' + s + 'Color']),
    style: cs['border' + s + 'Style'],
  }));
  const fill = hex(cs.backgroundColor);
  const anyBorder = sides.some(s => s.w > 0 && s.style !== 'none' && s.color);
  if (!fill && !anyBorder) return null;
  return {
    kind: 'box', x: r.left - base.left, y: r.top - base.top, w: r.width, h: r.height,
    fill, radius: parseFloat(cs.borderTopLeftRadius) || 0, sides,
  };
}

function tableItem(el, base) {
  const r = el.getBoundingClientRect();
  const rows = [...el.rows].map(tr => {
    const rr = tr.getBoundingClientRect();
    return {
      h: rr.height,
      cells: [...tr.cells].map(td => {
        const cs = getComputedStyle(td);
        const t = textItem(td, base);
        return {
          w: td.getBoundingClientRect().width,
          fill: hex(cs.backgroundColor) || hex(getComputedStyle(tr).backgroundColor),
          align: t.align, paras: t.paras, lineHeight: t.lineHeight,
          border: { w: parseFloat(cs.borderTopWidth), color: hex(cs.borderTopColor) },
          pad: [cs.paddingTop, cs.paddingRight, cs.paddingBottom, cs.paddingLeft].map(parseFloat),
        };
      }),
    };
  });
  return { kind: 'table', x: r.left - base.left, y: r.top - base.top, w: r.width, h: r.height, rows };
}

function walk(el, base, items) {
  for (const ch of el.children) {
    if (ch.tagName === 'ASIDE') continue;
    const cs = getComputedStyle(ch);
    if (cs.display === 'none') continue;
    if (ch.tagName === 'TABLE') { items.push(tableItem(ch, base)); continue; }
    if (ch.tagName === 'IMG') {
      const r = ch.getBoundingClientRect();
      items.push({ kind: 'image', src: ch.getAttribute('src'), alt: ch.getAttribute('alt') || '',
                   x: r.left - base.left, y: r.top - base.top, w: r.width, h: r.height });
      continue;
    }
    if (ch.tagName === 'X-CONNECTOR') {
      const r = ch.getBoundingClientRect();
      items.push({ kind: 'line', x: r.left - base.left, y: r.top - base.top + r.height / 2, w: r.width,
                   head: ch.getAttribute('head') || 'end', color: hex(cs.color), width: parseFloat(cs.borderTopWidth) || 4 });
      continue;
    }
    const b = boxItem(ch, base);
    if (b) items.push(b);
    const hasText = [...ch.childNodes].some(n => n.nodeType === 3 && n.textContent.trim());
    if (TEXT_TAGS.has(ch.tagName) || hasText) items.push(textItem(ch, base));
    else walk(ch, base, items);
  }
}

document.fonts.ready.then(() => {
  const out = [...document.querySelectorAll('.slide > section')].map(sec => {
    const base = sec.getBoundingClientRect();
    const items = [];
    walk(sec, base, items);
    const aside = sec.querySelector(':scope > aside');
    return { id: sec.id, bg: hex(getComputedStyle(sec).backgroundColor), items, notes: aside ? aside.textContent.trim() : '' };
  });
  const fontsOk = ['Syne', 'DM Sans', 'JetBrains Mono'].map(f => f + ':' + document.fonts.check('30px "' + f + '"'));
  document.getElementById('out').textContent = JSON.stringify({ fontsOk, slides: out });
});
