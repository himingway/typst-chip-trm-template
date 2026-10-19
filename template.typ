// ============================================================================
// template.typ — 技术参考手册 / 芯片设计 Spec 通用模板
// Technical Reference Manual / Chip Design Specification Template
//
// 特性:
//  - 中英文混排友好: 自动 CJK–Latin 间距、拉丁/中文字体分级回退
//  - 封面 / 修订记录 / 目录 / 图表目录
//  - booktabs 三线表、位域图、参数规格表等芯片文档常用组件
//  - 正文 10pt / 表格 9pt / 代码 8pt, 可在 conf 中调整
//
// 用法见 main.typ:
//   #import "template.typ": *
//   #show: trm-doc.with(conf)
// ============================================================================

// ---------------------------------------------------------------------------
// 字体与主色
// ---------------------------------------------------------------------------
#let cjk-fonts = (
  serif: ("Noto Serif CJK SC", "Source Han Serif CN", "SimSun"),
  sans: ("Noto Sans CJK SC", "Source Han Sans CN", "SimHei"),
)

// 正文/等宽字体栈: 拉丁字符命中西文字体, CJK 字符自动回退到中文字体
#let body-fonts = ("New Computer Modern", ..cjk-fonts.serif)
#let mono-fonts = ("DejaVu Sans Mono", "Noto Sans Mono CJK SC", ..cjk-fonts.sans)

// 主色: 用于封面顶部色带、章节分隔线、代码块左标线
#let accent-color = rgb("#1f4e79")

#let trm-conf-default = (
  // --- 文档元信息 (封面 / 页脚) ---
  title: [芯片技术参考手册],
  subtitle: [型号：XC-1000 系列内部设计规格],
  doc-number: "DS-XC1000-TRM-001",
  authors: ("硬件设计部",),
  company: [某某半导体科技有限公司],
  confidentiality: [保密级别：内部公开 │ Internal Use Only],
  version: "v0.1",
  date: datetime.today().display("[year]-[month]-[day]"),
  lang: "zh",

  // --- 版式与字号 ---
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.2cm, x: 2.2cm),
  font-size: 10pt,     // 正文 (中文习惯 10–10.5pt)
  table-size: 9pt,     // 表内文字
  caption-size: 8.5pt, // 图表题注
  code-size: 8pt,      // 代码块
  heading-1-breaks: true, // 一级标题是否另起一页
  numbering-pattern: "1.1", // 章节编号样式
)

// ---------------------------------------------------------------------------
// 主样式函数: #show: trm-doc.with(conf)  (body 由 show 规则自动传入)
// ---------------------------------------------------------------------------
#let trm-doc(conf, body) = {
  set document(
    title: conf.title,
    author: conf.authors.join("、"),
    keywords: ("技术参考手册", "芯片设计", "RISC-V"),
  )

  // ---- 页面与页脚 ----
  set page(
    paper: conf.paper,
    margin: conf.margin,
    numbering: "1 / 1",
    footer: context {
      set text(font: cjk-fonts.sans, size: 7.5pt, fill: luma(115))
      line(length: 100%, stroke: 0.4pt + luma(185))
      v(3.5pt)
      grid(
        columns: (1fr, auto, 1fr),
        align(left, conf.doc-number + "  " + conf.version),
        align(center, counter(page).display("第 1 页 / 共 1 页", both: true)),
        align(right, conf.confidentiality),
      )
    },
  )

  // ---- 正文文字: 拉丁/中文混排 ----
  set text(
    font: body-fonts,
    size: conf.font-size,
    lang: conf.lang,
    region: "cn",
    cjk-latin-spacing: auto, // 中西文之间自动加间距 (关键)
  )

  // ---- 段落: 两端对齐 + 首行缩进两字 ----
  set par(
    justify: true,
    leading: 0.64em,
    spacing: 0.82em,
    first-line-indent: (amount: 2em, all: true),
  )

  // ---- 标题 ----
  set heading(numbering: conf.numbering-pattern)
  show heading: set text(font: cjk-fonts.sans, weight: "bold")
  show heading.where(level: 1): it => {
    if conf.heading-1-breaks and it.numbering != none { pagebreak(weak: true) }
    // 每章重置图/表/公式编号
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    block(above: 1.0em, below: 1.0em)[
      #set text(size: 15pt)
      #it
      #v(0.35em)
      #line(length: 100%, stroke: 1.1pt + accent-color)
    ]
  }
  show heading.where(level: 2): it => {
    set text(size: 12pt)
    block(above: 1.8em, below: 1.35em, it)
  }
  show heading.where(level: 3): it => {
    set text(size: 10.5pt)
    block(above: 1.4em, below: 0.8em, it)
  }

  // ---- 图表: 按章编号 (图 2-1 / 表 3-1) ----
  set figure(numbering: (..n) => numbering("1-1", counter(heading).get().first(), ..n))
  set figure(gap: 0.75em)
  set figure.caption(position: bottom, separator: [　])
  show figure.caption: set text(font: cjk-fonts.sans, size: conf.caption-size)
  show figure.where(kind: table): set figure.caption(position: top)
  // 表题紧跟表格: 缩小题注与表格间距, 并在表格块前留出与正文的间隔
  show figure.where(kind: table): it => [#v(1.25em, weak: true) #it]
  show figure.where(kind: table): set figure(gap: 0.25em)
  // 图题紧跟图片: 缩小题注与图片间距, 图后留出与后文的间隔
  show figure.where(kind: image): it => [#it #v(0.9em, weak: true)]
  show figure.where(kind: image): set figure(gap: 0.3em)

  // ---- 公式按章编号, 文中引用显示 式（4-1） ----
  set math.equation(
    numbering: (..n) => "（" + numbering("1-1", counter(heading).get().first(), ..n) + "）",
    supplement: none,
  )
  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      link(el.location(), [式#it])
    } else {
      it
    }
  }

  // ---- 表格: 默认三线表风格, 表内字号统一缩小 ----
  set table(stroke: none, inset: (y: 3.6pt, x: 5pt))
  show table: set text(size: conf.table-size)
  show table: set par(leading: 0.55em)

  // ---- 代码块: 浅灰底 + 左侧主色标线 ----
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
  // ---- 行内代码: 仅用等宽字体区分, 不加底色 ----
  // 说明: 若给行内代码加背景内边距, 它与全角标点之间会被撑出空格
  show raw.where(block: false): set text(size: 0.95em)

  // ---- 列表间距 ----
  set list(indent: 1em, spacing: 0.7em, tight: false)
  set enum(indent: 1em, spacing: 0.7em, tight: false)

  body
}

// ---------------------------------------------------------------------------
// 辅助组件
// ---------------------------------------------------------------------------

/// 前置页标题 (封面后各部分): 不参与章节编号, 也不进目录
#let fm-title(body) = {
  // 前置页标题是独立段落, 不套用正文的段首缩进
  set par(first-line-indent: 0em)
  block(above: 0em, below: 1.2em)[
    #text(font: cjk-fonts.sans, size: 15pt, weight: "bold")[#body]
    #v(0.5em)
    #line(length: 100%, stroke: 1.1pt + accent-color)
  ]
}

/// 图表目录等前置页里的小标签 (不缩进, 不编号)
#let sub-label(body) = {
  set par(first-line-indent: 0em)
  block(above: 1.3em, below: 0.35em)[
    #text(font: cjk-fonts.sans, size: 9.5pt, weight: "bold", fill: luma(75))[#body]
  ]
}

/// 封面页
#let cover(conf) = {
  set page(footer: none, numbering: none)
  set text(font: body-fonts)
  set par(first-line-indent: 0em)

  // 顶部主色带
  block(width: 100%, height: 5pt, fill: accent-color)

  v(1.0cm)
  block(width: 100%)[
    #text(font: cjk-fonts.sans, size: 10pt, fill: luma(110))[#conf.company]
  ]

  v(3.2cm)
  align(center)[
    #text(font: cjk-fonts.sans, size: 25pt, weight: "bold")[#conf.title]
    #v(0.55cm)
    #line(length: 3.2cm, stroke: 1.4pt + accent-color)
    #v(0.55cm)
    #text(font: cjk-fonts.sans, size: 12pt)[#conf.subtitle]
  ]

  v(2.9cm)
  align(center)[
    #grid(
      columns: (auto, auto),
      align: (right, left),
      column-gutter: 1.3em,
      row-gutter: 0.6em,
      [文档编号], [#conf.doc-number],
      [版本], [#conf.version],
      [作者], [#conf.authors.join("、")],
      [日期], [#conf.date],
    )
  ]

  place(bottom + center, text(font: cjk-fonts.sans, size: 9pt, fill: luma(120))[
    #conf.confidentiality
  ])
}

// ---------------------------------------------------------------------------
// 表格组件
// ---------------------------------------------------------------------------

/// booktabs 三线表: header 为表头单元数组, rows 为二维数组
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

/// 修订记录表: #rev-history(("v0.1", "2026-01-01", "张三", "初稿"),)
#let rev-history(..entries) = booktabs(
  columns: (10%, 15%, 13%, 1fr),
  align: (center, center, center, left),
  header: ([版本], [日期], [作者], [修改说明]),
  rows: entries.pos(),
)

/// 修订记录 + 前置页标题
#let rev-section(..entries) = {
  pagebreak(weak: true)
  fm-title([修订记录])
  rev-history(..entries)
}

/// 信号名 / 寄存器名等宽标记: #sig("uart_tx"), #reg("UART_CTRL")
#let sig(name) = raw(name)
#let reg(name) = raw(name)

/// 位域图 + 字段说明表
/// fields: (名称, 高位, 低位, 属性, 复位值, 说明)
#let bitfield(title, fields, width: 32) = figure(
  caption: title,
  kind: image,
  supplement: [图],
)[
  #table(
    columns: range(width).map(_ => 1fr),
    stroke: none,
    inset: (x: 1pt, y: 2pt),
    align: center + horizon,
    table.hline(stroke: 0.7pt + luma(70)),
    // 位序号行: 每列一个数字, 不画竖线
    ..range(width).rev().map(b => text(size: 7pt, fill: luma(95))[#b]),
    table.hline(stroke: 0.45pt + luma(120)),
    // 位域行: 只在字段边界画竖线
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
    columns: (14%, 10%, 12%, 12%, 1fr),
    align: (left, center, center, center, left),
    inset: (y: 3pt, x: 5pt),
    header: ([字段], [位], [属性], [复位值], [说明]),
    rows: fields.map(f => (
      [#sig(f.at(0))],
      [#f.at(1):#f.at(2)],
      f.at(3),
      f.at(4),
      f.at(5),
    )),
  )
]

/// 寄存器映射总表
/// entries: (名称, 偏移, 位宽, 访问, 说明)
#let reg-table(..entries) = booktabs(
  columns: (24%, 12%, 9%, 11%, 1fr),
  align: (left, center, center, center, left),
  header: ([寄存器名], [偏移], [位宽], [访问], [说明]),
  rows: entries
    .pos()
    .map(e => (sig(e.at(0)), ..e.slice(1).map(x => [#x]))),
)

/// 参数规格表 (时序 / 电气)，仅返回 table；如需编号请包一层 figure
/// rows: (符号, 参数, 最小, 典型, 最大, 单位, 备注)
#let spec-table(..rows) = booktabs(
  columns: (9%, 1fr, auto, auto, auto, 8%, 27%),
  align: (left, left, center, center, center, center, left),
  header: ([符号], [参数], [最小], [典型], [最大], [单位], [备注]),
  rows: rows.pos(),
)

/// 缩略语表: #acronyms(("AHB", "高级高性能总线"), ("RTL", "寄存器传输级"))
#let acronyms(..entries) = booktabs(
  columns: (12%, 1fr),
  align: (left, left),
  header: ([缩写], [说明]),
  rows: entries.pos(),
)
