// ============================================================================
// main-en.typ — English sample document for template-en.typ
// Compile:  typst compile main-en.typ
// ============================================================================
#import "template-en.typ": *

#let conf = trm-conf-default + (
  title: [XC-1000 Technical Reference Manual],
  subtitle: [XC-1000R / XC-1000E Preliminary Design Specification],
  doc-number: "DS-XC1000-TRM-001",
  authors: ("Alice Chen", "Bob Li"),
  company: [Acme Semiconductor, Inc.],
  version: "v0.3",
)

#show: trm-doc.with(conf)

// ============================== Cover and front matter ==============================
#cover(conf)
#rev-section(
  ("v0.1", "2026-08-01", "A. Chen", "Initial draft: system architecture and register map"),
  ("v0.2", "2026-09-05", "B. Li", "Added UART, clock, and reset sections"),
  ("v0.3", "2026-10-19", "A. Chen", "Refined UART parameter table and bit-field descriptions"),
)

#pagebreak(weak: true)
#fm-title([Contents])
#outline(depth: 2, indent: 1.2em, title: none)

#pagebreak(weak: true)
#fm-title([List of Figures])
#outline(target: figure.where(kind: image), depth: 1, indent: 0em, title: none)

#pagebreak(weak: true)
#fm-title([List of Tables])
#outline(target: figure.where(kind: table), depth: 1, indent: 0em, title: none)

// ============================== 1 Overview ==============================
= Overview

XC-1000 is a 32-bit RISC-V microcontroller for low-power IoT endpoints. It integrates a vector processing unit and runs at up to 400~MHz. This manual is intended for IC design, verification, and FPGA prototyping engineers, and describes the functions, registers, timing, and electrical characteristics of each subsystem.

== Key Features

- 32-bit RISC-V RV32IMAC core at up to 400~MHz, with a 128-bit SIMD vector unit
- 256~KB SRAM and an 8-channel DMA controller on a multi-layer AHB/APB bus
- Three UARTs, two SPI interfaces, four timers, and a 32~kHz wake-up domain
- 1.8–3.6~V supply, QFN-48 package, and −40~°C to +105~°C operating range
- JTAG/cJTAG debug, watchdog, and brown-out reset

== Terms and Abbreviations

#acronyms(
  ("AHB", "Advanced High-performance Bus"),
  ("APB", "Advanced Peripheral Bus"),
  ("cJTAG", "Compact JTAG"),
  ("DMA", "Direct Memory Access"),
  ("FIFO", "First In, First Out"),
  ("FPGA", "Field-Programmable Gate Array"),
  ("GPIO", "General-Purpose Input/Output"),
  ("IC", "Integrated Circuit"),
  ("IoT", "Internet of Things"),
  ("JTAG", "Joint Test Action Group"),
  ("PLL", "Phase-Locked Loop"),
  ("QFN", "Quad Flat No-leads"),
  ("RC", "Resistor-Capacitor"),
  ("RTL", "Register Transfer Level"),
  ("SIMD", "Single Instruction Multiple Data"),
  ("SoC", "System on Chip"),
  ("SPI", "Serial Peripheral Interface"),
  ("SRAM", "Static Random Access Memory"),
  ("UART", "Universal Asynchronous Receiver/Transmitter"),
)

// ============================== 2 System architecture ==============================
= System Architecture

== Block Diagram

See @fig:block. XC-1000 uses a multi-layer bus and multiple clock domains: the core domain runs on #sig("hclk") (up to 400~MHz), the peripheral domain on #sig("pclk"), and the low-power wake-up domain on a 32~kHz #sig("lclk").

#figure(
  caption: [XC-1000 block diagram],
  kind: image,
)[
  #align(center)[
    #block(
      stroke: 0.7pt + luma(80), inset: 12pt, radius: 2pt,
      width: 78%,
    )[
      #grid(
        columns: 3,
        align: center + horizon,
        row-gutter: 9pt, column-gutter: 8pt,
        box(stroke: 0.6pt + luma(90), inset: (x: 6pt, y: 6pt), radius: 2pt, width: 100%)[
          #text(size: 9pt)[*RISC-V Core*\ RV32IMAC]
        ],
        box(stroke: 0.6pt + luma(90), inset: (x: 6pt, y: 6pt), radius: 2pt, width: 100%)[
          #text(size: 9pt)[*Vector Processor*\ 128-bit SIMD]
        ],
        box(stroke: 0.6pt + luma(90), inset: (x: 6pt, y: 6pt), radius: 2pt, width: 100%)[
          #text(size: 9pt)[*SRAM*\ 256 KB]
        ],
        box(stroke: 0.6pt + luma(90), inset: (x: 6pt, y: 6pt), radius: 2pt, width: 100%)[
          #text(size: 9pt)[*AHB Matrix*]
        ],
        box(stroke: 0.6pt + luma(90), inset: (x: 6pt, y: 6pt), radius: 2pt, width: 100%)[
          #text(size: 9pt)[*DMA*\ 8-channel]
        ],
        box(stroke: 0.6pt + luma(90), inset: (x: 6pt, y: 6pt), radius: 2pt, width: 100%)[
          #text(size: 9pt)[*APB Bridge*]
        ],
        box(stroke: 0.6pt + luma(90), inset: (x: 6pt, y: 6pt), radius: 2pt, width: 100%)[
          #text(size: 9pt)[*UART*\ ×3]
        ],
        box(stroke: 0.6pt + luma(90), inset: (x: 6pt, y: 6pt), radius: 2pt, width: 100%)[
          #text(size: 9pt)[*SPI*\ ×2]
        ],
        box(stroke: 0.6pt + luma(90), inset: (x: 6pt, y: 6pt), radius: 2pt, width: 100%)[
          #text(size: 9pt)[*Timer*\ ×4]
        ],
      )
    ]
  ]
] <fig:block>

== Clock & Reset

The clock tree supports an external crystal (#sig("hse")) and an internal RC oscillator. A PLL multiplies the reference clock for the core domain. Reset sources are listed in @tbl:reset.

#figure(
  caption: [Reset sources and behavior],
  kind: table,
  supplement: [Table],
)[
  #booktabs(
    columns: (18%, 22%, 1fr),
    align: (left, left, left),
    header: ([Source], [Scope], [Behavior]),
    rows: (
      ([#sig("por_rstn")], [Chip-wide], [Power-on reset; asserted asynchronously and released synchronously after 16~#sig("hclk") cycles]),
      ([#sig("wdt_rstn")], [Core/peripheral], [Triggered by a watchdog timeout; the wake-up domain is not reset]),
      ([#sig("sw_rstn")], [Software], [Selects subsystems to reset via #reg("SYS_RSTCTL")]),
    ),
  )
] <tbl:reset>

== Design Constraints

Timing closure targets 400~MHz in the core domain (TSMC 28~nm, 0.9~V, 125~°C corner). The critical path lies in the multiply-accumulate array of the vector unit. Static timing margin must be at least 10%, and scan coverage at least 98%.

// ============================== 3 Registers ==============================
= Registers

== Register Map

The system controller base address is `0x4000_0000`. The register map is shown in @tbl:regmap.

#figure(
  caption: [System controller register map (base address 0x4000_0000)],
  kind: table,
  supplement: [Table],
)[
  #reg-table(
    ("SYS_ID", "0x000", 32, "RO", [Chip ID and revision]),
    ("SYS_RSTCTL", "0x004", 32, "RW", [Software reset control]),
    ("SYS_CLKSEL", "0x008", 32, "RW", [Clock source and divider selection]),
    ("SYS_INTEN", "0x00C", 32, "RW", [Interrupt enable]),
    ("SYS_INTSTAT", "0x010", 32, "RC_W1C", [Interrupt status; write 1 to clear]),
  )
] <tbl:regmap>

== Bit Fields

#bitfield(
  [SYS_CLKSEL bit fields (offset 0x008)],
  (
    ("RSVD", 31, 8, "RO", "0x0", [Reserved; reads as 0, writes ignored]),
    ("SEL", 7, 4, "RW", "0x1", [System clock source: 0 = hse, 1 = pll, 2 = rc]),
    ("DIV", 3, 0, "RW", "0x0", [Clock divider: DIV + 1, giving 1–16]),
  ),
)

// ============================== 4 Functional description ==============================
= Functional Description

== UART Module

The UART supports programmable baud rates up to 6~Mbps, 8 or 9 data bits, hardware flow control, and a 64-byte FIFO. The baud rate is given by #ref(<eq:baud>).

$ "baud" = f_"pclk" / (16 (N + "DL"\/32)) $ <eq:baud>

where $N$ is the integer divisor and $"DL"$ the fractional divisor; see @tbl:baud.

#figure(
  caption: [UART baud-rate parameters (#sig("f_pclk") = 100~MHz)],
  kind: table,
  supplement: [Table],
)[
  #spec-table(
    ([$f_"baud"$], [Baud rate], [—], [—], [6], [Mbps], [Set by #sig("pclk") and divider]),
    ([$Delta f_"baud"$], [Baud-rate error], [−2.0], [—], [+2.0], [%], [Over the operating temperature range]),
    ([$t_"bit"$], [Bit time], [—], [—], [—], [—], [16× oversampling]),
    ([$N$], [Integer divisor], [1], [—], [65,535], [—], [—]),
  )
] <tbl:baud>

== Firmware Example

The standard clock-switch sequence is as follows.

```c
// Switch the system clock to PLL and wait for lock
sys_clksel_write(SYS_CLKSEL_SEL_PLL);
while (!sys_pll_locked()) {
    /* Wait for SEL to take effect; fall back to hse on timeout */
}
```

// ============================== Appendix ==============================
#pagebreak(weak: true)
#heading(numbering: none)[Appendix A: Package & Pinout]

#counter(heading).update((1, 0))
#set figure(numbering: (..n) => numbering("A-1", counter(heading).get().first(), ..n))

The device is supplied in a QFN-48 package measuring 7~mm × 7~mm, with a 0.4~mm pitch and an exposed 5~mm × 5~mm thermal pad. Table A-1 lists an excerpt of the pin assignments; the complete pin-multiplexing table is provided in the companion datasheet.

#figure(
  caption: [Pin assignments (excerpt)],
  kind: table,
  supplement: [Table],
)[
  #booktabs(
    columns: (8%, 22%, 12%, 1fr),
    align: (center, left, center, left),
    header: ([Pin], [Name], [Type], [Description]),
    rows: (
      ([1], [VDD], [Power], [1.8–3.6~V supply]),
      ([2], [VSS], [Ground], [Ground reference]),
      ([3], [POR_N], [Input], [Power-on reset, active low]),
      ([4], [HSE_IN], [Input], [Crystal oscillator input]),
      ([5], [HSE_OUT], [Output], [Crystal oscillator output]),
      ([6], [TCK], [Input], [JTAG test clock]),
      ([7], [TMS], [Input], [JTAG test mode select]),
      ([8], [UART0_TX], [Output], [UART0 transmit]),
      ([9], [UART0_RX], [Input], [UART0 receive]),
      ([10], [GPIO0], [I/O], [General-purpose I/O]),
    ),
  )
] <tbl:pins>

#pagebreak(weak: true)
#heading(numbering: none)[References]

#set par(justify: false)
#set text(hyphenate: false)
#set enum(numbering: "[1]", indent: 0em)
+ RISC-V International, "The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA," version 20240411, 2024.
+ Arm Limited, "AMBA AHB-Lite Protocol Specification," ARM IHI 0033.
+ Arm Limited, "AMBA APB Protocol Specification," ARM IHI 0024.
+ Acme Semiconductor, "XC-1000 Datasheet," 2026.
