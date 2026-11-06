'use strict'

// A cheat sheet for basic navigation, because the vim plugin's keys are not
// discoverable anywhere in the interface.
//
// Toggle with cmd-shift-/ (that is cmd-?), or click the badge in the corner.
// The bindings below are read from the vim plugin's own keymap and this
// profile's keymap.json, so they are what is actually bound, not a guess.

const GROUPS = [
  {
    title: 'Sidebar',
    hint: 'when the notebook list has focus',
    keys: [
      ['j', 'next item'],
      ['k', 'previous item'],
      ['l', 'expand'],
      ['h', 'collapse'],
    ],
  },
  {
    title: 'Note list',
    hint: 'the middle column',
    keys: [
      ['j', 'next note'],
      ['k', 'previous note'],
    ],
  },
  {
    title: 'Reading a note',
    hint: 'the preview pane',
    keys: [
      ['j', 'scroll down'],
      ['k', 'scroll up'],
      ['ctrl d', 'half page down'],
      ['ctrl u', 'half page up'],
      ['ctrl f', 'full page down'],
      ['ctrl b', 'full page up'],
      ['g g', 'top of note'],
      ['G', 'go to line'],
      ['H', 'top of note'],
    ],
  },
  {
    title: 'Jumping about',
    hint: 'your own bindings',
    keys: [
      ['space e', 'search everything'],
      ['space i', 'focus the note list'],
      ['cmd shift i', 'bring Inkdrop to the front'],
    ],
  },
]

const STYLE = `
#nav-hints-badge {
  position: fixed; right: 14px; bottom: 12px; z-index: 9998;
  width: 22px; height: 22px; border-radius: 11px;
  background: rgba(182,150,247,0.16); color: #b696f7;
  font: 600 12px/22px -apple-system, system-ui, sans-serif;
  text-align: center; cursor: pointer; user-select: none;
  transition: opacity .15s ease; opacity: .45;
}
#nav-hints-badge:hover { opacity: 1; }
#nav-hints {
  position: fixed; right: 14px; bottom: 42px; z-index: 9999;
  width: 460px; max-height: 70vh; overflow-y: auto;
  padding: 16px 18px 14px;
  background: rgba(17,21,28,0.97); color: #c9d3df;
  border: 1px solid #262e3a; border-radius: 10px;
  box-shadow: 0 10px 34px rgba(0,0,0,0.45);
  font: 13px/1.5 -apple-system, system-ui, sans-serif;
}
#nav-hints h3 {
  margin: 0 0 10px; font-size: 13px; font-weight: 600; color: #f7f7ee;
}
#nav-hints .group { margin-bottom: 12px; }
#nav-hints .group:last-child { margin-bottom: 2px; }
#nav-hints .label { color: #5ad1c4; font-weight: 600; font-size: 12px; }
#nav-hints .sub { color: #71808f; font-size: 11px; margin-left: 6px; }
#nav-hints .row {
  display: flex; align-items: baseline; gap: 10px; padding: 1px 0;
}
#nav-hints kbd {
  flex: 0 0 96px; text-align: right;
  font: 11px/1.6 'JetBrainsMono Nerd Font', ui-monospace, monospace;
  color: #b696f7;
}
#nav-hints .what { color: #c9d3df; }
#nav-hints .foot {
  margin-top: 10px; padding-top: 8px; border-top: 1px solid #262e3a;
  color: #71808f; font-size: 11px;
}
`

function build() {
  const panel = document.createElement('div')
  panel.id = 'nav-hints'
  panel.style.display = 'none'

  let html = '<h3>Navigation</h3>'
  for (const group of GROUPS) {
    html += '<div class="group">'
    html += `<div><span class="label">${group.title}</span>`
    html += `<span class="sub">${group.hint}</span></div>`
    for (const [key, what] of group.keys) {
      html += `<div class="row"><kbd>${key}</kbd><span class="what">${what}</span></div>`
    }
    html += '</div>'
  }
  html += '<div class="foot">cmd shift / closes this</div>'
  panel.innerHTML = html
  return panel
}

function install() {
  if (document.getElementById('nav-hints')) return

  const style = document.createElement('style')
  style.textContent = STYLE
  document.head.appendChild(style)

  const panel = build()
  const badge = document.createElement('div')
  badge.id = 'nav-hints-badge'
  badge.textContent = '?'
  badge.title = 'Navigation keys (cmd shift /)'

  const toggle = () => {
    panel.style.display = panel.style.display === 'none' ? 'block' : 'none'
  }
  badge.addEventListener('click', toggle)

  document.body.appendChild(panel)
  document.body.appendChild(badge)

  inkdrop.commands.add(document.body, {
    'custom:toggle-nav-hints': toggle,
  })

  // Escape closes it, which is what everyone tries first.
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && panel.style.display === 'block') {
      panel.style.display = 'none'
    }
  })
}

if (document.body) {
  install()
} else {
  document.addEventListener('DOMContentLoaded', install)
}


// ---------------------------------------------------------------------------
// Hint mode: label everything clickable, type the label to click it.
//
// The same idea as Vimium's f. Inkdrop is an Electron app, so this works on the
// real DOM rather than through Accessibility, which means the labels land on
// exactly what will be clicked.
//
// ctrl-; anywhere, or space f while reading a note.

const HINT_ALPHABET = 'asdfghjklqwertyuiop'

const CLICKABLE = [
  'a[href]',
  'button',
  'input:not([type="hidden"])',
  'textarea',
  'select',
  '[role="button"]',
  '[role="tab"]',
  '[role="menuitem"]',
  '[role="option"]',
  '[tabindex]:not([tabindex="-1"])',
  '.note-list-item',
  '.sidebar-menu-item',
  '.sidebar-menu--item',
  '.note-list-item-wrap',
  '[class*="button"]:not([class*="group"])',
].join(',')

const HINT_STYLE = `
#hint-layer { position: fixed; inset: 0; z-index: 10000; pointer-events: none; }
#hint-layer .hint {
  position: absolute;
  background: #b696f7; color: #11151c;
  font: 700 10px/1 'JetBrainsMono Nerd Font', ui-monospace, monospace;
  padding: 3px 4px; border-radius: 3px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.5);
  text-transform: uppercase; letter-spacing: 0.4px;
}
#hint-layer .hint.partial { background: #5ad1c4; }
#hint-layer .hint.gone { display: none; }
`

let hintLayer = null
let hintEntries = []
let hintTyped = ''

function hintLabels(count) {
  const letters = HINT_ALPHABET.split('')
  if (count <= letters.length) return letters.slice(0, count)
  const out = []
  for (const a of letters) {
    for (const b of letters) {
      out.push(a + b)
      if (out.length >= count) return out
    }
  }
  return out
}

function visibleTargets() {
  const seen = new Set()
  const found = []
  for (const el of document.querySelectorAll(CLICKABLE)) {
    if (seen.has(el)) continue
    const rect = el.getBoundingClientRect()
    if (rect.width < 8 || rect.height < 8) continue
    if (rect.bottom < 0 || rect.top > window.innerHeight) continue
    if (rect.right < 0 || rect.left > window.innerWidth) continue
    const style = getComputedStyle(el)
    if (style.visibility === 'hidden' || style.display === 'none') continue
    if (parseFloat(style.opacity) === 0) continue
    // A clickable inside another clickable would get two labels on the same spot.
    if (found.some((f) => f.el.contains(el))) continue
    seen.add(el)
    found.push({ el, rect })
  }
  return found
}

function clearHints() {
  if (hintLayer) {
    hintLayer.remove()
    hintLayer = null
  }
  hintEntries = []
  hintTyped = ''
  document.removeEventListener('keydown', onHintKey, true)
}

function narrowHints() {
  let matches = 0
  for (const entry of hintEntries) {
    const keep = entry.label.startsWith(hintTyped)
    entry.node.classList.toggle('gone', !keep)
    entry.node.classList.toggle('partial', keep && hintTyped.length > 0)
    if (keep) matches += 1
  }
  return matches
}

function pressTarget(el) {
  clearHints()
  setTimeout(() => {
    try {
      el.focus({ preventScroll: true })
    } catch (err) {
      /* some nodes are not focusable, which is fine */
    }
    // A plain .click() misses handlers bound to mousedown, which Inkdrop's list
    // rows use, so send the full sequence.
    for (const type of ['mousedown', 'mouseup', 'click']) {
      el.dispatchEvent(
        new MouseEvent(type, { bubbles: true, cancelable: true, view: window })
      )
    }
  }, 10)
}

function onHintKey(event) {
  if (event.key === 'Escape') {
    event.preventDefault()
    event.stopPropagation()
    clearHints()
    return
  }
  if (event.key === 'Backspace') {
    event.preventDefault()
    event.stopPropagation()
    hintTyped = hintTyped.slice(0, -1)
    narrowHints()
    return
  }
  if (event.metaKey || event.ctrlKey || event.altKey) return
  if (!/^[a-z]$/i.test(event.key)) {
    clearHints()
    return
  }
  event.preventDefault()
  event.stopPropagation()
  hintTyped += event.key.toLowerCase()
  const exact = hintEntries.find((entry) => entry.label === hintTyped)
  if (exact) {
    pressTarget(exact.el)
    return
  }
  if (narrowHints() === 0) clearHints()
}

function showHints() {
  if (hintLayer) {
    clearHints()
    return
  }
  const targets = visibleTargets()
  if (targets.length === 0) return

  hintLayer = document.createElement('div')
  hintLayer.id = 'hint-layer'

  const labels = hintLabels(targets.length)
  targets.forEach((target, index) => {
    const node = document.createElement('div')
    node.className = 'hint'
    node.textContent = labels[index]
    node.style.left = `${Math.max(0, target.rect.left)}px`
    node.style.top = `${Math.max(0, target.rect.top)}px`
    hintLayer.appendChild(node)
    hintEntries.push({ el: target.el, label: labels[index], node })
  })

  document.body.appendChild(hintLayer)
  document.addEventListener('keydown', onHintKey, true)
}

function installHints() {
  const style = document.createElement('style')
  style.textContent = HINT_STYLE
  document.head.appendChild(style)
  inkdrop.commands.add(document.body, {
    'custom:hint-mode': showHints,
  })
}

if (document.body) {
  installHints()
} else {
  document.addEventListener('DOMContentLoaded', installHints)
}
