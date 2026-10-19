// ============================================================================
// template-en.typ — Technical Reference Manual / Chip Design Specification
// English edition
//
// Design notes:
//  - Libertinus Serif body with Adwaita Sans headings and captions
//  - justified text with automatic hyphenation, book-style first-line indent
//  - wide side margins (~73 characters per line at 10.5 pt)
//  - booktabs tables, 9 pt table text, "Figure 2-1: ..." caption style
//  - non-breaking spaces between values and units in the example document
//
// Usage (see main-en.typ):
//   #import "template-en.typ": *
//   #show: trm-doc.with(conf)
// ============================================================================

// ---------------------------------------------------------------------------
// Fonts and accent colour
// ---------------------------------------------------------------------------
#let serif-fonts = ("Libertinus Serif", "New Computer Modern", "Liberation Serif")
#let sans-fonts = ("Adwaita Sans", "Liberation Sans")
#let mono-fonts = ("DejaVu Sans Mono",)

#let accent-color = rgb("#1f4e79")

#let trm-conf-default = (
  // --- document metadata (cover and footer) ---
  title: [Technical Reference Manual],
  subtitle: [Preliminary Design Specification],
  doc-number: "DS-0000-TRM-001",
  authors: ("First Author", "Second Author"),
  company: [Acme Semiconductor, Inc.],
  confidentiality: [Internal Use Only],
  version: "v0.1",
  date: datetime.today().display("[year]-[month]-[day]"),
  lang: "en",

  // --- layout and type ---
  paper: "a4",
  margin: (top: 2.7cm, bottom: 2.4cm, x: 3.0cm),
  font-size: 11pt,
  table-size: 9pt,
  caption-size: 8.5pt,
  code-size: 8pt,
  heading-1-breaks: true,
  numbering-pattern: "1.1",
)

// ---------------------------------------------------------------------------
// Main style function: #show: trm-doc.with(conf)
// ---------------------------------------------------------------------------
#let trm-doc(conf, body) = {
  set document(
    title: conf.title,
    author: conf.authors.join(", "),
    keywords: ("technical reference manual", "register map", "RISC-V"),
  )

  // ---- page and footer ----
  set page(
    paper: conf.paper,
    margin: conf.margin,
    numbering: "1 / 1",
    footer: context {
      set text(font: sans-fonts, size: 7.5pt, fill: luma(115))
      let cur = counter(page).get().first()
      let total = counter(page).final().first()
      line(length: 100%, stroke: 0.4pt + luma(185))
      v(3.5pt)
      grid(
        columns: (1fr, auto, 1fr),
        align(left, conf.doc-number + "  ·  " + conf.version),
        align(center, [Page #cur of #total]),
        align(right, conf.confidentiality),
      )
    },
  )

  // ---- body text: serif, justified, hyphenated ----
  set text(
    font: serif-fonts,
    size: conf.font-size,
    lang: conf.lang,
    region: "us",
    hyphenate: auto,
  )
  set par(
    justify: true,
    leading: 0.63em,
    spacing: 0.6em,
    // first paragraph after a heading stays flush, later ones are indented
    first-line-indent: (amount: 1.4em, all: false),
  )

  // ---- headings: sans ----
  set heading(numbering: conf.numbering-pattern)
  show heading: set text(font: sans-fonts, weight: "bold")
  show heading.where(level: 1): it => {
    if conf.heading-1-breaks and it.numbering != none { pagebreak(weak: true) }
    // restart figure/table/equation numbering in each chapter
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    block(above: 1.2em, below: 1.1em)[
      #set text(size: 15.5pt)
      #it
      #v(0.45em)
      #line(length: 100%, stroke: 1.1pt + accent-color)
    ]
  }
  show heading.where(level: 2): it => {
    set text(size: 12.5pt)
    block(above: 1.8em, below: 1.0em, it)
  }
  show heading.where(level: 3): it => {
    set text(size: 10.5pt)
    block(above: 1.4em, below: 0.8em, it)
  }

  // ---- figures and tables: chapter-based numbering (Figure 2-1) ----
  set figure(numbering: (..n) => numbering("1-1", counter(heading).get().first(), ..n))
  set figure(gap: 0.8em, supplement: [Figure])
  set figure.caption(position: bottom, separator: [: ])
  show figure.caption: set text(font: sans-fonts, size: conf.caption-size)
  show figure.where(kind: table): set figure.caption(position: top)
  // Keep the caption visually attached to its table: tighter caption–table gap
  // and explicit leading space above the whole table block.
  show figure.where(kind: table): it => [#v(1.25em, weak: true) #it]
  show figure.where(kind: table): set figure(gap: 0.25em)
  // Symmetrically, keep a figure caption attached to the image above it.
  show figure.where(kind: image): it => [#it #v(0.9em, weak: true)]
  show figure.where(kind: image): set figure(gap: 0.3em)

  // ---- equations: chapter-based numbering, referenced as Equation (4-1) ----
  set math.equation(
    numbering: (..n) => "(" + numbering("1-1", counter(heading).get().first(), ..n) + ")",
  )

  // ---- tables: booktabs by default, 9 pt text ----
  set table(stroke: none, inset: (y: 3.8pt, x: 5pt))
  show table: set par(justify: false)
  show table: set text(size: conf.table-size, hyphenate: false)

  // ---- code ----
  show raw: set text(font: mono-fonts)
  show raw.where(block: true): it => {
    set text(size: conf.code-size)
    block(
      width: 100%,
      inset: (x: 9pt, y: 7pt),
      fill: luma(248),
      stroke: (left: 2pt + accent-color),
      it,
    )
  }
  show raw.where(block: false): set text(size: 0.95em)

  // ---- lists ----
  set list(indent: 1em, spacing: 0.6em, tight: false)
  set enum(indent: 1em, spacing: 0.6em, tight: false)

  body
}

// ---------------------------------------------------------------------------
// Components
// ---------------------------------------------------------------------------

/// Front-matter title (not a heading, so it stays out of the contents list)
#let fm-title(body) = {
  set par(first-line-indent: 0em)
  block(above: 0em, below: 1.2em)[
    #text(font: sans-fonts, size: 15pt, weight: "bold")[#body]
    #v(0.5em)
    #line(length: 100%, stroke: 1.1pt + accent-color)
  ]
}

/// Cover page
#let cover(conf) = {
  set page(footer: none, numbering: none)
  set text(font: serif-fonts)
  set par(first-line-indent: 0em)

  block(width: 100%, height: 5pt, fill: accent-color)

  v(1.0cm)
  block(width: 100%)[
    #text(font: sans-fonts, size: 9.5pt, fill: luma(110))[#conf.company]
  ]

  v(3.0cm)
  align(center)[
    #text(font: serif-fonts, size: 22pt, weight: "bold", hyphenate: false)[#conf.title]
    #v(0.5cm)
    #line(length: 3.4cm, stroke: 1.4pt + accent-color)
    #v(0.55cm)
    #text(font: sans-fonts, size: 12pt)[#conf.subtitle]
  ]

  v(2.9cm)
  align(center)[
    #grid(
      columns: (auto, auto),
      align: (right, left),
      column-gutter: 1.3em,
      row-gutter: 0.55em,
      [Document No.], [#conf.doc-number],
      [Version], [#conf.version],
      [Author], [#conf.authors.join(", ")],
      [Date], [#conf.date],
    )
  ]

  place(bottom + center, text(font: sans-fonts, size: 9pt, fill: luma(120))[
    #conf.confidentiality
  ])
}

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

/// booktabs-style three-rule table
#let booktabs(columns: auto, header: (), rows: (), align: auto, inset: (y: 3.8pt, x: 5pt)) = table(
  columns: columns,
  align: align,
  stroke: none,
  inset: inset,
  table.hline(stroke: 0.9pt + black),
  table.header(
    ..header.map(c => strong([#c])),
    table.hline(stroke: 0.4pt + luma(80)),
  ),
  ..rows.map(r => r.map(c => [#c])).flatten(),
  table.hline(stroke: 0.9pt + black),
)

/// Revision history
#let rev-history(..entries) = booktabs(
  columns: (10%, 15%, 13%, 1fr),
  align: (center, center, center, left),
  header: ([Version], [Date], [Author], [Description of Change]),
  rows: entries.pos(),
)

/// Revision history with a front-matter title
#let rev-section(..entries) = {
  pagebreak(weak: true)
  fm-title([Revision History])
  rev-history(..entries)
}

/// Signal and register names in monospace: #sig("uart_tx")
#let sig(name) = raw(name)
#let reg(name) = raw(name)

/// Bit-field diagram plus field description
/// fields: (name, msb, lsb, access, reset, description)
#let bitfield(title, fields, width: 32) = figure(
  caption: title,
  kind: image,
  supplement: [Figure],
)[
  #table(
    columns: range(width).map(_ => 1fr),
    stroke: none,
    inset: (x: 1pt, y: 2pt),
    align: center + horizon,
    table.hline(stroke: 0.7pt + luma(70)),
    ..range(width).rev().map(b => text(size: 7pt, fill: luma(95))[#b]),
    table.hline(stroke: 0.45pt + luma(120)),
    ..fields
      .enumerate()
      .map(((i, f)) => {
        let span = calc.max(f.at(1) - f.at(2) + 1, 1)
        let right = if i == fields.len() - 1 { 0.45pt + luma(120) } else { none }
        table.cell(
          colspan: span,
          stroke: (left: 0.45pt + luma(120), right: right),
        )[
          #text(size: 8pt, weight: "bold")[#f.at(0)] \
          #text(size: 7pt, fill: luma(110))[#f.at(1):#f.at(2)]
        ]
      }),
    table.hline(stroke: 0.7pt + luma(70)),
  )
  #v(6pt)
  #booktabs(
    columns: (16%, 10%, 12%, 12%, 1fr),
    align: (left, center, center, center, left),
    inset: (y: 3pt, x: 5pt),
    header: ([Field], [Bits], [Access], [Reset], [Description]),
    rows: fields.map(f => (
      [#sig(f.at(0))],
      [#f.at(1):#f.at(2)],
      f.at(3),
      f.at(4),
      f.at(5),
    )),
  )
]

/// Register map
/// entries: (name, offset, width, access, description)
#let reg-table(..entries) = booktabs(
  columns: (26%, 12%, 9%, 11%, 1fr),
  align: (left, center, center, center, left),
  header: ([Register], [Offset], [Width], [Access], [Description]),
  rows: entries
    .pos()
    .map(e => (sig(e.at(0)), ..e.slice(1).map(x => [#x]))),
)

/// Parameter table (timing / electrical)
/// rows: (symbol, parameter, min, typ, max, unit, notes)
#let spec-table(..rows) = booktabs(
  columns: (12%, 21%, 9%, 9%, 9%, 8%, 1fr),
  align: (left, left, center, center, center, center, left),
  header: ([Symbol], [Parameter], [Min], [Typ], [Max], [Unit], [Notes]),
  rows: rows.pos(),
)

/// Abbreviations: #acronyms(("AHB", "Advanced High-performance Bus"),)
#let acronyms(..entries) = booktabs(
  columns: (20%, 1fr),
  align: (left, left),
  header: ([Abbreviation], [Description]),
  rows: entries.pos(),
)
