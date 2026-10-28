# 本地验证记录

日期：2026-10-28（Asia/Tokyo）。这些是本地实现证据，不是组委会/工艺厂验收。

环境：WSL Ubuntu，MoonBit moonc 0.10.13+cbb11c36f（2026-09-15）、moon/moonrun 0.1.20260915；依赖 SongYZZZ/moon-liberty 0.4.1 实际下载/解析成功。参考为 Ubuntu 官方 opensta 0~20191111gitc018cb2+dfsg-1.1，`sta -version` 为 2.0.17，包 SHA256 见 SOURCES。

以下表格与 680 字段为 implementation-03 历史基线，未在深入修复轮重跑或重复计数。

| 实际操作 | 结果 |
| --- | --- |
| moon check --target all --deny-warn | 通过 |
| moon build --target all --release --deny-warn | 修正导出包布局后通过；覆盖 wasm/wasm-gc/js/native |
| moon test --target js --deny-warn | 13/13 |
| moon test --target wasm-gc --deny-warn | 13/13 |
| moon test --target native --deny-warn | 13/13 |
| moon info --target all | 成功生成根公共接口；仅 JS 的导出适配包与 canonical Wasm 无接口的差异是预期后端限制 |
| moon run --target native --release cmd/main | 真正运行顺序例子，JSON ok=true |
| moon run --target wasm-gc --release cmd/main | 同一顺序例子实际运行，JSON ok=true |
| Node 导出消费者 | 真实读取库/请求文件、调用编译后的 js 包 |
| tools/verify-opensta.py（four_paths） | 独立进程及可移植脚本运行成功，60 个字段对照通过 |

外部差分全部使用同一固定 `.lib`、结构图及约束；Netlist wire cap 单独注入参考的 net load。集中电容、无 R、同角/同单位；参考数字使用 12 位 ns 打印（slew property 则使用其实际有效位），未用打印相等冒充数学零误差。

| 案例 | 比较字段数 | 最大绝对差 ps |
| --- | ---: | ---: |
| 三反相器链 | 36 | 0.0000333891 |
| 链 + 非零 wire C | 36 | 0.0000806744 |
| 链的负 slack | 36 | 0.0000160830 |
| RCA4（含多 sense XOR 弧） | 316 | 0.0001268743 |
| c17（仅本地参考） | 108 | 0.0001258408 |
| Sky130 dfxtp 同步路径 | 44 | 0.0001646848 |
| 同步路径负 slack | 44 | 0.0000422620 |
| 四类路径混合图 | 60 | 0.0001646848 |

合计 680 个 AT/slew/端点 required/slack 字段，最大差约 0.000164685 ps，小于本期固定模型下 1 ps 预算。37 个已报告最坏端点/边沿的路径序列一致；报告最多 100 路径，RCA4 的路径身份覆盖为 7/10 端点沿，数值字段仍覆盖其全部被测节点/端点。未声称全路径穷举、任意 PDK 或 RC 签核精度。

有意义的独立断言还检查负载 SI 数值、边沿反转、tCQ/setup 与周期/latency/uncertainty 的关系、未约束端点、寄存器反馈与真实组合环、多驱动/缺引脚/负负载、受限 SDC 的错误/覆盖规则、JSON 错误及范围策略。未把单个 oracle 当作元数据或数学定义的替代品。

失败记录如实保留：最初的 API/测试语法编译错误；旧 OpenSTA 不识别新命令名/属性，改以该固定版本源码核实 probing 接口；第一版路径验证器把次坏路径也要求等于最坏路径，修正后先复核已保存输出。之后因新增元数据校验与 JS 导出包布局改变，最终编译产物又执行一次完整相关差分，未合并成“更多样本”。

原始命令、退出码、版本、输入/源身份及逐字段结果保存在 `reports/liberty/implementation-03/` 的 commands.jsonl、logs、ORACLE-RESULT.json、oracle-runs 和 SOURCE-IDENTITY.json。源码交付的独立复现脚本不会内置或复制 STA 数值算法。

## 2026-10-28 深入修复 05

最小修复：有限输入派生 arrival/required/slack 的非有限结果显式报错；DFF 非零 ideal latency 在路径中记录；受限 SDC 接受有限负 latency，同时拒绝空选择器/不存在或非输入的时钟端口/空时钟名；外部对照 Verilog writer 正确连接不同名的 port 与 net。公共根接口不变。

新增 7 项黑盒回归包含三条独立溢出路径、仍可表示的大数、路径求和、负 latency、SDC 边界、真实负 setup/交换轴及半沿 unconstrained。最终 JS、Wasm-GC、native 均 20/20；check/all、release build/all、info/all、fmt 成功。构建输出的 CJS TypeScript 声明提示与 JS-only 接口差异是已有工具限制，不是新增编译诊断。

独立参考复用既有固定 OpenSTA 2.0.17 进程，不重新下载或重跑旧 680 字段。新增案例如下：

| 新案例 | 数值字段 | 最大绝对差 ps |
| --- | ---: | ---: |
| latency_positive | 60 | 0.000164146 |
| latency_negative | 60 | 0.000104072 |
| negative_setup | 24 | 0.000140857 |
| negative_setup_axes_swapped | 24 | 0.000140857 |
| port_net_alias | 60 | 0.000105280 |
| split_arrival_slew_fanin | 36 | 0.000114334 |
| picosecond_femtofarad_units | 36 | 0.000000137 |
| half_edge_unconstrained | 14 | 0.000028526 |

合计 314 字段，最大绝对差 0.000164146 ps，低于 1 ps 固定模型预算。16 条 DFF launch 路径 delay 求和与 arrival 一致（容差 1e-21 s）；36 项单位协变关系通过（1ns/1pF 改为 1ps/1fF，SI 结果为原来的 0.001）。汇合节点双沿 arrival 来自 a、slew 来自 merge/B。负 setup 在原始与变量轴交换后的表中均得到独立参考确认。

半沿未约束案例完整保留：OpenSTA 对缺 clocked arrival 的沿不生成 required，本库保留显式输出 required=1.9 ns；此 1 项单独按约束公式断言，不计入上述 OpenSTA 字段数。该沿 arrival/slack 无值，与参考未约束状态一致。初版探针把该 required 也要求参考存在而失败，其 JSON 与日志保留，修正的是比较语义，不是输入或实现。

仓库 tools/verify-opensta.py 在同一端口别名输入上由缺失 launch/Q 参考失败变为 60 字段通过，最大差 0.000105280 ps；该组是上表别名案例的复现，未重复计入 314。

证据目录 reports/liberty/deep-repair-05-20261028：FINDINGS.md、DEEP-ORACLE-before.json、DEEP-ORACLE-after-initial-probe.json、DEEP-ORACLE-after.json、cases、oracle-before/oracle-after、commands.jsonl/logs、before/after 身份清单与新源码 ZIP。保留旧报告、旧 ZIP、许可证与未改变的单时钟/零线电阻/非签核边界。

## 2026-10-28 深入修复 06 Max

本轮定位到缺省 timing_sense 忽略可判断的 function 单调性、单沿 timing group 被误拒、零 slew 来源丢失。最小修改只在 library.mbt/engine.mbt；新增 repair06_test.mbt，公共根接口 SHA 不变。依赖版本、图/约束/单位/溢出校验及第05轮修复保持。

新增 6 项黑盒，before 为 2 通过/4 失败，修复后定向 6/6。最终 JS、Wasm-GC、native 各 26/26；fmt、check/all --deny-warn、info/all、release build/all --deny-warn 通过。已有 CJS TypeScript 声明提示和 JS-only 接口差异仍为同一工具限制，不计为新增警告。固定函数/枚举 API 通过 moon ide doc 的完整包路径和依赖源码查证。

新增独立 OpenSTA 2.0.17 对照：每组通过发布的 tools/verify-opensta.py 序列化相同输入并运行编译后的 Node 导出消费者，比较所有被测节点 AT/slew 与端点 required/slack。真实 Sky130 表值不变，分组案例只改组织；零 slew 案例把 transition 值固定为 0。没有重跑旧 680/314 字段集合。

| 案例 | 数值字段 | 最大绝对差 ps |
| --- | ---: | ---: |
| omit_inv | 20 | 0.000049772 |
| omit_and2 | 28 | 0.000047684 |
| explicit_nonunate | 20 | 0.000049772 |
| omit_no_function | 20 | 0.000049772 |
| split_q | 44 | 0.000164685 |
| split_setup | 44 | 0.000164685 |
| split_comb | 20 | 0.000049772 |
| zero_slew | 20 | 0.000049772 |

合计 216 字段，最大差 0.000164685 ps，均低于固定模型 1ps 预算。零 slew 的两个输出沿还独立检查 contributor=gate/A。省略方向的 INV/AND2 在 before 分别误差约860.208/694.583ps；split-Q/setup/comb 在 before 报缺表；相同输入哈希在 after 通过。显式 non_unate 与完全无 function 的控制仍保留保守双沿，未被错误推断为单调。黑盒另核 INV/NAND2/AND2/OR2 与缺 delay/slew 配对或完全缺模型的错误。

首次探针的 AND2 pin 和 function 删除正则错误、首次 @liberty 别名 API 查询失败均单独保留；有效产品 before 在修正 fixture 后固定，不能把探针错误计为产品修复。原输入未裁掉，8组 before/after 身份可核对，未把控制或同案例重跑算成更多案例。

本轮证据在 reports/liberty/deep-repair-06-max-20261028：FINDINGS.md、REVIEW-PLAN.md、PRIMARY-SOURCE-IDENTITY.json、ORACLE-before/after.json、ORACLE-before-comb.json、cases、oracle-*、commands.jsonl/logs、BEFORE/AFTER-IDENTITY.json、BEFORE/AFTER-BUILD-IDENTITY.json 与新 ZIP/回读记录。旧报告/源码包保留；结果仍仅限单理想时钟、单角 NLDM、集中电容/零线电阻模型。

## 2026-10-28 深入修复 07 Max

F1：多输出组合单元被折成一个依赖顶点，造成合法通道交错的假环。graph.mbt 改按驱动输出 pin/实际组合弧排序，engine.mbt 逐输出求值，并在 DAG 完成后完整记录 input pin。真实组合回路、寄存器切分、单驱动和模型错误校验保留。公共根接口形状与生成签名 SHA 未变；topological_order 的实例名在交错求值时可以重复，连续同名合并，README 说明此必要的值语义。

新增4项黑盒的 before 为1通过/3失败；修复后4/4。最终 JS、Wasm-GC、native 各30/30；fmt、check/all --deny-warn、info/all、release build/all --deny-warn 通过。只运行受图/执行改动影响的包检查与新案例，没有重跑以前的下载或680/314/216字段集合。

新输入是自编双缓冲 DUAL 与 INV 的精确模型，实际执行固定 OpenSTA 2.0.17 与发布的 Node 导出消费者。不是新增工艺库精度声明：标量延迟/transition 是明示常数；1D 延迟为 base+0.1×input_slew(ns)，slew(ns)=base+load(pF)。对同一真实 pin DAG 作 scalar、pin声明换序、1D以及直连1D控制。

| 案例 | 比较字段 | 最大绝对差 ps |
| --- | ---: | ---: |
| interleaved_scalar | 36 | 0.000025034 |
| reordered_scalar | 36 | 0.000025034 |
| interleaved_1d | 36 | 0.000061989 |
| straight_1d_control | 20 | 0.000081062 |

合计128个AT/slew/端点required/slack字段，最大差0.000081062ps；8项端点到达值手算独立通过（1e-24s容差）。标量 rise/fall 为0.88/0.9ns；1D为0.8975/0.9175ns；直连1D控制 before 已通过，未把已有正确查表凑成缺陷。黑盒另检查完整前驱路径/沿、负载SI、末级slew、18个唯一pin/edge记录、pin/实例声明顺序不变性与真实Y→B→Y循环拒绝。

本轮目录 reports/liberty/deep-repair-07-max-20261028 包含 REVIEW-PLAN.md/FINDINGS.md、cases、oracle-before/after、ORACLE-before/after.json、commands.jsonl/logs、源码与编译产物身份和新ZIP回读。before编译身份复用已封存06的release消费者基线，before源码身份与该轮一致；after重新构建并直接记录实际消费者产物。旧源码包/回执保留，未发布或改全局工具链。

## 2026-10-28 深入修复 08 Max

F1：原来直接拼 instance/pin，会把端口u/Y与实例u输出Y合并，也会混淆不同的实例/pin分量分割。只在types.mbt/engine.mbt加入统一报告分量转义，并用于Node、Endpoint、PathStep和slew contributor；原始输入、SDC选择器、topological_order、时序算术不变。公共根API形状和签名SHA不变，含~/名称的报告字符串值按README规则修正；普通名称保持输出。

新增4项黑盒的before为0/4，修复后4/4；最终JS、Wasm-GC、native各34/34，fmt/check-all/info-all/release-build-all完成。第一版转义把UTF-16补充字符拆开，2/4失败保留；按实际Char API写入后修正，未另凑原始缺陷。API精确文档查询未命中、WSL无rg及grep源码fallback日志全部保留，String::to_array -> Array[Char]由实际SDK源码查证。

4组实际Node导出消费者（相同before/after输入）：port_pin_and_lookalike、components_unicode、unicode_only_control、sequential_labels。56个pin/edge记录身份唯一，报告ID集合与输入物理pin严格对应，所有path/contributor引用有效。另有6项固定1D模型手算到达值、82项DFF双射重命名的数值不变性检查。Unicode-only控制before即通过，证明确实没有把已有正确词法算成缺陷。

本轮没有新增OpenSTA精度成绩或重复旧数值集合：算术及表模型未变，沿用07已验证数据；新验证针对实际JSON/SDC/输出消费者和名称身份。RFC6901 §3为分量规则依据，采用其可逆映射而非新建输入格式。旧05—07源码/报告/包保留。

证据在 reports/liberty/deep-repair-08-max-20261028：REVIEW-PLAN.md/FINDINGS.md、cases、consumer-before/after、CONSUMER-before/after.json、commands.jsonl/logs、BEFORE/AFTER-IDENTITY.json、BEFORE/AFTER-BUILD-IDENTITY.json和新源码ZIP回读。后续功能拓展另行立案，不混入本轮已证修复。

## 2026-10-28 拓展 09：Setup 周期预算

用户授权拓展后，先核MoonBit生态和相关EDA项目，再选择本方向；研究/候选/兼容标准见本轮ECOSYSTEM-RESEARCH.md与DESIGN.md。承认OpenSTA已有相近报告，不宣称首创。固定运行依赖/SDK不变，没有移植参考STA代码。

新增run_period_analysis及可选JSON period_budget:true：同时返回原时序结果与逐端点period下界、覆盖状态、限制端点及可表示频率。只在完整覆盖时给整体结果；缺约束、无正下界、倒数溢出均区分。直接由端点约束计算，巨大period不因P−WNS消减而丢小预算；下界溢出报错，旧timing API可表示输入仍有效。

新增9项独立黑盒，最终JS/Wasm-GC/native各43/43；fmt、check/all --deny-warn、info/all、release build/all --deny-warn通过。根公共接口为加法扩展，旧签名保留。JSON集成还揭出Netlist派生Input/Output与读取小写不兼容，before原输入保留；入口与参考writer兼容这两个枚举别名，小写请求不变。

真实Node运行完整/Partial两个新示例、旧缺省请求、原生枚举往返及非法flag，共5次：预算true不改变原result，缺省不增加预算字段；非法flag退出2。完整示例最低周期约0.487723672ns、模型频率约2.050341325GHz，Partial示例缺2沿时整体period/frequency无值。

固定OpenSTA 2.0.17在预测下界的下方1ps、边界及上方1ps重算：

| 模型/位置 | 字段 | 参考最坏slack ps | 最大绝对差 ps |
| --- | ---: | ---: | ---: |
| scalar/lower | 36 | -0.999977929 | 0.000025034 |
| scalar/boundary | 36 | 0.000000000 | 0.000025034 |
| scalar/upper | 36 | 0.999977929 | 0.000036716 |
| negative_setup/lower | 24 | -1.000033459 | 0.000041459 |
| negative_setup/boundary | 24 | 0.000000000 | 0.000066543 |
| negative_setup/upper | 24 | 0.999977929 | 0.000053669 |

共180字段，最大差0.000066543ps；下/上边界符号和边界绝对值<=1e-15s的检查通过，所有目标周期下预算相同。scalar独立公式1ns/1GHz；真实DFF的负setup逐端点下界0.0518665/0.0591908ns按固定PDK节点与约束手算确认。另在同一原生枚举JSON上运行参考writer，before方向检查失败、after44字段通过（不当作新物理模型或重复大集合）。

公开API/错误分支另覆盖：巨大参考period、负延迟/无正限制、部分/全部/没有端点、极小下界的倒数溢出、有限旧timing但预算下界不可表示、转义端点身份及JSON默认兼容。没有重跑以前680/314/216/128字段集合；本轮参考为新目标周期与原生表示输入。

证据目录 reports/liberty/extension-09-max-20261028：研究来源原文、DESIGN/FINDINGS、FEATURE-BEFORE、PERIOD-ORACLE、SMOKE-RESULT、cases/oracle/native-oracle、commands/logs、源码/编译身份、API差分、新ZIP逐项回读。08及更早封存件不改；不推送、发布或改报名/作者/全局SDK。

## 2026-10-28 深入修复 10：共同时间参考稳定性

F1：共同ideal latency只是时间原点平移，但绝对arrival舍入后再比较/相减，会丢失前驱、slack与预算。原样NAND输入的有限大正/负共同偏移使原程序把1.2ns下界报成0.1ns、晚输入b错选a、slack全0。真实Sky130 DFF也复现预算改变。只修改engine.mbt/period_budget.mbt，保留传播时的相对值，路径比较、slack与同一次预算共享；公开绝对Double字段/接口保持。

新增5项黑盒before为2通过/3失败，after5/5；最终JS/Wasm-GC/native各48/48，fmt/check-all/info-all/release-build-all通过。覆盖标量边界上下、正/负共同平移、较晚前驱、真实DFF、旧有限极大输入的相对值超范围fallback、并列限制端点与未知沿。后两控制原已正确，未凑作缺陷；未引入新幅值限制。

6个实际Node输入：zero、positive、negative、lower、boundary、upper。before/after JSON及Liberty哈希相同；after所有场景预算1.2ns、前驱b，2ns目标最坏slack0.8ns；边界上下为约-1/+1ps。端点限制定位与预算、slack的三个相关后果一起修复，未只改显示。

独立参考采用代数等价的L=0框架：required=P+L−U−offset，arrival=L+data，故slack=P−U−offset−data。固定OpenSTA 2.0.17验证同一NAND和三个目标，再把参考slack与大L消费者结果对照，不声称在高偏移绝对AT上有额外可表示精度。

| 目标 | 零偏移参考字段 | 最大绝对差 ps | 大偏移slack对照最大差 ps |
| --- | ---: | ---: | ---: |
| lower | 28 | 0.000047684 | 0.000036716 |
| boundary | 28 | 0.000047684 | 0.000008941 |
| upper | 28 | 0.000048637 | 0.000022071 |

共84个规范化AT/slew/required/slack字段，最大差0.000048637ps；另6个大偏移端点slack对照最大差0.000036716ps，均通过1e-15s交叉容差。绝对字段仍可能舍入，应使用直接报告的slack/预算；相对通道自身超范围时保留既有绝对通道行为，没有无限精度声明。

首次参考探针把两个get_ports参数写为裸位置参数，OpenSTA要求Tcl列表分组；失败保存在normalized-oracle/initial-probe。仅参考侧规范化为{a b}，原6个消费者输入不改，已过消费者输出复用而未重新运行；CLOCK-after说明了复用。该探针问题和当前SDK缺Option.and_then的首次编译失败不计为原项目缺陷。

证据目录 reports/liberty/deep-repair-10-max-20261028：REVIEW-PLAN/FINDINGS、CLOCK-before/after、cases/consumer-*、normalized-oracle、commands/logs、源/编译身份、新ZIP逐项回读。09及以前封存件保留；未重复旧大集合、修改依赖/SDK、发布或改变账号作者。

## 2026-10-28 深入修复 11：短约束和相消及最终范围

同一 F1 有两种表现：P+L−U−offset、P−U−offset−data 和 data+U+offset 顺序计算会吞掉相消后的小量，或在最终有限时因中间溢出误拒绝。四个真实 JSON/SDC 反例使用合法有限输入和 1s 库时间单位；before/after 输入 SHA256 相同。

| 反例 | before | after 与精确有理数预期 |
| --- | --- | --- |
| cancel：U=1e12、output_delay=−1e12 | required=0、slack=−1ns、预算=0 | required=2ns、slack=1ns、预算=1ns |
| near_cancel：残差 0.0001220703125s | required/slack/bound 均丢小量 | required=0.00007792968750000001s，slack=0.00007792868750000001s，下界=0.0001220713125s |
| budget_intermediate_overflow | period bound 非有限错误 | required=1e308s、slack=0、下界=1e308s |
| required_intermediate_overflow | required 非有限错误 | required/slack=1e308s、下界=0，NoPositiveLimit |

constraint_sum.mbt 是本项目私有实现：有限 binary64 操作数按 2^-1074 整数单位落入固定 72 个 base-2^30 带符号 limb，精确合并后以 guard/sticky 和偶数规则舍入一次；精确相反项有二项和捷径。只用于现有三／四项 required、稳定 slack 与周期下界。绝对报告和逐弧传播仍为 Double；没有全流程任意精度承诺、幅值裁剪、新依赖或公开类型变更。相对通道超范围时，budget 的四项合并可恢复有限下界；slack 的既有绝对 fallback 保留。

新增 4 项公开 API 黑盒，覆盖相消/近相消与上下边界、两个中间溢出反例、DFF 负 setup 与 uncertainty 抵消、相对 arrival 超范围但周期下界有限。另有 1 项白盒内嵌 384 组独立 Python Fraction 预期（165 组定向排列、109 组近相消、110 组有限位模式）；含负数、正规/次正规、零、ties-to-even、sticky、最大有限数与真正最终溢出。向量生成不复刻 limb 算法。最终 JS/Wasm-GC/native 各 53/53，fmt、check-all --deny-warn、info-all、release-build-all 通过。

12 次实际 Node 导出消费者：4 原始反例、4 个 cancel/near_cancel 下界±1ps、3 个真正最终 required/slack/bound 溢出拒绝，以及原真实 Sky130 sequential 示例。4 反例的16字段、4边界的32字段和DFF的12字段合计60项精确有理数核对通过；上下边界 slack 分别为负/正，3错误均退出2。DFF核对使用实际转换后的 binary64 约束与报告的逐端点 offset/arrival，只验证约束代数，不作为独立查表或新物理模型精度成绩。本轮没有重跑旧 OpenSTA 集合。

首次编译暴露本地 SDK 的弃用转换方法和运算符优先级，按实际诊断修正，失败日志保留；不计为原产品缺陷。第一次完整 JS 为52/53，旧 inverter/setup 断言将顺序表达式当精确预期；REAL-DFF-ROUNDING.json 的12项独立有理数核对确认新结果正确。保留原测试输入，将两个正数代数比较明确为最多1 ULP，未修改全局 near 容差。修正后单次 JS/Wasm-GC/native 完整验证均为53/53；首次失败未覆盖。

证据在 reports/liberty/deep-repair-11-max-20261028：REVIEW-PLAN/FINDINGS、CONSTRAINTS-before/after、RATIONAL-VECTORS、BOUNDARIES、REAL-DFF-ROUNDING、原始cases/consumer输出、commands/logs、源/编译身份及新ZIP逐项读回。根公开接口 SHA 不变；第10轮及更早封存包/报告保留；未发布、推送或修改账号/作者/SDK。

## 2026-10-28 深入修复 12：SDC 精确名称与注释边界

F1：sdc_tokens在命令词中以及已提取的selector列表数据中再次解释#为注释。真实before的embedded_hash把a#b约束静默写到另一个存在的a，y变成未约束；leading_hash把#data拒绝为空selector；clock_hash把core#clk截断并拒绝create_clock。comments_control原本通过，不计作缺陷。

仅在sdc.mbt调整私有分词器：顶层注释从空词、分组外开始；名称词中的#保留。selector内部和waveform列表为数据，禁用注释解释。受限profile已有空白后行尾注释继续支持；不宣称完整Tcl执行语义。官方Tcl语法规则[6]/[10]提供词/列表与注释边界参考，见本轮REVIEW-PLAN链接。

新增3项黑盒：hash在名称中间/开头的精确绑定与短前缀防误绑、hash时钟名和整行/行尾注释共存、未知a#missing按完整名称错误。JS/Wasm-GC/native各3/3；JS额外受影响既有SDC4/4、名称4/4。fmt、check-all --deny-warn、info-all及release-build-all通过，根公共API SHA不变。为遵守不重复无关验证，本轮未执行完整root数值套件、384向量、OpenSTA或旧大数消费者，不宣称56项全套已重跑；第11轮53/53历史结果保留。

4组相同before/after实际Node消费者：embedded_hash、leading_hash、clock_hash、comments_control。原JSON哈希逐项相同；after全部完整覆盖，a=0.9ns，目标data=0.2ns、required=1.9ns、slack=1.7ns、周期下界=0.3ns。共20数值字段按独立直连SI公式在1e-24s容差内通过；selector/注释修复没有重写时序数值算法。新增examples/hash-names.json与已验证embedded_hash请求逐字节相同，可用README命令运行。

证据在reports/liberty/deep-repair-12-max-20261028：REVIEW-PLAN/FINDINGS、SELECTORS-before/after、原请求/消费者输出、commands/logs、源/编译身份、差分及新ZIP逐项回读。第11轮RESULT/ZIP哈希与提供封存值一致，未改旧材料；未发布/推送/改SDK账号作者。

## 2026-10-28 深入修复 13：花括号内的标量位名称

F1：JSON允许独立标量名a[0]/clk[0]/y[3]，但SDC已用花括号保护名称时，lexer仍累加内部方括号深度并把它当嵌套命令。before的data_bit、clock_output_bit、bit_list三个真实请求均bad SDC grouping；nested_command_control已正确拒绝，未计为缺陷。

仅修改sdc.mbt私有分词器：命令扫描在花括号外处理方括号分组；已提取的selector列表关闭方括号解释。花括号内方括号为数据，包括合法的单个未配对方括号字符。没有新增总线声明、位展开、向量运算或Tcl执行器；非花括号保护的嵌套命令仍拒绝，上轮hash/注释行为保留。

新增2项黑盒在JS/Wasm-GC/native各2/2，覆盖输入/时钟/输出标量位名、括号字符保真、名称列表精确绑定与真实嵌套命令拒绝；JS另有受影响的既有SDC4/4、上轮hash3/3。fmt/check-all --deny-warn/info-all/release-build-all通过，根公开API SHA不变。未重跑完整root、384数值向量、OpenSTA或旧大数消费者；不将本轮子集表述为当前58项全套成绩，第11轮53/53历史结果保持。

同一before/after原始JSON的4个实际Node消费者：3个正确接受并完整预算，1个嵌套命令退出2。直连独立预期：目标data=0.2ns；另一输入=0.9ns，名称列表覆盖时=0.2ns；required=1.9ns、slack=1.7ns、下界=0.3ns。3×5=15数值字段在1e-24s容差内吻合；这属于名称/绑定核对，不增加物理模型精度成绩。examples/scalar-bit-names.json与已证bit_list请求逐字节相同。

证据在reports/liberty/deep-repair-13-max-20261028：REVIEW-PLAN/FINDINGS、BITS-before/after、原始cases/consumer输出、commands/logs、源码/编译身份、差分和新ZIP逐项读回。第12轮RESULT/ZIP与给定封存SHA一致，旧材料只读；没有发布、推送、赛事提交或SDK/账号/作者变更。

## 2026-10-28 有限审查 14：CLI 文件入口

本轮选两个未覆盖的入口契约：在产品目录外、中文/空格目录中用含Unicode的相对文件路径调用真实Node CLI；文件读取错误和已读取坏JSON的输出/退出分界。没有发现新缺陷，没有修改运行时代码/API/例程/依赖/数值算法，也没有新增测试或重复MoonBit编译、全套回归、OpenSTA与旧数值集合。

共4次实际CLI：external_unicode_space_paths退出0，missing_library/missing_request/malformed_request均退出2。缺文件在stderr报告对应ENOENT且stdout为空；坏JSON由MoonBit核心返回ok:false/schema/error。成功路径的库/请求是原sequential示例字节副本，文件移到“输入 文件”目录，在不同的“外部 调用”目录用相对输入路径调用；SHA与第11轮独立DFF约束回执输入一致，输出与其封存consumer-real-dff.json全部内容等价。

独立预期是文件位置变换不应改变内容、以及既有CLI退出契约，不是新增时序模型或查表精度oracle。没有为了核对路径再跑一次原产品目录下的相同模型基准。第13轮冻结身份与当前60个源文件和四个实际release产物一致；审查后编译产物SHA保持，仅README/PROPOSAL/VALIDATION说明变化。

首次回执脚本读取含中文路径的JSON时漏指定UTF-8，Windows默认GBK导致报告阶段失败；只修本轮报告脚本的显式编码，CLI验证不重复。失败日志保留，不计为产品缺陷。

证据在reports/liberty/deep-repair-14-max-20261028：REVIEW-PLAN/FINDINGS、IO-REVIEW、原输入副本和consumer stdout/stderr、commands/logs、源码/编译身份、差分及新ZIP逐项CRC/SHA读回。第13轮RESULT/ZIP与给定封存值核对并保留，未发布/推送/提交赛事或改SDK账号作者。本轮有限审查完成，不代表新增核心回归成绩。

## 2026-10-28 拓展 15：Setup状态、覆盖与违例摘要

先研究最多两个实际需求：自动化消费违例摘要、自有SDC的位置诊断。上游MoonLiberty公开README覆盖库解析/查询/审计并明确非完整STA；OpenSTA已有WNS/TNS报告，因此不宣称摘要首创。实际依赖/SDK不升级。选择有清晰手算验收的小范围摘要，位置诊断只记录研究，不改旧错误枚举。候选/来源原文与选择见本轮ECOSYSTEM-RESEARCH/DESIGN。

新增SetupSummaryStatus、SetupSummary与STAResult::setup_summary，按已有端点slack统计唯一报告pin端点数、已知/未知沿、负slack沿/端点和worst/WNS，不重跑传播。状态为Met/Violated/PartialCoverage/NoCoverage/NoEndpoints，已知违例足以判失败，覆盖不足或空端点不能判Met。JSON布尔setup_summary可选添加并与period_budget组合；原result、预算和默认退出规则保持。公开API是加法扩展，原声明逐块核对。

新增5项黑盒三后端各5/5：独立给定六沿三端点的去重计数、全部状态及零边界、有限极大值/非有限公开slack对象拒绝、真实DFF已知6沿/3端点在宽松与严格目标下的状态、JSON缺省/false/组合/坏flag兼容。JS另执行两个直接受影响的既有JSON回归各1/1。fmt/check-all --deny-warn/info-all/release-build-all通过。未执行完整root数值套件，不将本轮子集宣称为当前63项全套成绩；旧OpenSTA、384向量和第14轮I/O场景未重跑。

拓展前真实CLI请求setup_summary:true得到原报告与已有预算、没有新摘要，记录为功能缺口而非缺陷。拓展后10次实际消费者：combined、summary_only、absent、false、met、partial、violated_partial、unconstrained、empty、bad_flag。7个摘要场景共56项状态/计数/Optional值字段按独立直连模型手算核对；其他3个验证缺省/false封包与坏类型。原combined请求SHA和库SHA不变，result与period_budget逐字段等于拓展前，负slack成功分析仍退出0，坏flag退出2。

直连例程独立预期：input=0.6ns、目标1ns，y输出delay为0.5/0.6ns，z为0.2/0.2ns，w为0.5/0ns，故六沿slack为−0.1/−0.2/+0.2/+0.2/−0.1/+0.4ns；3个违例沿、2个违例端点、WNS=−0.2ns。目标2ns时worst=+0.8ns而WNS=0。部分约束例子分别核正已知+未知及负已知+未知；计数不是路径数，也没有TNS或新模型精度声明。setup-summary.json和setup-summary-partial.json与已证请求逐字节相同。

初版枚举构造器Partial/Unconstrained与旧PeriodBudgetStatus产生推断歧义，首次check/target日志保留；发布前改为不冲突的PartialCoverage/NoCoverage，未修改旧类型或算法，不计为原产品缺陷。修正后新增测试及相关验证单次通过，未反复刷通过用例。

证据在reports/liberty/deep-repair-15-max-20261028：研究来源/设计、FEATURE-BEFORE、SUMMARY-CONSUMERS、cases/consumer-before/after、commands/logs、API兼容差分、源/编译身份及新ZIP逐项读回。第14轮RESULT/ZIP与给定冻结值核对，旧材料只读；本地未发布、推送、赛事提交或改SDK/账号/作者。

## 2026-10-28 拓展 16：显式CLI setup检查

先只读复核15轮冻结RESULT/ZIP、64源码/四编译身份、三端各5项摘要测试、两个相关JSON回归和10消费者56字段，不重跑。没有把默认负slack仍退出0的既有正确契约当作bug。本轮只研究并实现一个操作缺口：CI显式要求Met，并区分已知违例与覆盖不足。MoonBit生态/同类检索及参考vyges-tools/sta-si的显式退出方式见RESEARCH；不宣传首创，不引入其SI/OCV范围。

新增--check-setup：Met退出0、Violated退出3、PartialCoverage/NoCoverage/NoEndpoints退出4，输入/参数/分析错误仍2。JS宿主只映射核心status；MoonBit JS新导出analyze_json_for_setup_check在合法布尔/缺省时请求既有摘要，坏类型/非对象/坏JSON保留原核心错误行为。默认两路径模式、原analyze_json、可选JSON模式和period_budget不变；原root的29公开声明、摘要端点/沿计数及WNS算法完全未改。新模式不改写请求文件。

13次实际CLI调用：auto_met、auto_violated、partial、violated_partial、no_coverage、no_endpoints、bad_flag、bad_json、non_object_json、legacy_default_violation、literal_flag_library_name、unicode_identity_and_capacitance、unknown_option。四类退出分布为0三次、3三次、4三次、2四次；10份完整JSON按冻结15轮报告（或明确的独立名称/电容变换）等价核对，另外3份核错误/usage契约。所有请求字节SHA前后不变。已知违例+未知沿仍退出3；没有把WNS=0或None当作Met。

Unicode/电容场景使用数🌙/a~0的合法名称及1.234567890123456e-15F非零线电容；独立按报告转义规则和直连负载定义变换预期，完整输出吻合。两个默认模式控制即使Violated仍退出0，字面名--check-setup的库文件在双参数形式仍合法。新增setup-check-met.json与已验证auto_met请求逐字节相同；现有违例/Partial例程可直接用于新CLI。

只执行受改动JS路径的Moon check --target js --deny-warn、fmt、info --target js、release build --target js --deny-warn和Node语法检查。没有重复未改核心三后端测试、旧10/56消费者、OpenSTA或14轮I/O；三个未改后端编译产物保留实际身份。JS模块保留旧导出并增加检查导出，生成接口诊断与实际CJS导出均有证据。

首版直接创建SDK只读Json枚举被编译拒绝；按本地moon ide doc Json已查的公开Json::boolean/object工厂修正。首次check/info失败保留，不计为原产品缺陷。修正后相关检查与实际消费者单次通过，随后只做文档和封包。

证据在reports/liberty/deep-repair-16-max-20261028：PRIOR-EVIDENCE-REVIEW、RESEARCH/DESIGN、FEATURE-BEFORE、GATE-CONSUMERS、cases/stdout/stderr、commands/logs、root/JS接口身份、源/编译身份及新ZIP逐项CRC/SHA读回。15轮冻结材料只读；没有推送发布、赛事提交或SDK/账号/作者变更。

## 2026-10-28 有限审查 17：同进程错误优先级与恢复

本轮只选一个未覆盖链：长期进程顺序复用普通/检查CJS入口，多重错误请求的首错优先级和随后部分覆盖恢复。未发现需要修复的代码。运行时代码、root29声明、JS导出、CLI退出策略及README/面向评委的功能提案原样保留；仅在此记录新增证据，不为轮次刷写功能文案。

单个Node进程只加载一次实际CJS产物，执行11次模块调用：五组多重错误各走普通/检查入口（10个错误响应），随后一个合法部分覆盖请求。独立按未改核心源码定义的首错为：网表缺ports、库语法LibraryFailure、SDC未知命令、range_policy无效、period_budget类型无效。后置错误同时存在，包含坏setup_summary类型；所有普通/检查原始错误封包逐字节相同，且只有ok/schema/error字段，首错符合既有顺序。库阶段只冻结错误类型，不把上游语法文字当额外兼容承诺。

随后在同一实例对合法setup_summary:false请求调用检查入口，返回完整报告与15轮已独立验证的partial结果等价，状态仍为PartialCoverage、未知沿数1，没有误报Met或残留先前错误。本轮不是并发测试，也没有重跑16轮13次CLI/10输出、旧模式兼容集合或退出码矩阵；CLI源码和实际编译产物与冻结16轮一致，原Met0/违例3/覆盖不足4/错误2策略保持。

16轮RESULT/ZIP给定SHA、65源码文件、四实际编译身份及既有证据只读核验。没有重编译、MoonBit/OpenSTA旧套件重跑或新增产品单元测试。当前README/PROPOSAL仍准确，按原字节随新包封存；新ZIP逐项CRC/SHA读回。

证据在reports/liberty/deep-repair-17-max-20261028：REVIEW-PLAN、PRIOR-EVIDENCE-REVIEW、driver.cjs/request-sequence.json、single-process stdout/stderr、PRIORITY-REVIEW、commands/logs、源/编译/API身份及新包回执。只代表这条固定顺序复用链的有限审查，不增加时序数学或签核精度成绩；没有发布、推送、赛事提交或SDK/账号/作者变更。

## 2026-10-28 有限审查 18：大JSON管道消费

只选一条不同的真实消费链：较多端点的部分覆盖报告，经显式CI检查输出给延迟开始、分块读取的客户端，非零退出时JSON仍须完整。未发现新缺陷，运行时代码/README/功能提案无需改写；仅记录本次证据。

一次真实CLI，使用新建直连标量图的256个中文/emoji输出别名，目标1ns、输入delay=0.6ns、输出只约束rise delay=0.2ns。独立预期为256端点/512沿，rise256已知、fall256未知；arrival=0.6ns、rise required=0.8ns/slack=0.2ns。WNS为0但状态必须PartialCoverage，检查退出4。周期预算Partial，rise下界0.8ns、fall无值，不给整体period/frequency。

实际stdout共364110字节，以4093字节块读出89块。消费者先延迟250ms、每块请求暂停1ms并做增量UTF-8解码，发生2次跨块编码暂存后完整完成；解码再编码与原始字节严格一致，JSON完整可解析。全部512端点记录和512预算记录的Unicode身份、沿与数值/缺省字段符合手算，未知fall没有被补0。原请求SHA保持，CLI退出4，原始stdout/stderr及SHA保存。此处不假定系统管道容量，不宣称吞吐/最大规模或新增物理模型精度。

17轮RESULT/ZIP给定冻结SHA、65源码/四实际编译身份只读核验。未重跑17轮同进程11调用或16轮CI13调用集合，未重编译或刷MoonBit/OpenSTA旧测试。CLI退出策略、root29公开声明、JS导出、摘要计数/WNS和旧模式保持；README/17行功能提案准确，原字节随包封存。

证据在reports/liberty/deep-repair-18-max-20261028：REVIEW-PLAN、PRIOR-EVIDENCE-REVIEW、large-partial.json、probe_stream.py、stream.stdout/stderr、STREAM-REVIEW、commands/logs、源/编译/API身份及新ZIP逐项CRC/SHA读回。本轮只证明这一固定大输出/完整读取场景；没有实现新模型、格式、发布或SDK/账号/作者变更。

## 2026-10-28 兼容拓展 19：Node UTF-8 BOM输入

先核18轮冻结RESULT/ZIP、65源码/四编译身份，只读旧证据，不重跑18/17/16链。选一个真实文件互操作需求：Windows工具生成带UTF-8 BOM的Liberty/请求文件。Microsoft官方PowerShell编码说明及上游MoonLiberty 0.4.2已声明BOM兼容的公开README作为需求/同类依据，见RESEARCH与原文。实际依赖保持0.4.1、SDK不动；只在Node/JS适配边界处理文件签名，不复制上游parser或宣传首创。

before同原始输入下，BOM请求、BOM库、两者组合检查分别被拒绝退出2；内部U+FEFF合法名称控制已通过，不算缺陷。仅js/api.mbt添加私有首字符检查，两个入口各自对完整库/请求文本移除开头一个U+FEFF，再交原核心；内部字符、SDC字段、错误优先级与旧默认/显式检查合同保留。空串安全，单独标记/连续标记不会成为有效默认请求。root29声明、两个JS导出签名、核心数学与宿主退出策略均未改。

after11个编码场景一次通过：默认BOM请求、默认BOM库、检查BOM请求、检查两者BOM、BOM部分覆盖、BOM坏flag、BOM坏JSON、内部U+FEFF无文件头控制、内部U+FEFF加文件头检查、仅标记JSON、双标记控制。8份完整输出按15轮冻结报告及明确a→a U+FEFF b身份变换比较，另3份验证原JSON错误合同；前后库/请求SHA对应，所有原文件只读。默认false仍不增加摘要，显式检查请求摘要，部分覆盖退出4，错误退出2；原CLI退出3策略由未改源码保留，不重刷旧矩阵。

相关fmt、Moon check --target js --deny-warn、info --target js、release build --target js --deny-warn通过；SDK String切片在仅移除单代码单元BOM时不切代理对，本地ide doc证据保留。没有新增镜像单元测试或重跑未变核心三端/OpenSTA/旧消费者。仅JS产物重建，另外三实际产物身份保持。新examples/setup-check-utf8bom.json物理前三字节EF BB BF，且与已证check_json_bom请求逐字节相同，配原干净库可运行。

证据在reports/liberty/deep-repair-19-max-20261028：RESEARCH/DESIGN、research-upstream、BOM-before/after、cases/consumer输出、commands/logs、源/编译/API身份及新ZIP逐项CRC/SHA读回。只支持此Node/JS完整UTF-8文本的单首标记；没有编码自动探测、新SDC格式、SDK升级、发布或账号作者变更。

## 2026-10-28 操作拓展 20：显式请求stdin

先核19轮冻结RESULT/ZIP、66源码/四实际编译身份，并只读11个BOM场景/8份完整输出证据，不重跑旧集合。选择一个操作缺口：CI生成器已有现行JSON请求字节，却必须先落临时文件。旧CLI拒绝新语法的before仅证明功能未提供，不把原两文件契约称为bug。Node官方fd读取说明、jq JSON管道先例与MoonLiberty有限检索见本轮RESEARCH；没有新格式、领域parser或依赖替换。

仅Node宿主添加--request-stdin：最后两参数仍按路径位置解释，显式flag要求请求占位为-，从fd0读取完整UTF-8至EOF。可与--check-setup任意顺序组合，flag不允许重复。未指定新flag时字面-仍读文件；两个位置参数中的字面--request-stdin库名合法。库仍读文件；原MoonBit适配处理单个首BOM、现行JSON及可选模式，输出/退出映射代码块原样保留。

14个真实CLI消费者一次通过：普通stdin、Python字节管道Met例程、逆序flags违例、BOM部分覆盖、空EOF、坏JSON、多JSON文档、坏摘要flag、旧字面dash文件、旧字面flag库文件、旧检查文件调用、缺dash usage、重复flag usage、分段BOM/内部U+FEFF。9份完整输出与冻结15/19轮预期一致；另3份核原JSON错误合同，2份核usage stderr/空stdout。实际覆盖退出0/2/3/4，默认false仍无摘要，多个文档没有被当作JSONL。所有报告输入文件字节SHA前后相同。

分段场景先延迟150ms，BOM三个字节各自写入，再以17字节块写剩余文本，共74次写入。生产者关闭stdin前CLI仍存活且无stdout，EOF后完整报告等价、Met退出0；内部U+FEFF名称保持。本轮证明这一固定输入消费链，不宣称吞吐或最大规模。产品新增examples/setup-check-stdin.py以标准库直接传原始字节，在实际Windows Node v24.11.0/Python 3.14.4上调用成功，不改PowerShell全局编码设置；CLI本身不需要Python。

Node --check和上述消费者通过；未添加镜像单元测试，也未重编译或重跑未改MoonBit核心/OpenSTA/旧消费者集合。root29声明、两个JS入口源码/构建接口依据与四个实际编译产物身份保持。README和17行功能提案按现有输入、模型、API、例程、证据和未支持能力更新；SOURCES标明原创Node IO及Python示例。

证据在reports/liberty/deep-repair-20-max-20261028：RESEARCH/DESIGN、FEATURE-BEFORE、STDIN-CONSUMERS、consumer-after原始stdin/stdout/stderr、commands/logs、源码/编译/API身份及新ZIP逐项CRC/SHA读回。19轮封存材料只读；未发布、推送、赛事提交或变更SDK/账号/作者。库stdin、JSONL/交互协议、自动编码探测及原多时钟/hold/latch/RC/OCV/完整Tcl/Verilog/向量能力不在本轮支持范围。

## 2026-10-28 修复 21：报告管道写入失败

先核20轮冻结RESULT/ZIP、67源码/四实际编译身份与14个stdin消费者/9份完整输出证据，旧集合只读。沿现有CI消费链确认一个实际错误路径：消费者在提交有效BOM Met请求前关闭stdout读端，旧CLI仍退出0且stderr为空，报告无法交付却未显示IO失败。该before原样保存于DELIVERY-BEFORE，不把它解释为时序计算错误。

Node官方Console文档的ignoreErrors默认true与writable error事件说明解释了主因；外层同步try/catch无法处理被Console忽略的输出事件。Moon CLI/moonrun的WASI BrokenPipe映射及MoonLiberty有限stdout检索见RESEARCH，均不作为新STA能力或生态首创依据。版本化Node文档读取不可达的原始返回保留，使用可访问官方说明和本地Node v24.11.0真实消费者验证；未升级任何依赖或SDK。

仅tools/sta.cjs在输出前注册stdout error监听：检测到错误先把退出码置2，再向stderr写一行stdout诊断。原console.log、状态映射块、20轮option解析/stdin或文件读取及JS BOM适配原样保留。已计算的0/3/4在交付失败时被IO错误2覆盖；正常输出仍按旧模式退出。没有重试输出、向损坏stdout写替代JSON或提前process.exit。

单次相关after共7个真实CLI调用：预先关闭输出的Met/stdin、Violated/文件、JSON错误/stdin；接收大型PartialCoverage报告4093字节后关闭管道；正常Met/stdin、正常Violated/文件、正常PartialCoverage/可写文件重定向。四个实际OS管道失败均产生一行EPIPE stdout诊断并退出2；其中途取消前缀与18轮已证报告前4093字节严格一致。后三个完整JSON分别与15/19轮冻结结果相同，退出0/3/4且stderr为空。输入文件SHA前后相同，同一Met请求before退出0、after失败通道退出2。18轮输入只用于新的中途取消行为，未重跑旧89块流式断言，也不新增时序精度计分。

Node语法检查及上述消费者一次通过。没有新增镜像单元测试，未重跑20轮14调用、旧核心/OpenSTA/CJS顺序集合或重编译。所有MoonBit源/接口、root29公开声明、两个JS入口/既有构建接口依据及四个实际编译产物身份保持。README/17行功能提案描述正常输出与输出失败规则，SOURCES标明原创IO策略；既有例程仍适用。

证据在reports/liberty/deep-repair-21-max-20261028：RESEARCH/DESIGN、DELIVERY-BEFORE、DELIVERY-CONSUMERS、consumer-after原始stdin/stdout/stderr/取消前缀、commands/logs、源码/编译/API身份及新ZIP逐项CRC/SHA读回。20轮封存件只读。检测不到的接收端后续解析/持久化失败、已关闭接收端的数据恢复及原多时钟/hold/latch/RC/OCV/完整Tcl/Verilog等限制不属于新增支持；未发布、推送、赛事提交或改SDK/账号/作者。

## 2026-10-28 修复 22：拒绝输入字节的有损UTF-8解码

先核21轮冻结RESULT/ZIP、67源码/四实际编译身份与7消费者/4次EPIPE/3份完整报告证据，旧集合只读。两个新的before真实文件消费者确认：请求信号名称含非法FF字节、Liberty注释含非法FF字节，都被Node默认UTF-8解码替换后接受，退出0；前者与一个原本合法的字面U+FFFD名称生成同一完整报告。Python strict UTF-8独立拒绝这些原字节。未将此输入完整性缺陷误称为时序精度问题。

Node官方Buffer替换字符、编码/字节相等说明及RFC8259编码要求作为边界依据；MoonBit core已有strict/lossy区分并支持BOM策略，承认这不是新算法。当前STA JS接口收到String时原字节已丢失，因此修复属于Node IO。MoonLiberty有限检索、core固定提交源码及来源记录见RESEARCH；既有product/.mooncakes只读检查，没有依赖/SDK工具调用、缓存写入或复制UTF-8解析器。

tools/sta.cjs新增小辅助函数：先按Buffer读取，用原Node UTF-8 codec解码，再重新编码比较原字节；不相等才报带Liberty/request输入标签的IO错误2，stdout为空。合法字面U+FFFD能逐字节往返，绝不按是否出现替换字符拒绝输入。辅助函数不删BOM，原JS适配仍只处理一个首标记；内部字符、原默认/check解析、选择输入渠道及输出策略保留。字节错误在核心解析前按IO处理；合法编码内的JSON/库/SDC错误优先级不改。

after单次9个真实CLI：FF请求/文件、截断多字节请求/stdin、FF库/文件、过长编码请求/stdin、合法Unicode普通文件、合法Unicode与BOM检查/分字节stdin、同名部分覆盖/BOM/stdin、双BOM、合法UTF-8坏JSON配坏库语法。前4个明确编码错误退出2且无stdout；3份完整健康输出按冻结15轮结果及独立身份变换一致，分别普通0无摘要、检查Met0、PartialCoverage4；后2个保持核心invalid request JSON封包/退出2且无stderr。合法名称含中文、U+FFFD、emoji、slash、内部U+FEFF及tilde，按公开转义规则推导报告身份，未改数值预期。

分段消费者先延迟150ms，再1300次每次写1字节，拆开初始BOM和所有多字节字符；消费者等待EOF，随后完整报告吻合。所有fixture字节SHA保持，before/after两个反例按相同库/请求SHA对应。新命令共11次实际CLI分析（before2、after9）；Node语法检查另计。没有重跑21轮七消费者、20轮矩阵、旧MoonBit/OpenSTA集合或镜像单元测试。

全部MoonBit源/接口、root29声明、两个JS入口与四个编译产物身份保持，没有重编译。21轮stdout监听和0/3/4映射、20轮options保持原字节；本轮退出3及EPIPE策略依据未改源码/冻结证据保留，不冒称重新实测。README及17行功能提案准确说明UTF-8输入边界，既有例程仍适用。新ZIP逐项CRC/SHA读回。

证据在reports/liberty/deep-repair-22-max-20261028：RESEARCH/DESIGN、CASE-PROVENANCE、UTF8-BEFORE/CONSUMERS、cases与原始consumer-before/after、commands/logs、源/编译/API身份及新包回执。仅Node CLI原始字节入口严格验证，直接JS String API不新增字节或字符限制；不自动识别其他编码、证明下游落盘或拓展原有时序模型。21轮封存件只读，未发布、推送、赛事提交或改SDK/账号/作者。

## 2026-10-28 有限审查 23：并列周期限制与声明顺序

先核22轮冻结RESULT/ZIP、67源码/四编译身份和9个UTF-8消费者证据，旧集合只读。本轮转回STA报告契约，选一个有限场景：多输出别名的rise/fall同时限制周期时，limiting_endpoints须保留全部身份；交换语义等价声明顺序不得改变报告含义。现有代码检查没有确认新缺陷，不为此制造新功能或预设修复。MoonLiberty有限检索与OpenSTA官方period接口/官方OpenROAD例程研究见本轮RESEARCH，不声称首创或全模型等价。

新建报告内直连图：两个输入a/b、四个独立输出别名（普通名、Unicode/slash、tilde、花括号标量位名），无gate。a的rise/fall输入delay为1/2、1/4秒，b为1/4、1/2秒；各输出offset补足为1秒，共同ideal latency1/4秒、uncertainty1/8秒。八条端点沿均限制period>=9/8秒。报告内库只把time_unit元数据由1ns改为1s，保留原来源/表内容且不查询任何NLDM表；此fixture是精确算术/契约控制，不是新增真实器件或查表精度证据。

六个新的实际CLI调用一次通过：period17/16、9/8、19/16秒，各用正向及反向port/net声明和互不覆盖的SDC赋值顺序。独立Python Fraction预期给全部slack=-1/16、0、+1/16秒；实际检查退出3/0/0，反向同样。每例均为4端点、8已约束沿、0未知沿；低于边界有8违例沿/4违例端点，边界零slack为Met且WNS0。period budget均Complete、下界9/8秒、频率为8/9Hz一次舍入，并列限制完整8条且无重复。全部48端点、48逐沿下界、48限制条目符合独立预期。

三组正反顺序报告在仅按(pin,edge)排列nodes/endpoints/endpoint_bounds/limiting_endpoints后逐字段完全一致；路径次序和其他字段原样保留。此归一化用于比较无序集合，不给原始数组顺序增加公开承诺。原请求/派生库字节SHA保持，stdout/stderr、独立预期及归一化全报告均保存。没有将既有period边界/OpenSTA/UTF-8/管道错误集合当本轮新运行。

未发现本场景需要修复的运行时代码；README和17行面向评委功能提案仍准确，保持原字节。产品仅在此补充真实验证证据，其他源、接口、例程和四个编译产物完全不改。没有新增镜像单元测试、重编译、SDK/依赖工具或旧缓存写入，未重跑22轮9调用、21轮7调用或历史数学套件。root29声明及两个JS入口保持；22轮字节入口和21轮stdout策略依据原字节/冻结证据保留，不另冒称本轮复测。

证据在reports/liberty/deep-repair-23-max-20261028：RESEARCH/REVIEW-PLAN、CASE-PROVENANCE与独立Fraction预期、cases/consumer原始结果、TIE-REVIEW、commands/logs、源/编译/API身份及新ZIP逐项CRC/SHA读回。本轮只是这一固定并列/顺序场景的有限审查；不新增模型/格式/下游落盘证明或覆盖任意电路。22轮封存件只读，未发布、推送、赛事提交或改SDK/账号/作者。

## 2026-10-28 操作拓展 24：无需构建的CLI帮助

先核23轮冻结RESULT/ZIP、67源码/四编译身份及6个并列限制消费者证据，旧链只读。本轮只选源码包首次使用的操作缺口：未构建核心、尚未准备输入时，希望查询工具本身的参数、输入/编码要求、退出码及模型边界。before独立--help只得到stderr usage/退出2，未把这称为旧分析契约或时序bug。Moon CLI官方help处理/委派和Node固定v24.11.0官方帮助说明表明此功能已有通用先例；不宣传新STA能力或首创。

仅在恰好一个--help参数时进入帮助分支，跳过两路径要求；先注册原stdout错误监听，直接打印静态帮助，不加载CJS核心、不读输入、不等待EOF，也不用process.exit0截断输出。普通分析体仅置于另一分支并缩进，原UTF-8辅助函数、stdout监听、核心调用、JSON输出及0/3/4映射/catch保留。usage列出新增独立形式；混合分析prefix中的--help仍报参数错误，两文件位置中的字面--help仍是原文件路径。

after六个真实CLI调用一次通过：产品帮助0；复制到本轮source-only/tools的同一脚本、没有_build且stdin生产端仍打开时帮助0；帮助接收端关闭时一行stdout EPIPE诊断/退出2；字面--help库文件普通分析0；字面--help请求文件部分覆盖检查4；混合help/检查prefix保持usage2。两个成功帮助stdout逐字节相同，共1323字节，包含既有flags、单JSON/EOF/UTF8/BOM、默认负slack语义、检查与错误退出码、构建命令、模型限制及README/例程指引。两份分析完整JSON与19轮冻结报告一致，原输入及复制脚本SHA保持。

本轮共7次实际CLI调用（before1、after6），其中实际时序分析仅2次；帮助输出错误验证是新增分支，未重跑21轮七个分析/管道消费者。没有重复23轮并列链、22轮编码矩阵、旧MoonBit/OpenSTA或三端核心测试，没有新增镜像单元测试或重编译。29条root声明、两个JS签名与四个编译产物身份保持；输入UTF-8/BOM和健康退出3等旧规则按未改代码/冻结证据保留，不冒称额外运行。

README与17行功能提案说明源码阶段可查帮助、分析仍须构建，SOURCES标明原创CLI帮助。初次GitHub前导dash查询422及web连接失败保留，随后plain help查询和官方GitHub文档读取成功；这些研究错误不计为产品失败或通过测试。既有product/.mooncakes只读核位置，无SDK/依赖工具或缓存写入。

证据在reports/liberty/deep-repair-24-max-20261028：RESEARCH/DESIGN及研究原始返回、HELP-BEFORE/CONSUMERS、cases/source-only与原始stdout/stderr、commands/logs、源码/编译/API身份及新ZIP逐项CRC/SHA读回。未增加版本/机器帮助格式、短flag、格式解析器、模型能力或下游落盘保证；23轮封存件只读，未发布、推送、赛事提交或改SDK/账号/作者。

## 2026-10-28 有限审查 25：Unicode精确绑定与JSON写法

先核24轮冻结RESULT/ZIP、67源码/四编译身份与6个帮助消费者证据，旧集合只读。本轮针对已公开的原始名称/不规范化契约，选一个具体消费者场景：外观等价的é（U+00E9）和e加组合重音（U+0065/U+0301）分别代表两个真实信号，SDC值与报告身份不能合并。局部实现检查未建立缺陷；Unicode UAX15、RFC8259字符串比较、MoonBit官方String接口及OpenSTA名称适配研究见RESEARCH，未声称OpenSTA实际运行此Unicode案例，也不加规范化器或新开关。

新建两个直连数据net，各有一输入/一输出；输入名称带slash，输出带tilde及花括号标量[0]。两对原始名称分别规范化到NFC后相同，但原始codepoint/UTF-8不同，独立Python unicodedata核验且码点表保留。两net固定SI电容2^-40、2^-39F，给两套不同delay/slew/输出offset，再交换SDC赋值；因此名称保真还必须伴随不同数值的正确绑定。报告内派生库仅改time_unit1ns->1s，不查询表、不增加NLDM精度声明。

四次新的真实CLI调用一次通过：基础/交换两套绑定，各用直接UTF-8与全ASCII JSON转义写法。独立json.loads确认每组两种写法解码对象相同、原字节SHA不同。Fraction预期：快路径rise/fall slack13/8、11/8秒，慢路径-1/4、-1/2秒；各例2端点/4已约束沿、2违例沿/1违例端点、WNS-1/2秒、检查退出3。budget均Complete、下界5/2秒、频率2/5Hz一次舍入；唯一Fall限制及违例端点随约束交换移动到另一个原始名称，没有按外观合并。

全部32条data node记录的arrival/slew/load/contributor和16条端点记录的arrival/required/slack按独立预期通过，32个端点路径引用均落到正确原始source/target身份。报告只按既有~和/规则转义，可逆且组合字符保留。两组直接/转义写法的完整JSON逐字段一致，无需排序或规范化报告。请求/派生库原字节SHA保持，原始stdout/stderr及独立预期保存。

未发现需要修复的运行时代码；README已准确说明不做Unicode规范化，17行功能提案和既有例程仍准确，原字节保留。仅在此记录真实有限证据，不将编码/帮助/周期并列等旧结果计作本轮运行。未重跑24轮6消费者、旧UTF-8/管道/OpenSTA/核心套件，没有新增镜像单元测试、编译或SDK/依赖工具/缓存写入。root29声明、两个JS入口与四个编译产物身份保持；source-only帮助等旧策略依据未改源码/冻结证据保留。

证据在reports/liberty/deep-repair-25-max-20261028：RESEARCH/REVIEW-PLAN、CASE-PROVENANCE与码点/独立Fraction预期、cases/consumer原始输出、UNICODE-REVIEW、commands/logs、源/编译/API身份及新ZIP逐项CRC/SHA读回。此为固定名称对/图/两种JSON写法的有限审查，不承诺任意Unicode/SDC/电路覆盖、不新增模型或下游落盘证明。24轮封存件只读，未发布、推送、赛事提交或改SDK/账号/作者。
