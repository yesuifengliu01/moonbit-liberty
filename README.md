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

Node 分析 CLI 及两个分析 JS 适配入口可读取 UTF-8 或带单个 UTF-8 BOM 的库/请求文本。只处理整个输入文本最开头的 U+FEFF；内部名称、SDC 字符串中的字符和源文件字节保留。默认可选 JSON、显式检查和错误优先级不变，实际依赖仍为 MoonLiberty 0.4.1。物理带 BOM 的请求例程可直接运行：

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

## Netlist JSON 字段路径诊断

`netlist_from_json` 保留原 `STAError`。可选的 `netlist_from_json_with_diagnostics(value)` 解析相同结构与数值，失败时抛出 `NetlistJsonDiagnostic(original_error, pointer)`，便于在多个 ports/gates/connections 对象中定位缺失或类型错误。它不修改传入的 Json。

`pointer` 是相对于独立 Netlist 根的 [JSON Pointer](https://www.rfc-editor.org/rfc/rfc6901)：空字符串表示根，数组下标是 **0-based 元素下标**。例如 `/gates/1/connections/1/net` 指第二个单元的第二条连接的 `net`；它不是行列、字节或 UTF-16 offset。缺失字段指向预期的子字段；应为对象但实际为其他类型时指向该值本身。路径只遍历已有的 ASCII schema 键，Unicode 名称/值不作为路径片段，未知键（包括 Unicode、`/`、`~`）仍忽略。

首错沿用原解码顺序，不按 JSON 对象键的书写顺序排序：先 ports，再 gates，再 nets；数组从 0 递增。端口先 direction，再 name/net；单元先 connections（每项先 pin 再 net），再 name/cell；net 先 wire_cap_farads，再 name。输入/输出方向仍接受 input/Input/output/Output，数值类型接受政策和空数组政策保持原样。

```sh
moon build --target js --release
node tools/check-netlist.cjs --help
# 退出 0；含多个对象、Unicode 名称和未知扩展键的合法结构
node tools/check-netlist.cjs examples/netlist-diagnostic-valid.json
# 退出 2；保留 JSON string required，pointer 为 /gates/1/connections/1/net
node tools/check-netlist.cjs examples/netlist-diagnostic-error.json
```

独立 JSON schema 为 `moonbit.sta.netlist.v1`：成功返回 `ok:true`；失败返回 `ok:false`、原 `error` 和 `pointer`。无可解码语义位置的 JSON 语法错误使用 `pointer:null`，已解码但类型错误的根使用 `pointer:""`。核心 `check_netlist_json(text)` 和同名 JS 导出提供此边界；JS/文件入口允许单个首 BOM，文件须为合法 UTF-8，源字节不改写。文件/编码/输出错误写入 stderr 并退出 2，`--help` 无需构建。

此检查只解码已有 Netlist 结构，不执行图、驱动、引脚/库匹配、数值范围或时序分析；例如负线电容仍能被结构解码，后续 STA 保留原来的数值校验。原分析 API、默认错误 JSON、SDC 诊断及所有时序结果合同不变。

## 未约束端点的因果见证

原报告已经能按 pin/edge 定位未知 slack，也能区分 arrival 和 required 缺失。需要解释缺失 arrival 的上游来源时，可选调用 `engine.run_setup_with_constraint_context()`：在同一次 setup 传播中返回原 `timing` 和 `constraint_context`，不改变默认分析、摘要、周期预算、JSON 或错误合同。

每个原有未知 slack 端点边沿最多带一条 `launch_witness`：原始输入端口 `port`、既有转义报告身份 `pin`、源 `edge`、实际接受的 net/时序弧路径。`MissingInputDelay` 表示该输入边沿未设 delay；`IdealClockNoDataArrival` 表示理想 clock 端口本来不作为数据 arrival，不能据此给 clock 添加被禁止的 input delay。DFF 的 Q 从时钟发射，切断 D 的缺失来源。缺少输出 delay 的端口另以原始名 `missing_output_delay_port` 标出，两类原因可同时存在。

见证的 `path` 不伪造 arrival：source 步没有 `delay_seconds`，net 步按现有模型为 0，时序弧步保留本次已查表的延迟，单位为秒。它按引擎既有接受弧/相关输入/边沿顺序选择一条缺失来源，不是最坏时序路径、全部缺失输入清单或完整路径覆盖认证。若另一路已有 arrival，保持原端点覆盖规则，不把该端点重新归类为未覆盖。

```sh
moon build --target js --release
node tools/constraint-context.cjs --help
node tools/constraint-context.cjs examples/constraint-context.lib examples/constraint-context-netlist.json examples/constraint-context-partial.sdc
node tools/constraint-context.cjs examples/constraint-context.lib examples/constraint-context-netlist.json examples/constraint-context-complete.sdc
```

自编常数 1D 反相器例子中，partial 输出 `out~1~0😀/Rise` 追到输入 `a~1~0😀/Fall`，经 `inv~1~0😀/A`、`inv~1~0😀/Y` 的 0.2ns 反相弧；直连 `alias~1#/Fall` 还缺自身的 output delay。完整对照输入为 0.6ns、反相器 arrival 为 0.8ns、required 为 1.8ns、slack 为 1.0ns，context 为空。该合成数据只用于手算验证，来源见 SOURCES。

独立三文本核心/JS 入口 `analyze_constraint_context_json(library, netlist, sdc)` 使用默认 Extrapolate，返回 `moonbit.sta.constraint-context.v1`，包含原 `result`、原方法派生的 `setup_summary` 和 `constraint_context`。网表是独立 Netlist JSON，SDC 保持原文；库/网表文件允许单个首 BOM，所有文件须为 UTF-8，文件不改写。它不接收旧 request flags 或计算周期预算；原入口继续提供那些能力。

文件工具退出 0 表示分析完成，包含 PartialCoverage 或负 slack 的情况；输入/分析/输出错误退出 2，主机 IO/编码诊断写 stderr。`--help` 无需构建。这是对现有受限模型报告的因果解释，不是时序闭合、所有路径约束完整或生产签核保证。

## 指定发射端与捕获端的路径查询

全局报告只保存每个节点的一条最晚 arrival 路径。指定来源在汇合处落选时，筛选原 `path` 找不回它的后续弧。可选入口在同次原分析中保留所有实际接受弧已算出的延迟，再沿原输出 DAG 查询一个精确来源：

```moonbit
let query : @sta.PathQuery = {
  launch: InputPort("b", Rise),
  capture: OutputPort("out", Rise),
}
let analysis = engine.run_setup_path_query(query)
// analysis.timing 是原全局报告；analysis.path_query 是指定来源的结果。
```

`PathLaunch` 是 `InputPort(raw_name, edge)` 或 `RegisterQ(raw_instance, raw_pin, edge)`；`PathCapture` 是 `OutputPort(raw_name, edge)` 或 `RegisterD(raw_instance, raw_pin, edge)`。寄存器点必须是已支持 ff 的真实 Q/D。原始分量按字面精确匹配，不展开通配符，输出的 launch/capture/path pin 沿用原可逆报告身份。

```sh
node tools/path-query.cjs examples/path-query.lib examples/path-query-netlist.json examples/path-query.sdc examples/path-query.json
node tools/path-query.cjs examples/path-query-changed.lib examples/path-query-netlist.json examples/path-query.sdc examples/path-query.json
```

查询 JSON 为 `{"from":{"kind":"input_port","name":"b","edge":"rise"},"to":{"kind":"output_port","name":"out","edge":"rise"}}`。寄存器 kind 分别是 `register_q` / `register_d`，用 `instance`、`pin` 代替 `name`；edge 只接受 `rise` / `fall`。顶层可选 `range_policy` 沿用 `extrapolate`（默认）/`reject`/`clamp`。

示例中 A 以1ns发射，经过0.2+0.3ns，全局 arrival1.5ns、slack0.3ns；B 以0.1ns发射，经过0.4+0.3ns，查询 arrival0.8ns、required1.8ns、slack1ns。第二个库仅把落选 B 弧改为0.6ns，原完整报告相同，查询 arrival 变为1ns、slack0.8ns。输入与逐步独立期望见 `examples/path-query-cases.json`。

四文本核心/JS 入口 `analyze_path_query_json(library, netlist, sdc, query)` 返回独立 `moonbit.sta.path-query.v1`，包含原 `result` 与 `path_query`。查询结果明确使用 `queried_arrival_seconds`、`queried_slack_seconds`，还有 `required_seconds`、身份和一条 owned `path`；全为秒，未知数值省略。

| status | 含义 |
| --- | --- |
| Found | 实际接受的边沿路径存在且发射 arrival 已知；缺捕获约束时 required/slack 仍省略 |
| NoPath | 两个合法查询点之间不存在该边沿数据路径；path为空，无数值查询字段 |
| UnconstrainedLaunch | 路径存在但发射 arrival 未知；path为空，无数值查询字段 |

新 JSON 边界先解析 Netlist、库、SDC，再解析 query 形状/范围策略；typed 引擎先完成原 setup 分析，再按 launch、capture 顺序验证点，最后判可达性。不可达优先 NoPath，可达且 launch 未知才是 UnconstrainedLaunch。坏原输入与非法查询是错误。三种有效状态均退出0，包括负查询 slack；参数/编码/IO/分析/查询/输出失败退出2。`--help` 无需构建或输入。文件入口严格 UTF-8，库/网表/query 允许单个首 BOM，SDC 保持原文，源文件不改写，相对路径以调用者 cwd 为准。

每条弧权使用完整原设计的 GBA worst-slew 和实际负载，捕获 setup 也沿用原分析；不沿指定路径重算 slew/load。Q 使用原 clock-latency/tCQ 前缀独立发射，数据图没有 D→Q 边。查询 slack 不能当全局 WNS或签核结论。同值沿用原 timing-group/related-pin/edge 遍历顺序取一条；不支持 all paths/top-K、through、批量、内部端点、路径异常或新的时序模型。默认报告、诊断、数学和原可选入口保持。

`examples/path_query_receiver` 是单独编译、只调用公开 typed API 的自编消费包；`python3 tools/ci-path-query.py` 从其他 cwd 用真实四文件调用并核对冻结的完整路径/时间/状态，保留原始 stdout/stderr。它们属于自编集成验证，不代表第三方采用。

## 映射设计的 pin 电气上限

Setup Met 和查表坐标合法并不等于满足库里声明的 pin 上限。可选 `engine.run_pin_limit_analysis()` 先运行原 setup，再用原完整设计的每 pin/edge slew 和输出 driver load 检查：

- 实例输出 pin 的简单标量 `max_capacitance`，按库电容单位转法拉。
- 实例输入/输出 pin 的简单标量 `max_transition`，缺失时用库级 `default_max_transition`，按时间单位转秒；包括已支持 FF 的 CLK/D/Q。

```sh
# 相同原始 timing：严格库报告4项超限，放宽声明的库为Met
node tools/check-pin-limits.cjs --range-policy reject examples/pin-limits.lib examples/pin-limits-netlist.json examples/pin-limits.sdc
node tools/check-pin-limits.cjs --range-policy reject examples/pin-limits-met.lib examples/pin-limits-netlist.json examples/pin-limits.sdc
# 自编映射设计使用现有真实Sky130子集；保留原Extrapolate诊断
node tools/check-pin-limits.cjs examples/sky130-demo.lib examples/pin-limits-real-netlist.json examples/pin-limits-real.sdc
```

严格例的源输出负载是 wire0.25pF + 后级输入0.25/0.5pF + alias外部负载0.5pF，得到rise1pF/fall1.25pF；上限1pF，rise等于上限仍满足。加上三项 transition 超限，共4项。两套声明的完整原 timing 一样且 setup Met，所有 NLDM 坐标在网格内。实库例负载0.2pF高于声明0.181284pF，也超过实际 timing 网格，所以使用原外推策略；还报告 Rise slew 超限，共3项，不作为网格内证明或新精度验证。

返回 `PinLimitAnalysis { timing, pin_limits }`。`pin_limits.checks` 是 owned 的完整规则/pin/edge列表，按实例、库pin次序、输出电容/transition、Rise/Fall排列。每项含原始 instance/cell/library_pin、原转义报告 pin、edge/kind/unit、`actual_si`、可选 `limit_si`/`margin_si`，以及声明来源、属性名、解码后的值文本和问题。`margin = limit - actual`，严格 `actual > limit` 才超限。输出电容使用原网表全负载；Clamp 仅作用查表坐标，不改变这里报告的物理负载。未知数据 arrival 不妨碍已有 slew/load 检查。

| 每项 status | 含义 |
| --- | --- |
| Satisfied / Exceeded | 有可表示的非负 SI 上限，分别为满足/超限 |
| NotSpecified | 没有适用声明；不补0 |
| InvalidLimit | 已存在但无效、转换不可表示或形式不受支持；bound/margin省略，原timing保留 |

显式 pin 声明（含0或无效值）优先于库默认，不因无效而偷偷回退。原解析/分析已经拒绝的输入仍给原错误；旧分析接受的负上限等元数据由新报告标记 InvalidLimit，原 API 接受行为保持。没有库默认电容的推断。复杂/分组形式会明确标记不支持。

总计按规则/pin/edge记录为 `checked_rules`、`violated_rules`、`unspecified_rules`、`invalid_rules`。JSON 总状态优先 Violated，其次 InvalidLimits，再是 NoDeclaredLimits，否则 Met；Met只表示所有适用且已声明的支持规则满足，不保证每个pin有上限或签核通过。typed 总状态构造名为 `LimitsMet` / `LimitsViolated` / `InvalidLimits` / `NoDeclaredLimits`，避免影响旧 SetupSummary 的名字；JSON名称仍为 Met/Violated。

公共核心/JS `analyze_pin_limits_json(library, netlist, sdc, range_policy)` 接收四个 String，最后一项明确为 `extrapolate` / `reject` / `clamp`，输出 `moonbit.sta.pin-limits.v1`，含完整原 `result` 与 `pin_limits`。文件工具只读三个 UTF-8文件，`--range-policy` 默认 extrapolate，库/网表允许单首 BOM，SDC保持原文。有效报告始终 `ok:true`；checker退出码0 Met、3 Violated、4 InvalidLimits/NoDeclaredLimits、2参数/编码/IO/原分析/输出错误，stdout失败覆盖为2。`--help`无须构建。

不检查端口/SDC设计规则覆盖、最小值、fanout、动态/table上限或其他pin角色；不重算 slew/load、改变时序科学模型或声称 OpenSTA 等价。`examples/pin_limit_receiver` 与 `tools/ci-pin-limits.py` 分别执行公开 typed 包和任意三文件接收链，按 `examples/pin-limit-cases.json` 的完整冻结行核对结果；属于自编集成验证。

## 映射实例用量与声明面积

只有 Liberty 和已映射标量 Netlist JSON，也可以先统计设计资源：

```sh
moon build --target js --release
node tools/cell-usage.cjs examples/cell-usage.lib examples/cell-usage-netlist.json
```

示例不含时间/电容单位、时序表或 SDC；两个 BUF 的声明面积各为1.25，一个名为 DFF 的合成单元为2.5，结果为3个实例、2种已用单元、总面积5。库里未使用的面积100单元不计入。该合成 DFF 仅是单元名称；真实 Sky130 INV/NAND/DFF 的声明字段另在冻结案例中核对，不将这些计数样例当成完整连接/触发器验证。

公共 typed 入口 `analyze_cell_usage(library, netlist)` 返回 `CellUsageReport`；直接接受现有 `Library` / `Netlist`，不需要 `STAEngine`、约束或 GBA。只要求实例名非空且唯一；不检查连接、pin 角色、驱动或图合法性。所有 flat gates 均计入，端口别名和未用库单元不增加实例；按现有 `Library.cell` 的精确原名、首个匹配绑定。`instances` 按输入次序保留 index/原始 instance/cell，`cells` 按首次使用次序给直方图与面积贡献；这些数组为 owned。

每行面积状态为 `KnownArea`、`MissingArea`、`InvalidArea` 或 `UnmappedCell`，保留可用的解码 `raw_area`、数值和问题原因。数值来自公开 `Cell.area`；简单、有限、非负值有效，包括零；缺声明、负数、非数字或 complex/group 声明不猜值。程序构造的 Library 同样使用公开数值字段，源文本只提供声明解释。`unit` 固定为 `liberty_declared_area`，不转换成物理平方微米。

`known_area_subtotal` 是各已知单元面积乘实例数后的有限小计；任一分组乘积或小计溢出则省略，并置 `area_overflow`。只有全部实例已映射且面积有效、聚合有限时，`status=Complete` 且给出 `total_declared_area`；否则为 `Incomplete`，省略总面积。空设计 Complete、总面积0。Complete 只说明面积覆盖，不证明连接正确、物理 PPA 或时序签核。

核心与 JS `analyze_cell_usage_json(library, netlist)` 输出独立 `moonbit.sta.cell-usage.v1`，含 `ok` 和 `usage`（输入错误则为 `error`）。两文件工具使用严格 UTF-8，库和网表各允许单首 BOM，按调用者 cwd 解释路径，不重写源文件。退出0 Complete、4 Incomplete（含溢出）、2参数/编码/IO/解析/身份/输出错误；`--help` 无须构建。

固定上游0.4.1会丢失引号单元名中的非BMP字符，例如 `"BUF/~😀"` 变为 `BUF/~`。本工具按实际 Library 模型绑定，不会偷偷修名；裸标识 `BUF/~😀` 保真。该上游限制保留在原样输入案例中，报告 UnmappedCell；未修解析器或更换依赖。

`examples/cell-usage-cases.json` 固定21例的完整期望；初始20例的面积/计数预期保留，主例将同名单元改用合法裸标识，并额外保留原样引号输入的明确未映射期望。`examples/cell_usage_receiver` 通过独立包实际调用 typed API，`python3 tools/ci-cell-usage.py` 从其他 cwd 运行两文件接收，并保存实际测试副本和原始 stdout/stderr。它们是自编集成验证，不代表第三方采用。局部验证与必需的完整 CI 范围见 [CI-PLAN.md](CI-PLAN.md)。

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

### SDC 源位置诊断与文件检查

`parse_sdc` 继续抛出原 `STAError`。需要在较长文件中定位失败命令时，新增的 `parse_sdc_with_diagnostics(text, library, netlist)` 抛出 `SdcDiagnostic(original_error, position)`，保留原错误类别、消息和优先级；合法输入得到相同 `TimingConstraints`。

`position` 是失败命令的起点，**不是坏 token 的精确范围**。`line`、`column` 从 1 开始，`offset` 从 0 开始；列与 offset 都按原始 MoonBit/JavaScript String 的 **UTF-16 code unit** 计数。LF 开始新行，CRLF 占两个 offset 单位，tab 占一列，补充平面字符占两个单位，不按终端视觉宽度计算。行内分词/分组、未知命令/flag、数值、选择器及端口绑定错误均指向该命令；文本预算、库前置校验、缺少 clock 等没有具体失败命令的错误位置为 `None`。源文本不做换行、Unicode 或 BOM 归一化。

独立文件消费者读取 Liberty、一个包含 `ports/gates/nets` 的独立网表 JSON 对象及原始 SDC 文件：

```sh
moon build --target js --release
node tools/check-sdc.cjs --help
# 故意含不支持的 -min：退出 2，位置为 line6/column3/offset115
node tools/check-sdc.cjs examples/sky130-demo.lib examples/sdc-diagnostic-netlist.json examples/sdc-diagnostic-error.sdc
```

输出采用独立 `moonbit.sta.sdc.v1` JSON schema。有效约束退出 0 并返回 `constraints`；SDC/JSON/库错误退出 2 并返回原 `error` 和 `position`（无位置时为 `null`）。文件/编码/输出错误退出 2，诊断写入 stderr。输入须为合法 UTF-8；库和网表允许单个首 BOM，SDC 原文完整保留。`--help` 无需构建。JS 导出 `check_sdc_json(library, netlist, sdc)` 提供同一边界。

此入口仅做已有受限 SDC 的解析和约束绑定，不执行时序分析、完整网表图校验或 Tcl；它的通过不代表完整 STA 能运行或时序满足。原 `analyze_json`、`tools/sta.cjs` 及其默认错误 JSON 保持原合同。

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

工作流执行全目标 check、格式检查、JS/Wasm-GC/native 测试及 release 构建，再以 `python3 tools/ci-consumers.py` 启动真实 CLI 验证示例、普通/检查退出码、BOM stdin、输入错误及关闭报告接收端。另运行 `python3 tools/ci-sdc-diagnostics.py`、`python3 tools/ci-netlist-diagnostics.py` 和 `python3 tools/ci-constraint-context.py`，验证 SDC 命令起点、Netlist 语义路径、缺失 launch 的因果见证及真实文件/API 消费。位置、路径和常数弧 SI 预期独立手工确定，原状态、计数与裕量预期来自示例直连约束；失败会使 job 失败，报告保存在 `_build/ci-*.json`。这不替代完整时序签核或历史外部 OpenSTA 对照。

另有 `python3 tools/ci-cell-usage.py` 门禁，逐字段核对无时序配置的完整面积/计数报告和缺失、溢出、输入/输出错误，通过独立公开包和两文件工具实际接收。执行范围与历史科学对照的边界见 [CI-PLAN.md](CI-PLAN.md)。

`tools/bootstrap-ci.py`只把官方 SDK 安装到显式指定的新目录并验证归档 SHA，不覆盖已有 SDK。CI 在 runner 临时目录安装；已有本机工具链可直接运行以上常规命令。
