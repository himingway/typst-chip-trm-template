# Typst 芯片 TRM / 设计规格模板

本仓库包含两套 Typst 模板，分别用于中文和英文的芯片技术参考手册（TRM）与设计规格书。示例文档为虚构芯片 XC-1000，两版均编译为 11 页。

![中文版预览](preview/preview-cn.png)

![英文版预览](preview/preview-en.png)

## 文件

| 文件 | 说明 |
|---|---|
| `template.typ` | 中文模板：版式、封面、页脚、表格、位域图、寄存器表、参数表 |
| `main.typ` | 中文示例，11 页 |
| `main.pdf` | 中文示例编译结果 |
| `template-en.typ` | 英文模板，结构与中文版对应 |
| `main-en.typ` | 英文示例，11 页 |
| `main-en.pdf` | 英文示例编译结果 |
| `README-en.md` | 英文说明 |
| `preview/` | 预览图 |

## 构建

```bash
typst compile main.typ        # main.pdf
typst compile main-en.typ     # main-en.pdf
typst watch main.typ
```

依赖 Typst 0.15 或更高版本。也可将对应的 `.typ` 文件上传至 [Typst Web App](https://typst.app) 编译。

## 排版参数

### 中文版

| 项目 | 值 |
|---|---|
| 正文 | Noto Serif CJK SC，10 pt，行距 0.64 em |
| 标题 | Noto Sans CJK SC Bold |
| 页面 | A4；上 2.5 cm，下 2.2 cm，左右 2.2 cm |
| 段落 | 两端对齐，首行缩进 2 em，CJK–Latin 间距自动 |
| 表格 | 9 pt，三线表 |
| 题注 | 8.5 pt，表题在上、图题在下 |
| 公式 | 按章编号，显示 `（4-1）`，引用显示 `式（4-1）` |
| 页脚 | 文档编号、版本、页码、保密级别 |

### 英文版

| 项目 | 值 |
|---|---|
| 正文 | Libertinus Serif，11 pt，行距 0.63 em |
| 标题 / 题注 | Adwaita Sans Bold（回退 Liberation Sans） |
| 页面 | A4；上 2.7 cm，下 2.4 cm，左右 3.0 cm |
| 段落 | 两端对齐，en-US 断词，首行缩进 1.4 em，标题后首段不缩进 |
| 表格 | 9 pt，三线表；单元格内禁用断词与两端对齐 |
| 题注 | 8.5 pt，格式 `Figure 2-1: …` / `Table 3-1: …` |
| 公式 | 按章编号，显示 `(4-1)`，引用显示 `Equation (4-1)` |
| 页脚 | 文档编号、版本、页码、保密级别 |

## 编号与结构

- 章节编号为 `1`、`1.1`。
- 图、表、公式按章编号：`图 2-1`、`表 3-1`、`式（4-1）`；每章开始时重置计数器。附录表编号为 `表 A-1`。
- 位域表列为：`字段 / 位 / 属性 / 复位值 / 说明`。
- 表格使用三线表，表内字号小于正文。
- 表题位于表格上方，图题位于图片下方。表格题注与表格间距 0.25 em，图片题注与图片间距 0.3 em；题注与上下文间距为 0.9–1.25 em。
- 参考文献为独立章节，使用 IEEE 方括号编号、左对齐、悬挂缩进。
- 附录 A 为封装与引脚，包含引脚表 `表 A-1`。
- 缩略语表覆盖正文使用的缩写；PDF 元数据包含标题与作者。

文档顺序：

```text
封面 → 修订记录 → 目录 → 图目录 → 表目录
→ 1 概述（主要特性、术语与缩略语）
→ 2 系统架构（框图、时钟与复位、设计约束）
→ 3 寄存器（总表、位域定义）
→ 4 功能描述（UART 模块、固件示例）
→ 附录 A（封装与引脚）
→ 参考文献
```

## 页边距

页边距由目标行宽确定：

- 中文版：A4 宽度 210 mm − 2 × 22 mm = 166 mm；10 pt 汉字宽约 3.53 mm，每行约 47 字。
- 英文版：210 mm − 2 × 30 mm = 150 mm；11 pt Libertinus Serif 平均字符宽约 1.6 mm，每行约 94 字符。
- 英文版未采用 2.5 cm 边距，因为行宽会达到约 100 字符。两侧收到 3.0 cm 后，行宽约 94 字符，同时保留表格和代码块的横向空间。

## 配置

中文版修改 `main.typ` 的 `conf`，英文版修改 `main-en.typ` 的 `conf`。默认值位于各模板的 `trm-conf-default`。

| 键 | 中文版 | 英文版 | 说明 |
|---|---|---|---|
| `font-size` | 10 pt | 11 pt | 正文 |
| `table-size` | 9 pt | 9 pt | 表内文字 |
| `caption-size` | 8.5 pt | 8.5 pt | 图/表题注 |
| `code-size` | 8 pt | 8 pt | 代码块 |
| `margin` | 2.5 / 2.2 / 2.2 cm | 2.7 / 2.4 / 3.0 cm | 上 / 下 / 左右 |
| `heading-1-breaks` | `true` | `true` | 每章另起一页 |
| `numbering-pattern` | `1.1` | `1.1` | 章节编号 |

主色由各模板顶部的 `accent-color` 定义。

## 组件

```typ
#sig("hclk")          // 行内信号名
#reg("SYS_CLKSEL")    // 寄存器名

#fm-title([目录])     // 前置页标题

#rev-section(
  ("v0.1", "2026-08-01", "张三", "初稿"),
)

#booktabs(
  columns: (18%, 22%, 1fr),
  header: ([复位源], [影响范围], [行为描述]),
  rows: (([#sig("por_rstn")], [全芯片], [上电复位]),),
)

#figure(caption: [...], kind: table, supplement: [表])[
  #reg-table(("SYS_ID", "0x000", 32, "RO", [芯片 ID]),)
] <tbl:regmap>

#bitfield(
  [寄存器 SYS_CLKSEL 位域],
  (("SEL", 7, 4, "RW", "0x1", [时钟源选择]),),
)

#spec-table(([$f_"baud"$], [波特率], [—], [—], [6], [Mbps], [说明]),)

#acronyms(("AHB", "Advanced High-performance Bus，高级高性能总线"),)
```

英文版组件接口相同，参数使用英文内容。

## 注意事项

- Typst 将源码中的换行视为空格。中文段落应在源码中写为一行，由编辑器软换行。
- 数值与单位之间使用不换行空格：`400~MHz`、`32~kHz`、`0.4~mm`。
- 范围使用 en dash：`1.8–3.6 V`；负号使用 U+2212：`−40 °C`。
- 按章编号依赖一级标题处的计数器重置。附录表使用 `counter(heading).update((1, 0))` 与 `A-1` 编号函数。
- 缺少字体时 Typst 会输出 `unknown font family` 警告，可按本机字体调整字体列表。

## 许可证

MIT License，见 [LICENSE](LICENSE)。

## English documentation

英文说明见 [README-en.md](README-en.md)。
