# Typst TRM / Design Specification Templates (Chinese and English)

This repository contains two Typst templates: one for Chinese documents, one for
English documents, covering chip technical reference manuals and design
specifications. The sample document is a fictional XC-1000; both editions compile
to 11 pages.

![Chinese edition](preview/preview-cn.png)

![English edition](preview/preview-en.png)

## Files

| File | Purpose |
|---|---|
| `template.typ` | Chinese template: layout, cover, footer, tables, bit-field diagram, register map, parameter tables |
| `main.typ` | Chinese sample, 11 pages |
| `main.pdf` | Chinese sample output |
| `template-en.typ` | English template, structurally equivalent |
| `main-en.typ` | English sample, 11 pages |
| `main-en.pdf` | English sample output |
| `README.md` | Chinese documentation |
| `preview/` | Preview images |

## Build

```bash
typst compile main.typ        # main.pdf
typst compile main-en.typ     # main-en.pdf
typst watch main-en.typ
```

Requires Typst 0.15 or later. The `.typ` files can also be compiled in the
[Typst Web App](https://typst.app).

## Layout

### Chinese edition

| Item | Value |
|---|---|
| Body | Noto Serif CJK SC, 10 pt, 0.64 em leading |
| Headings | Noto Sans CJK SC Bold |
| Page | A4; 2.5 cm top, 2.2 cm bottom, 2.2 cm sides |
| Paragraphs | Justified, 2 em first-line indent, automatic CJK–Latin spacing |
| Tables | 9 pt, three-rule style |
| Captions | 8.5 pt; table captions above, figure captions below |
| Equations | Numbered by chapter, displayed as `（4-1）`, referenced as `式（4-1）` |
| Footer | Document number, version, page number, confidentiality |

### English edition

| Item | Value |
|---|---|
| Body | Libertinus Serif, 11 pt, 0.63 em leading |
| Headings / captions | Adwaita Sans Bold (fallback: Liberation Sans) |
| Page | A4; 2.7 cm top, 2.4 cm bottom, 3.0 cm sides |
| Paragraphs | Justified, en-US hyphenation, 1.4 em first-line indent; first paragraph after a heading is flush |
| Tables | 9 pt, three-rule style; hyphenation and justification disabled in cells |
| Captions | 8.5 pt, `Figure 2-1: …` / `Table 3-1: …` |
| Equations | Numbered by chapter, displayed as `(4-1)`, referenced as `Equation (4-1)` |
| Footer | Document number, version, page number, confidentiality |

## Numbering and structure

- Sections are numbered `1`, `1.1`.
- Figures, tables, and equations are numbered by chapter: `Figure 2-1`,
  `Table 3-1`, `Equation (4-1)`. Counters reset at every level-1 heading.
  Appendix tables use `Table A-1`.
- Bit-field tables have the columns `Field / Bits / Access / Reset / Description`.
- Tables use three-rule layout and 9 pt text.
- Table captions are above tables; figure captions are below figures. The
  caption-to-object gap is 0.25 em for tables and 0.3 em for figures; the gap to
  surrounding text is 0.9–1.25 em.
- References are a separate section with IEEE bracket numbering, flush-left
  alignment, and a hanging indent.
- Appendix A contains package and pinout information, including `Table A-1`.
- The abbreviation table covers the acronyms used in the body. PDF metadata
  contains the title and author.

Document order:

```text
Cover → Revision History → Contents → List of Figures → List of Tables
→ 1 Overview (Key Features, Terms and Abbreviations)
→ 2 System Architecture (Block Diagram, Clock & Reset, Design Constraints)
→ 3 Registers (Register Map, Bit Fields)
→ 4 Functional Description (UART Module, Firmware Example)
→ Appendix A: Package & Pinout
→ References
```

## Page margins

The margins follow from the target line length:

- Chinese: 210 mm − 2 × 22 mm = 166 mm. A 10 pt CJK glyph is about 3.53 mm wide,
  giving about 47 characters per line.
- English: 210 mm − 2 × 30 mm = 150 mm. At 11 pt, Libertinus Serif averages about
  1.6 mm per character, giving about 94 characters per line.
- 2.5 cm side margins in English would produce about 100 characters per line.
  The 3.0 cm sides reduce this to about 94 while leaving room for tables and code.

## Configuration

Edit `conf` in `main.typ` (Chinese) or `main-en.typ` (English). Defaults are in
each template's `trm-conf-default`.

| Key | Chinese | English | Notes |
|---|---|---|---|
| `font-size` | 10 pt | 11 pt | body text |
| `table-size` | 9 pt | 9 pt | table text |
| `caption-size` | 8.5 pt | 8.5 pt | figure/table captions |
| `code-size` | 8 pt | 8 pt | code blocks |
| `margin` | 2.5 / 2.2 / 2.2 cm | 2.7 / 2.4 / 3.0 cm | top / bottom / sides |
| `heading-1-breaks` | `true` | `true` | page break before each chapter |
| `numbering-pattern` | `1.1` | `1.1` | section numbering |

The accent colour is defined by `accent-color` at the top of each template.

## Components

```typ
#sig("hclk")          // inline signal name
#reg("SYS_CLKSEL")    // register name

#fm-title([Contents]) // front-matter title

#rev-section(
  ("v0.1", "2026-08-01", "A. Chen", "Initial draft"),
)

#booktabs(
  columns: (18%, 22%, 1fr),
  header: ([Source], [Scope], [Behavior]),
  rows: (([#sig("por_rstn")], [Chip-wide], [Power-on reset]),),
)

#figure(caption: [...], kind: table, supplement: [Table])[
  #reg-table(("SYS_ID", "0x000", 32, "RO", [Chip ID and revision]),)
] <tbl:regmap>

#bitfield(
  [SYS_CLKSEL bit fields (offset 0x008)],
  (("SEL", 7, 4, "RW", "0x1", [System clock source]),),
)

#spec-table(([$f_"baud"$], [Baud rate], [—], [—], [6], [Mbps], [Notes]),)

#acronyms(("AHB", "Advanced High-performance Bus"),)
```

The Chinese template exposes the same component names.

## Notes

- Typst treats a newline in the source as a space. Chinese paragraphs should be
  written as one source line and wrapped by the editor.
- Use a non-breaking space between values and units: `400~MHz`, `32~kHz`,
  `0.4~mm`.
- Use an en dash for ranges (`1.8–3.6 V`) and U+2212 for negative values
  (`−40 °C`).
- Chapter-based numbering depends on resetting the counters at each level-1
  heading. Appendix tables use `counter(heading).update((1, 0))` and an `A-1`
  numbering function.
- Missing fonts produce `unknown font family` warnings. Adjust the font lists to
  the fonts installed on the machine.

## License

MIT License. See [LICENSE](LICENSE).

## Chinese documentation

See [README.md](README.md) for the Chinese edition.
