# Typst Chip TRM / Design Specification Templates (Chinese & English)

Typst templates for chip technical reference manuals and design specifications,
with two independent editions:

- **Chinese edition**: `template.typ` + `main.typ` → `main.pdf` (11 pages)
- **English edition**: `template-en.typ` + `main-en.typ` → `main-en.pdf` (11 pages)

Both editions share the same document structure, components, and datasheet/TRM
conventions, while typography (fonts, measure, hyphenation, captions, references)
is tuned separately for each language.

![Chinese edition](preview/preview-cn.png)

![English edition](preview/preview-en.png)

## Files

| File | Purpose |
|---|---|
| `template.typ` | Chinese template: layout, cover, footer, tables, bit-field diagram, register map, parameter tables |
| `main.typ` | Chinese sample (XC-1000), 11 pages |
| `main.pdf` | Chinese sample output |
| `template-en.typ` | English template: layout, cover, footer, tables, bit fields, register map |
| `main-en.typ` | English sample, 11 pages |
| `main-en.pdf` | English sample output |
| `README.md` | Chinese documentation |
| `preview/` | README preview images |

## Quick start

```bash
typst compile main.typ        # Chinese edition → main.pdf
typst compile main-en.typ     # English edition → main-en.pdf

typst watch main-en.typ       # live rebuild
```

Requires Typst **0.15+**. Both `.typ` files can also be uploaded to the
[Typst Web App](https://typst.app).

## Conventions shared by both editions

- **Chapter-based numbering**: `Figure 2-1` / `图 2-1`, `Table 3-1` / `表 3-1`,
  `Equation (4-1)` / `式（4-1）`. Counters restart at every chapter; appendix
  tables use `Table A-1` / `表 A-1`.
- **Bit-field table includes bit positions**: `Field / Bits / Access / Reset /
  Description` (`字段 / 位 / 属性 / 复位值 / 说明`).
- **Three-rule tables** (booktabs), table text smaller than body text.
  Hyphenation and justification are disabled inside English table cells.
- **Caption placement**: table captions above, figure captions below; the
  caption is grouped with its table/figure and separated from surrounding text.
- **References are standalone back matter**, not an appendix subsection:
  IEEE bracket numbers, flush left, hanging indent, ragged right, no hyphenation.
- **Appendix**: `Appendix A: Package & Pinout` / `附录 A　封装与引脚`, including a
  pin-assignment table `Table A-1` / `表 A-1`.
- **Abbreviations** cover every acronym used in the body.
- **PDF metadata** (title and author) is written on export.

## Typography

### Chinese edition

| Aspect | Setting |
|---|---|
| Body | Noto Serif CJK SC, 10 pt, 0.64 em leading |
| Headings | Noto Sans CJK SC Bold |
| Measure | A4, 2.5 / 2.2 cm top/bottom, 2.2 cm sides — about 47 CJK characters per line |
| Paragraphs | Justified, 2 em first-line indent, automatic CJK–Latin spacing |
| Tables | 9 pt, booktabs three-rule style |
| Captions | 8.5 pt sans; table captions above, figure captions below |
| Equations | Chapter-based, displayed `（4-1）`, referenced as `式（4-1）` |
| Footer | Document number · version / page X of Y / confidentiality |

### English edition

| Aspect | Setting |
|---|---|
| Body | Libertinus Serif, 11 pt, 0.63 em leading |
| Headings / captions | Adwaita Sans Bold (fallback: Liberation Sans) |
| Measure | A4, 2.7 / 2.4 cm top/bottom, 3.0 cm sides — about 94 characters per line |
| Paragraphs | Justified, en-US hyphenation, 1.4 em first-line indent; first paragraph after a heading is flush |
| Tables | 9 pt, booktabs rules only; hyphenation and justification disabled in cells |
| Captions | `Figure 2-1: …` / `Table 3-1: …`, 8.5 pt sans |
| Equations | Chapter-based, displayed `(4-1)`, referenced as `Equation (4-1)` |
| References | IEEE `[1]`, flush left, hanging indent, no hyphenation |

### Why these margins

Margins are derived from the desired measure, not fixed by habit:

- Chinese at 10 pt with 2.2 cm sides gives about 47 characters per line, near
  the upper end for technical Chinese text.
- English at 11 pt with Word's default 2.5 cm sides would give about 100
  characters per line. The 3.0 cm sides bring it to about 94 — already the upper
  limit for a technical manual, and the widest text block that still reads well.

Wide tables and code blocks also need the horizontal space, so the margins were
not increased further.

## Structure

```text
Cover → Revision History → Contents → List of Figures → List of Tables
→ 1 Overview (Key Features, Terms and Abbreviations)
→ 2 System Architecture (Block Diagram, Clock & Reset, Design Constraints)
→ 3 Registers (Register Map, Bit Fields)
→ 4 Functional Description (UART Module, Firmware Example)
→ Appendix A: Package & Pinout (pin table)
→ References
```

## Configuration

Edit `conf` at the top of `main.typ` (Chinese) or `main-en.typ` (English);
defaults live in each template's `trm-conf-default`:

| Key | Chinese | English | Notes |
|---|---|---|---|
| `font-size` | 10 pt | 11 pt | body text |
| `table-size` | 9 pt | 9 pt | table text |
| `caption-size` | 8.5 pt | 8.5 pt | figure/table captions |
| `code-size` | 8 pt | 8 pt | code blocks |
| `margin` | 2.5 / 2.2 / 2.2 cm | 2.7 / 2.4 / 3.0 cm | top / bottom / sides |
| `heading-1-breaks` | `true` | `true` | chapters start on a new page |
| `numbering-pattern` | `1.1` | `1.1` | section numbering |

The accent colour is `accent-color` at the top of each template.

## Components

```typ
#sig("hclk")                        // monospace signal name
#reg("SYS_CLKSEL")                  // monospace register name

#fm-title([Contents])               // front-matter title (not in contents)

#rev-section(
  ("v0.1", "2026-08-01", "A. Chen", "Initial draft"),
)

// Any three-rule table
#booktabs(
  columns: (18%, 22%, 1fr),
  header: ([Source], [Scope], [Behavior]),
  rows: (([#sig("por_rstn")], [Chip-wide], [Power-on reset]),),
)

// Register map (wrap in a figure to number it)
#figure(caption: [...], kind: table, supplement: [Table])[
  #reg-table(("SYS_ID", "0x000", 32, "RO", [Chip ID and revision]),)
] <tbl:regmap>

// 32-bit bit-field diagram; the field table includes a Bits column
#bitfield(
  [SYS_CLKSEL bit fields (offset 0x008)],
  (("SEL", 7, 4, "RW", "0x1", [System clock source]),),
)

// Timing / electrical parameters
#spec-table(([$f_"baud"$], [Baud rate], [—], [—], [6], [Mbps], [Notes]),)

// Abbreviations
#acronyms(("AHB", "Advanced High-performance Bus"),)
```

The Chinese template exposes the same component names; pass Chinese content
instead.

## Notes

- Keep body text within one source line per paragraph; Typst treats a newline
  inside a paragraph as a space (applies to both editions).
- Use `~` for non-breaking spaces between values and units.
- Use `–` (en dash) for ranges and `−` (U+2212) for negative values.
- Chapter-based numbering relies on resetting the figure/table/equation counters
  at every level-1 heading. Appendix tables are numbered by setting
  `counter(heading).update((1, 0))` and an `A-1` figure-numbering function.
- Missing fallback fonts produce `unknown font family` warnings; trim the font
  stacks to match the fonts installed on your machine.

## License

No open-source licence is included yet. Choose one (MIT, CC BY 4.0, etc.) before
redistributing.

## Chinese documentation

See [README.md](README.md) for the Chinese edition and additional notes.
