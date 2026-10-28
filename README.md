# MoonBit STA

单理想时钟、单角 NLDM（标量/1D/2D）门级时序分析库。参赛账号 `yesuifengliu01`，项目 ID `liberty`，本地模块 `yesuifengliu01/sta`。源码仓库：[yesuifengliu01/moonbit-liberty](https://github.com/yesuifengliu01/moonbit-liberty)。本次源码发布不代表赛事换题批准，也不包含 Mooncakes 包发布或赛事提交。

独立实现网表校验/拓扑排序、集中负载聚合、rise/fall 图传播、clock-to-Q、建立时间约束和可解释路径。Liberty 文本解析、领域模型、Boolean AST 与查表复用 **SongYZZZ/moon-liberty 0.4.1**；OpenSTA 仅作独立验证进程，运行时不依赖它。

## 运行

已验证 MoonBit SDK `0.10.13+cbb11c36f` / moon `0.1.20260915`、Node.js，WSL Ubuntu 环境。构建/测试命令在本目录执行；CLI 可从其他目录调用：

首次使用可运行 `node tools/sta.cjs --help`，查看参数、输入要求、退出码与模型边界；无需预先构建或提供输入，也不等待 stdin。只有单独的 `--help` 进入帮助模式，正常输出退出 0；帮助输出失败仍报 stderr、退出 2。分析命令需要下面的 JS 构建。

```sh
moon update
moon check --target all --deny-warn
moon build --target js --release
node tools/sta.cjs examples/sky130-demo.lib examples/sequential.json
moon test --target js --deny-warn
moon test --target wasm-gc --deny-warn
```

消费者成功输出 `{"ok":true,"schema":"moonbit.sta.v1","result":...}`。分析/参数/IO 错误退出码 2；默认模式正常分析即使存在负 slack 仍退出 0，调用者应检查 `worst_slack_seconds`。`tools/sta.cjs` 负责请求 IO、调用 MoonBit 导出及映射检查退出码；时序计算在 MoonBit 核心。

CLI 的相对输入路径相对于调用者当前目录，编译核心按工具自身位置定位。从其他目录调用时，使用工具的实际路径，并对含空格的路径加引号；中文与 Unicode 文件路径已有实际验证。文件读取失败输出到 stderr 并退出 2；已读取的坏 JSON 则由核心输出 `ok:false` JSON 并退出 2。

若 stdout 写入失败（例如下游提前关闭管道），CLI 在 stderr 报告 `stdout:` 错误并退出 2，覆盖本次计算的 0/3/4；接收端关闭后无法保证完整 JSON。正常接收报告时仍使用原退出规则。成功写入只说明操作系统接受了数据，调用方仍负责解析和保存报告。

Node CLI 的库/请求文件及请求 stdin 必须是合法 UTF-8。坏字节在核心解析前以 `Invalid UTF-8 in Liberty input` 或 `Invalid UTF-8 in request input` 报到 stderr、退出 2，stdout 为空，避免名称被静默替换为 `�`。合法编码的字面 U+FFFD、中文、emoji 和内部 U+FEFF 保留；不按字符内容拒绝名称。直接 JS API 接收已解码的 String，原始字节验证属于 CLI IO 边界。

Node CLI 及两个 JS 适配入口可读取 UTF-8 或带单个 UTF-8 BOM 的库/请求文本。只处理整个输入文本最开头的 U+FEFF；内部名称、SDC 字符串中的字符和源文件字节保留。默认可选 JSON、显式检查和错误优先级不变，实际依赖仍为 MoonLiberty 0.4.1。物理带 BOM 的请求例程可直接运行：

```sh
node tools/sta.cjs --check-setup examples/sky130-demo.lib examples/setup-check-utf8bom.json
```

该例程退出 0、摘要为 Met；文件本身的 setup_summary:false 仍只在显式检查模式被请求为摘要。只处理首个文件签名，剩余非法内容仍由原解析器报告。

生成器可用 `--request-stdin` 传入现有 JSON 请求：库仍是文件，最后一个参数必须是 `-`。读取 UTF-8 至 EOF 后执行一次分析；接受单个初始 BOM，空输入、坏 JSON 或多个 JSON 文档报错。可与 `--check-setup` 组合，两个 flag 可交换顺序；检查退出码仍为 0/2/3/4。未指定此 flag 时，`-` 仍是普通文件名。

```sh
# Bash / cmd 重定向；普通分析可省略 --check-setup
node tools/sta.cjs --check-setup --request-stdin examples/sky130-demo.lib - < examples/setup-check-utf8bom.json
# Python 3 示例直接传原始字节，也适用于 PowerShell，不依赖 shell 编码设置
python examples/setup-check-stdin.py
```

示例等待生产者关闭标准输入（EOF），返回 Met 和退出 0；接入自己的生成器时传同一请求结构即可。

另有自编 `examples/chain.json`、`rca4.json`、`seq_path.json`、`four_paths.json`，以及同图 Verilog/SDC，便于复现。Sky130 文件是六类单元的真实 TT/25°C/1.80V 数据子集，**不是完整 PDK**。

## 公共 API

精确签名见 `pkg.generated.mbti`（`moon info --target all` 生成）。核心入口：

```moonbit
// 在导入本地 sta 与上游 liberty 的消费者中：
let library = @liberty.load_library(liberty_text)
let netlist = @sta.netlist_from_json(netlist_json)
let constraints = @sta.parse_sdc(sdc_text, library, netlist)
let report = @sta.STAEngine::new(library, netlist, constraints)
  .run_setup_analysis()
```

`Netlist` 的 `ports`、`gates`、`nets` 是已映射的标量结构；实例 connections 使用 cell 的原始 pin 名称。核心不解析完整 Verilog。`Net.wire_cap_farads`、结构化 Clock/PortValue 都使用 **秒/法拉**。JSON 请求结构为（direction 的规范写法为 input/output，也兼容 MoonBit Netlist.ToJson 派生的 Input/Output）：

```json
{
  "netlist": {
    "ports": [{"name":"a","net":"a","direction":"input"}],
    "gates": [],
    "nets": [{"name":"a","wire_cap_farads":0}]
  },
  "sdc": "...",
  "range_policy": "extrapolate"
}
```

该片段仅说明字段形状；完整可运行输入见 examples。`range_policy` 支持 `extrapolate`（默认）、`reject`、`clamp`。外推是上游端区间延拓，会返回诊断；不是切平面外推。NaN/Inf、坏坐标或缺模型不能静默绕过；有限输入若使最终派生 arrival/required/slack 溢出，返回明确错误，不输出 Infinity。仍可表示的大数继续支持。

`STAResult` 含：每 pin/edge 的 arrival、slew、driver net 总 load；每端点 required/slack/setup；最坏 slack；拓扑次序和诊断；带 pin/edge/单弧 delay 的 predecessor 路径。DFF launch 在非零 ideal latency 时先列出 CLK 的 `clock_latency` 步，再列 tCQ，使路径 delay 求和等于 arrival。JSON 的 Option 无值字段被省略，表示未约束，不是 0。`slew_contributor` 与 arrival path 分列，因为图分析分别合并最坏 slew 与最晚 arrival，不能把结果解释为精确相关的单路径波形。零 slew 仍记录真实贡献来源；NLDM 外推得到的负 slew 按物理下限取 0。`topological_order` 是按输出求值的实例序列，连续同名合并，交错时可重复实例名（如 pair→invert→pair）；按 pin/edge 查询节点。

## 报告中的 pin 标识

Netlist、SDC 和结构化约束始终使用原始名字。报告的 `NodeTiming.pin`、`EndpointTiming.pin`、`PathStep.pin` 和 `slew_contributor` 使用可逆的唯一标识：端口是一个转义分量，内部 pin 是 `E(instance)/E(pin)`；E 仅把 `~` 编为 `~0`、`/` 编为 `~1`，其余 Unicode 字符原样保留，不做规范化。分量规则来自 [RFC6901 §3](https://www.rfc-editor.org/rfc/rfc6901#section-3)，整体标识不是完整 JSON Pointer。

例如原始端口 `u/Y` 报为 `u~1Y`，实例 u 的输出 Y 报为 `u/Y`；原始 `u~1Y` 则报为 `u~01Y`。解码时先按分隔 `/` 拆分，再在各分量依次还原 `~1`、`~0`。普通不含 `~` 或 `/` 的名字保持原输出。`topological_order` 仍列原始实例名字。

## 明确模型

- 单库、单角、单理想时钟，数据图按寄存器切开，寄存器反馈合法；真实组合环报错。组合 DAG 以实际 timing arc 和驱动输出 pin 建立，支持同一多输出实例的通道交错求值。
- 集中负载 `Cwire + Σ Cpin(edge) + Cexternal(edge)`；优先使用 rise/fall capacitance，回退通用/声明的默认输入电容。R=0、net delay=0；无 SPEF、RC、OCV/PVT scaling。
- 正/反单调展开对应边沿；多条反向/同向弧分别处理，non_unate 保守展开两种输入沿。缺省 timing_sense 时按 output function 的信号极性推断；显式声明优先，混合极性/XOR、缺函数或无法解析时保守保留双沿。when 条件弧明确拒绝，不假装完成 case analysis。
- 单上升沿、无异步 set/reset 的 D/CLK/Q `ff`；支持真实 `sky130_fd_sc_hd__dfxtp_1` 的 rising_edge tCQ 和 setup_rising 数据/时钟 slew 约束表。setup 可为负数。传播与约束表可按单沿拆成 timing group；传播 delay/slew 仍须按沿配对，必要边沿的模型不能缺失。
- 默认不缩放 slew_derate；库声明值须为 1。同库输入/输出阈值必须具有一致定义；不实现跨库阈值换算。
- 四类路径 PI→PO、PI→D、Q→PO、Q→D；捕获 required = period + ideal latency − uncertainty − setup/output delay，数据 arrival 包含 launch latency 与 tCQ/input delay。
- 缺 I/O delay 的数据保留 unconstrained；缺输入 slew、缺弧、非法方向/连接、重复身份、多驱动、无驱动或负电容均报错。约束报告的负 slack 是结果，不是异常。

本期不承诺 hold、recovery/removal、latch、多时钟/异步域、generated/propagated clocks、条件逻辑求值、完整 SDC/Verilog、功耗或生产签核。

## Setup 周期预算

一次分析同时得到原时序结果、逐端点周期下界、限制沿及约束覆盖状态：

```moonbit
let analysis = @sta.STAEngine::new(library, netlist, constraints)
  .run_period_analysis()
let budget = analysis.budget
// analysis.timing 是原 STAResult；budget 的时间为秒，频率为 Hz。
```

Node 请求显式加 `"period_budget": true` 才在原 `result` 旁增加 `period_budget`；省略或 false 保持旧输出。可直接运行：

```sh
node tools/sta.cjs examples/sky130-demo.lib examples/period-budget.json
node tools/sta.cjs examples/sky130-demo.lib examples/period-budget-partial.json
```

完整示例的实际 setup 下界约 **0.487723672 ns**、模型内频率上限约 **2.050341325 GHz**；Partial 示例保留未约束沿，整体周期/频率无值。`endpoint_bounds` 的 `bound_seconds` 缺失表示该沿未约束；有值可以为负。`limiting_endpoints` 列出正最大下界的所有沿，pin 标识沿用上述转义规则。

| status | 整体结果 |
| --- | --- |
| Complete | 所有端点沿均约束，正周期下界与有限频率都有值 |
| Partial / Unconstrained | 部分或全部缺约束（也含没有端点），不给整体周期/频率 |
| NoPositiveLimit | 当前模型没有正的 setup 周期限制；下界0，频率无值，不代表可创建零周期时钟 |
| FrequencyOverflow | 周期下界仍是正有限数，倒数不可表示，频率无值 |

固定所有非周期参数的绝对值，仅改变 period；传播时保留共同时钟参考下的到达值，用于路径比较、slack 和预算，避免大共同 latency 淹没小数据延迟。绝对 arrival/required 仍按 Double 报告，发生舍入时不宜自行相减恢复 slack。由 `P >= arrival - latency + uncertainty + setup/output_delay` 直接计算下界，避免大基准 period 减 slack 的消减误差。最终下界非有限时显式报错，不能输出 Infinity。这是**现有单理想时钟 setup 模型**的下界，未包含 hold、器件最小脉宽/最小周期、RC/OCV 或签核保证；不处理随周期比例变化的外部约束。

required、稳定 slack 和周期下界中的三／四项有限约束先精确累加，再一次舍入到 Double，避免有符号约束相消丢失小量，也接受中间加减超范围但最终结果有限的输入。此处理仅限这些短约束表达式；逐弧传播仍使用 Double。相对 arrival 自身超范围时，slack 保留原绝对通道行为；周期下界合并 arrival、−latency、uncertainty 和 offset 后判断最终范围。

## Setup 违例摘要

已有报告可调用 `report.setup_summary()`，直接从端点 slack 派生摘要，无需再次传播或读取库。返回 `SetupSummary`：端点数（按报告 pin 身份去重）、已约束/未约束沿数、违例沿数、违例端点数、最坏 slack 与 WNS。一个端点的 rise/fall 都负时，计两个违例沿、一个违例端点；别名输出端口各自是独立端点。负值严格 `< 0`，零不算违例；WNS 为 `min(0, worst_slack)`，没有已知 slack 时无值。公开手工构造的报告若含非有限 slack，此方法用现有 `STAError` 拒绝。

| status | 含义 |
| --- | --- |
| Met | 非空端点沿全部有已知 slack，且没有负值 |
| Violated | 至少一个已知负 slack；仍需查看未约束沿计数 |
| PartialCoverage | 有已知 slack、没有负值，同时仍有未知沿 |
| NoCoverage | 端点存在，但所有沿的 slack 未知 |
| NoEndpoints | 没有端点，不能视作 setup 已通过 |

JSON 请求可加 `"setup_summary":true`，在原 `result` 旁添加 `setup_summary`；缺省或 false 不添加字段，坏类型报错。可以与 `"period_budget":true` 组合，两者共享同一次时序结果。无值字段在 JSON 中省略。默认调用成功分析即使摘要为 Violated 仍退出 0；自动化调用者可读取 status/覆盖计数，或使用下文显式 CLI 检查模式。

```sh
node tools/sta.cjs examples/sky130-demo.lib examples/setup-summary.json
node tools/sta.cjs examples/sky130-demo.lib examples/setup-summary-partial.json
```

第一个例程有 3 个输出端点、6 个已约束沿、3 个违例沿与 2 个违例端点，WNS 约 −0.2ns；第二个仅 rise 有约束且 slack 为正，状态为 PartialCoverage。摘要只描述现有受限 setup 模型的端点记录。

## CLI setup 检查

显式开启 `--check-setup` 可用于 CI：只有摘要为 Met 才通过。完整 JSON 仍输出到 stdout，WNS、端点/沿计数与原时序结果保持原含义。

| 退出码 | 检查模式含义 |
| --- | --- |
| 0 | Met |
| 3 | Violated，包括已有违例但另有未知沿 |
| 4 | PartialCoverage、NoCoverage 或 NoEndpoints |
| 2 | 参数、读取、JSON、分析或报告写入错误 |

```sh
# 退出 0；请求文件无需预先开启 setup_summary
node tools/sta.cjs --check-setup examples/sky130-demo.lib examples/setup-check-met.json
# 退出 3；JSON 中仍有完整报告与违例摘要
node tools/sta.cjs --check-setup examples/sky130-demo.lib examples/setup-summary.json
# 退出 4；覆盖不足不能当作通过
node tools/sta.cjs --check-setup examples/sky130-demo.lib examples/setup-summary-partial.json
```

flag 放在两个文件路径之前。检查模式在 MoonBit JS 适配层请求现有摘要：缺省或合法 false 都强制为 true，不改写原文件；坏类型仍由原核心报错。可选 period_budget 不变。旧双路径调用与普通 JS 导出 `analyze_json` 保持原行为；两个路径参数中即使库的字面文件名是 `--check-setup`，也仍按旧模式读取。检查只判断现有受限 setup 模型的摘要。

## 受限 SDC profile

这是逐行读取的数据 profile，**不执行 Tcl**。数值按库 `time_unit` 和 `capacitive_load_unit` 转成 SI。先创建一个真实输入端口时钟，`-name` 与正 `-period` 必填；可选 `-waveform {0 T/2}`。对象仅 `[get_ports exact_name]`、列表 `{a b}`、或 `*`（筛选适用输入/输出且不含 clock）；时钟对象仅 `[get_clocks exact_clock_name]`。

| 命令 | 支持选项 |
| --- | --- |
| create_clock | -name、-period、可选 -waveform |
| set_input_delay / set_output_delay | -clock 必填；-max、-rise、-fall |
| set_input_transition | -rise、-fall |
| set_load | 输出端口外部总电容，无其他 flag；net wire cap 在 Netlist |
| set_clock_transition | -rise、-fall |
| set_clock_latency | 共同 ideal latency，允许有限负值，无其他 flag |
| set_clock_uncertainty | -setup |

无边沿 flag 表示两沿；同字段重复命令覆盖，其他边沿保留。允许整行注释及空白后、分组外的行尾 `#` 注释；名称词中的 `#` 和选择器列表内的 `#` 保留为名称，例如 `[get_ports {a#b}]`、`[get_ports {#data}]`、`[get_clocks core#clk]`。含方括号的独立标量名称需放在花括号中，例如 `[get_ports {data[0]}]`、`[get_ports {data[0] data[1]}]`；花括号内的方括号按名称字符保留，不作嵌套命令解释。此处没有向量声明、位展开或总线运算。这是受限 profile 的名称/注释规则，不执行完整 Tcl。允许空白，不允许变量、引号、续行、分号脚本和嵌套命令。未知命令/flag、-min、-add_delay、第二时钟、错误对象、空选择器、错误方向都拒绝；create_clock 在解析时检查真实输入端口与非空 plain name。未设置 clock slew 为 0 并按选定范围策略查询；实际例子显式给出 clock/input slew。

## 验证

历史基线的 13 个 MoonBit 黑盒测试涵盖真实顺序路径、时钟/不确定度、SI 负载、反相边沿、unconstrained、寄存器反馈、真实组合环、结构/数值错误、SDC 拒绝/覆盖、JSON 错误和外推策略；JS、Wasm-GC 与 native 的实际结果见 `VALIDATION.md`。

历史基线：独立 Ubuntu OpenSTA **2.0.17**（2019 c018cb2 系列、官方 Ubuntu 二进制包）与 JS 导出消费者，在 8 个共享输入案例上比较 **680 个** AT/slew/端点 required/slack 字段，实测最大绝对误差 **0.000164685 ps**，小于 1 ps 候选模型预算。三种组合图、线电容、正负 slack、真实 DFF 及四类路径均包含在内。此结果只属于这组固定库/图模型，不能外推任意 PDK/复杂寄生或所有商业电路。关键路径对照限已报告最坏端点/沿，未声称穷举所有路径。

2026-10-28 深入修复新增 7 项回归，第 05 轮共 20 项，JS、Wasm-GC、native 均通过。新增 8 组真实 OpenSTA 对照比较 314 个数值字段，最大差约 0.000164146 ps；另核 16 条 DFF 路径求和、36 项时间/电容单位缩放关系，以及 arrival/slew 来源分离、负 setup/交换变量轴、负 latency、端口别名和半沿未约束。未约束沿的 required 按显式输出约束独立断言，OpenSTA 该沿不生成 clocked required。详见 VALIDATION.md。

第 06 轮补齐缺省 timing_sense 的单调方向、单沿 timing group 与零 slew 来源。新增 6 项黑盒，第 06 轮 JS/Wasm-GC/native 各 26/26；新增 8 组真实消费者/OpenSTA 对照共 216 字段，最大差 0.000164685 ps。两项保守双沿控制和破损表错误路径一并核验；第 03/05 轮集合未重复运行或计数。

第 07 轮修复多输出合法图被实例级依赖误判为组合环，并按输出依赖执行、完整记录每个 pin。新增 4 项回归，JS/Wasm-GC/native 各 30/30；4 组自编标量/1D 模型经实际 Node 消费者与 OpenSTA 对照 128 字段，最大差 0.000081062 ps，另有 8 项手算到达值检查。真实输出回路仍拒绝；表查找算法未改。

第 08 轮修复报告名称拼接冲突，保留所有合法原始输入；新增 4 项回归，JS/Wasm-GC/native 各 34/34。4 组实际 Node 消费者检查唯一身份和路径/贡献引用，另核 6 项手算到达值及 82 项 DFF 重命名数值不变性；Unicode-only 控制 before 已通过。未改时序算术或重跑旧 OpenSTA 集合。

第 09 轮增加周期预算和原生 Netlist JSON 往返兼容。第 09 轮 43 项黑盒在 JS/Wasm-GC/native 均通过；两套模型在预测下界±1ps与边界的 6 次实际 OpenSTA 重算比较 180 字段，最大差 0.000066543 ps，边界/符号和预算不随目标周期变化的断言通过。另以原生枚举 JSON 的 44 字段对照验证参考 writer 兼容。详见 VALIDATION.md 与 SOURCES.md。

第 10 轮修复共同时间平移下的路径/slack/周期预算消减错误。新增 5 项回归，JS/Wasm-GC/native 各 48/48；6 个实际消费者输入在原样 before/after 对照，等价零偏移 OpenSTA 的 3 个目标周期比较 84 字段，并独立核 6 个大偏移 slack。公开 API 不变，原有限大数范围保留。

第 11 轮修复有符号约束短和中的相消及中间溢出：新增 4 项黑盒和 1 项含 384 组独立有理数预期的白盒，JS/Wasm-GC/native 各 53/53（52 项黑盒＋1 项白盒）。12 次实际 Node 消费覆盖 4 个原样 before/after 反例、相消/近相消下界±1ps、3 种真正最终溢出及真实 Sky130 DFF；60 个约束数值字段精确匹配一次舍入的有理数预期。该核对检查约束算术，不作为新增 NLDM/物理模型精度成绩。公开 API/Double 字段不变，历史 OpenSTA 集合未重跑。

第 12 轮修复 SDC 选择器二次分词误把 `#` 当注释、静默截短名称的问题。新增 3 项回归在 JS/Wasm-GC/native 各 3/3；JS 的相关既有 SDC 4/4、名称 4/4。4 个原样 before/after Node 输入中，3 个反例修复，已有注释控制保持正确；20 个直连网表数值字段按独立 SI 手算通过。未执行本轮完整 root 套件，不把历史 53/53 宣称为新 56 项全套成绩。可运行 `node tools/sta.cjs examples/sky130-demo.lib examples/hash-names.json` 查看精确名称绑定。

第 13 轮修复花括号内标量位名称的方括号被误判为嵌套命令。新增 2 项在 JS/Wasm-GC/native 各 2/2；JS 相关既有 SDC 4/4、上轮 hash 名称 3/3。3 组原样消费者位名场景按独立直连公式核 15 个数值字段，另 1 组真正嵌套命令保持拒绝。未重跑完整 root 或旧数值集合。可运行 `node tools/sta.cjs examples/sky130-demo.lib examples/scalar-bit-names.json` 查看标量位名称列表的精确绑定。

第 14 轮为 CLI 文件入口有限审查，未发现新缺陷，运行时代码未改。4 次实际调用覆盖外部工作目录下的中文/空格/Unicode 相对路径、缺 Liberty 文件、缺请求文件和坏 JSON。成功报告与第 11 轮封存报告整体等价，输入字节 SHA 一致；3 个错误按既有输出/退出契约通过。仅更新入口说明与回执，未重复编译或执行无关的核心数值测试，四个实际 release 产物身份保持。

第 15 轮先研究违例摘要与 SDC 位置诊断两个候选，选择实现可选 setup 摘要。新增 5 项在 JS/Wasm-GC/native 各 5/5，相关既有 JSON/周期预算 JSON 回归共 2/2；10 次实际消费者验证 7 个摘要场景的 56 项状态/计数/值字段检查，以及缺省/false/坏 flag。原 result 和 period_budget 与同输入拓展前逐字段一致。原 API 声明保留，新增 enum/struct/报告方法；未重跑完整 root、OpenSTA 或旧 I/O/数值集合。

第 16 轮增加显式 CI setup 检查，核心 29 个公开声明与摘要/WNS 算法未改，普通 JSON/CLI 模式保留。13 次真实 CLI 调用验证退出 0/2/3/4、10 份完整输出等价、缺省/false 自动摘要、非法类型及 JSON、字面 flag 文件名与 Unicode/非零电容保真。只检查并构建新增 JS 适配层，未重跑第 15 轮已冻结的三端测试或旧消费者集合。

第 19 轮在 Node/JS 输入边界补齐单个 UTF-8 BOM 兼容，不修改核心解析器或依赖版本。11 个新的编码场景通过，8 份完整输出与冻结报告/明确名称变换一致；包含普通与检查模式、库/请求组合、内部 U+FEFF 保真、部分覆盖及错误控制。root 29 声明和两个 JS 签名保留，只构建相关 JS 适配；旧核心/门禁/错误序列/大流式集合未重跑。

第 20 轮增加显式请求 stdin 输入，沿用同一 JSON/UTF-8/检查链。14 个真实消费者通过，9 份完整报告与冻结输出一致；含分段 BOM/内部 U+FEFF、EOF、退出 0/2/3/4、坏输入和旧字面文件名控制。运行时代码只改 Node IO 入口，MoonBit 核心/接口与四个编译产物保持；未重跑旧数值集合。

安装独立 OpenSTA 2.0.17 后，可复现仓库内自编例子（先按上述命令构建 JS）：

```sh
python3 tools/verify-opensta.py --sta /path/to/sta --request examples/four_paths.json
```

结果和原始报告写到 `_build/oracle/`；该工具只做输入序列化、调用和逐字段比较，无 STA 参考算法副本。脚本适配已验证的 2.0.17 probing 接口；新版本需按其 API 调整，不能把报错/空报告当通过。

完整本轮命令、首次失败、原始报告、c17 本地来源和差分详单在执行回执目录。c17 原文件分发条款未确认，因此没有随产品分发该图；其本地差分照实保留。代码/数据/参考许可详见 `SOURCES.md`、`NOTICE` 与 examples 中独立数据许可证。

## GitHub Actions

[CI 工作流](https://github.com/yesuifengliu01/moonbit-liberty/actions/workflows/ci.yml)使用普通 Ubuntu 24.04 runner，固定 MoonBit `0.10.13+cbb11c36f`、对应 core 及 Node `24.11.0`。SDK/core 官方下载地址与 SHA256 在 `tools/ci-toolchain.json`，Actions 引用也固定到提交。

工作流执行全目标 check、格式检查、JS/Wasm-GC/native 测试及 release 构建，再以 `python3 tools/ci-consumers.py` 启动真实 CLI 验证示例、普通/检查退出码、BOM stdin、输入错误及关闭报告接收端。消费者的状态、计数与裕量预期来自示例直连约束，失败会使 job 失败；报告保存在 `_build/ci-consumers.json`。这不替代完整时序签核或历史外部 OpenSTA 对照。

`tools/bootstrap-ci.py`只把官方 SDK 安装到显式指定的新目录并验证归档 SHA，不覆盖已有 SDK。CI 在 runner 临时目录安装；已有本机工具链可直接运行以上常规命令。
