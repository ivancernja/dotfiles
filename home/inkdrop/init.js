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
