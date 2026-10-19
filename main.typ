// ============================================================================
// main.typ — 模板使用示例: 芯片技术参考手册 / 设计规格
// 编译:  typst compile main.typ
// ============================================================================
#import "template.typ": *

#let conf = trm-conf-default + (
  title: [XC-1000 技术参考手册],
  subtitle: [XC-1000R / XC-1000E 内部设计规格书],
  doc-number: "DS-XC1000-TRM-001",
  authors: ("张三", "李四"),
  version: "v0.3",
)

#show: trm-doc.with(conf)

// ============================== 封面 / 前置页 ==============================
#cover(conf)
#rev-section(
  ("v0.1", "2026-08-01", "张三", "初稿：系统架构、寄存器总表"),
  ("v0.2", "2026-09-05", "李四", "补充 UART 与时钟复位章节"),
  ("v0.3", "2026-10-19", "张三", "完善电气参数表，修订勘误"),
)

#pagebreak(weak: true)
#fm-title([目录])
#outline(depth: 2, indent: 1.2em, title: none)

#pagebreak(weak: true)
#fm-title([图目录])
#outline(target: figure.where(kind: image), depth: 1, indent: 0em, title: none)

#pagebreak(weak: true)
#fm-title([表目录])
#outline(target: figure.where(kind: table), depth: 1, indent: 0em, title: none)

// ============================== 第 1 章 ==============================
= 概述

XC-1000 是一款面向低功耗物联网终端的 32 位 RISC-V 微控制器，内嵌 Vector Processor（向量处理单元），主频最高可达 400 MHz。本手册面向 IC 设计、验证与 FPGA 原型工程师，描述各子系统的功能、寄存器、时序与电气特性。

== 主要特性

- 32 位 RISC-V RV32IMAC 内核，最高主频 400 MHz，内嵌 128 位 SIMD 向量单元
- 256 KB SRAM、8 通道 DMA，AHB / APB 多层总线架构
- 3 路 UART、2 路 SPI、4 路 Timer，支持 32 kHz 低功耗唤醒域
- 1.8–3.6 V 宽压供电，QFN-48 封装，工作温度 −40 ℃ 至 +105 ℃
- 支持 JTAG / cJTAG 调试接口，内置看门狗与欠压复位

== 术语与缩略语

#acronyms(
  ("AHB", "Advanced High-performance Bus，高级高性能总线"),
  ("APB", "Advanced Peripheral Bus，高级外设总线"),
  ("cJTAG", "Compact JTAG，紧凑型 JTAG"),
  ("DMA", "Direct Memory Access，直接存储器访问"),
  ("FIFO", "First In, First Out，先进先出队列"),
  ("FPGA", "Field-Programmable Gate Array，现场可编程门阵列"),
  ("GPIO", "General-Purpose Input/Output，通用输入输出"),
  ("IC", "Integrated Circuit，集成电路"),
  ("JTAG", "Joint Test Action Group，联合测试行动组"),
  ("PLL", "Phase-Locked Loop，锁相环"),
  ("QFN", "Quad Flat No-leads，方形扁平无引脚封装"),
  ("RC", "Resistor-Capacitor，阻容（振荡器）"),
  ("RTL", "Register Transfer Level，寄存器传输级"),
  ("SIMD", "Single Instruction Multiple Data，单指令多数据"),
  ("SoC", "System on Chip，片上系统"),
  ("SPI", "Serial Peripheral Interface，串行外设接口"),
  ("SRAM", "Static Random Access Memory，静态随机存取存储器"),
  ("UART", "Universal Asynchronous Receiver/Transmitter，通用异步收发器"),
)

= 系统架构

== 框图

见@fig:block。XC-1000 采用三层总线结构：Core 域运行在 #sig("hclk")（最高 400 MHz），外设域运行在 #sig("pclk")，低速唤醒域运行在 32 kHz #sig("lclk")。

#figure(
  caption: [XC-1000 系统框图],
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

== 时钟与复位

时钟树支持 #sig("hse")（外部高速晶振）与内部 RC 振荡器，经 PLL 倍频后供给 Core 域。复位层级如@tbl:reset 所示。

#figure(
  caption: [复位源与行为],
  kind: table,
  supplement: [表],
)[
  #booktabs(
    columns: (18%, 20%, 1fr),
    align: (left, left, left),
    header: ([复位源], [影响范围], [行为描述]),
    rows: (
      ([#sig("por_rstn")], [全芯片], [上电复位，异步断言、同步释放，保持 16 个 #sig("hclk") 周期]),
      ([#sig("wdt_rstn")], [Core 域 + 外设域], [看门狗超时触发，不复位唤醒域]),
      ([#sig("sw_rstn")], [软件可配置], [由 #reg("SYS_RSTCTL") 按位选择复位子系统]),
    ),
  )
] <tbl:reset>

== 设计约束

综合约束：Core 域目标频率 400 MHz（TSMC 28 nm 工艺，0.9 V / 125 ℃ 工艺角），其中关键路径位于向量单元的乘加阵列。静态时序余量要求 ≥ 10%，扫描链覆盖率 ≥ 98%。

= 寄存器

== 寄存器总表

系统控制模块基地址为 `0x4000_0000`，映射如@tbl:regmap 所示。

#figure(
  caption: [系统控制模块寄存器映射（基地址 0x4000_0000）],
  kind: table,
  supplement: [表],
)[
  #reg-table(
    ("SYS_ID", "0x000", 32, "RO", [芯片 ID 与版本号]),
    ("SYS_RSTCTL", "0x004", 32, "RW", [软件复位控制]),
    ("SYS_CLKSEL", "0x008", 32, "RW", [时钟源与分频选择]),
    ("SYS_INTEN", "0x00C", 32, "RW", [中断使能]),
    ("SYS_INTSTAT", "0x010", 32, "RC_W1C", [中断状态，写 1 清零]),
  )
] <tbl:regmap>

== 位域定义

#bitfield(
  [寄存器 #raw("SYS_CLKSEL")（偏移 0x008）位域定义],
  (
    ("RSVD", 31, 8, "RO", "0x0", [保留，读为 0，写无效]),
    ("SEL", 7, 4, "RW", "0x1", [系统时钟源选择：0=hse, 1=pll, 2=rc]),
    ("DIV", 3, 0, "RW", "0x0", [分频比 DIV+1，范围 1–16]),
  ),
)

= 功能描述

== UART 模块

UART 支持可编程波特率（最高 6 Mbps）、8/9 位数据、硬件流控与 FIFO 深度 64 字节。波特率计算公式如#ref(<eq:baud>)所示：

$ "baud" = "f"_"pclk" / (16 (N + "DL"\/32)) $ <eq:baud>

其中 $N$ 为整数分频，$"DL"$ 为小数分频。典型配置见@tbl:baud。

#figure(
  caption: [UART 波特率参数（#sig("f_pclk") = 100 MHz）],
  kind: table,
  supplement: [表],
)[
  #spec-table(
    ([$f_"baud"$], [波特率], [—], [—], [6], [Mbps], [由 #sig("pclk") 与分频系数决定]),
    ([$Delta f_"baud"$], [波特率误差], [−2.0], [—], [+2.0], [%], [全温度范围]),
    ([$t_"bit"$], [位时间], [—], [—], [—], [—], [16 倍过采样]),
    ([$N$], [整数分频], [1], [—], [65,535], [—], [—]),
  )
] <tbl:baud>

== 固件示例

时钟切换的标准流程如下：

```c
// 将系统时钟切换到 PLL 并等待锁定
sys_clksel_write(SYS_CLKSEL_SEL_PLL);
while (!sys_pll_locked()) {
    /* 等待 SYS_CLKSEL.SEL 生效，超时需回退到 hse */
}
```

#pagebreak(weak: true)
#heading(numbering: none)[附录 A　封装与引脚]

#counter(heading).update((1, 0))
#set figure(numbering: (..n) => numbering("A-1", counter(heading).get().first(), ..n))

XC-1000 采用 7 mm × 7 mm 的 QFN-48 封装，引脚间距 0.4 mm，裸露散热焊盘尺寸 5 mm × 5 mm。表 A-1 列出部分引脚分配，完整引脚复用表见配套数据手册。

#figure(
  caption: [引脚分配（摘录）],
  kind: table,
  supplement: [表],
)[
  #booktabs(
    columns: (8%, 22%, 14%, 1fr),
    align: (center, left, center, left),
    header: ([引脚], [名称], [类型], [说明]),
    rows: (
      ([1], [VDD], [电源], [1.8–3.6 V 供电]),
      ([2], [VSS], [地], [接地]),
      ([3], [POR_N], [输入], [上电复位，低有效]),
      ([4], [HSE_IN], [输入], [晶振输入]),
      ([5], [HSE_OUT], [输出], [晶振输出]),
      ([6], [TCK], [输入], [JTAG 测试时钟]),
      ([7], [TMS], [输入], [JTAG 测试模式选择]),
      ([8], [UART0_TX], [输出], [UART0 发送]),
      ([9], [UART0_RX], [输入], [UART0 接收]),
      ([10], [GPIO0], [输入/输出], [通用输入输出]),
    ),
  )
] <tbl:pins>

#pagebreak(weak: true)
#heading(numbering: none)[参考文献]

#set par(justify: false)
#set enum(numbering: "[1]", indent: 0em)
+ RISC-V Instruction Set Manual, Volume I: Unprivileged ISA, v20240411.
+ AMBA AHB-Lite Protocol Specification, ARM IHI 0033.
+ AMBA APB Protocol Specification, ARM IHI 0024.
+ 《XC-1000 数据手册》，2026.
