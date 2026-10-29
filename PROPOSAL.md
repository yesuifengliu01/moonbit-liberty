# MoonBit STA：单时钟门级时序分析与CI检查

MoonBit STA（项目liberty，账号yesuifengliu01）将Liberty、已映射标量网表和受限SDC转为可解释的建立时间报告、周期预算与CI判定。
面向MoonBit EDA工具作者、课程实验和时序检查脚本，支持程序内调用及JSON流水线，用于定位受限模型中的约束缺口、负裕量和限制周期的端点。

已完成的核心功能：

- 输入与约束：读取Liberty及标量JSON网表；受限SDC支持单时钟、输入/输出延迟、输入及时钟转换时间、负载、理想时钟延迟和建立时间不确定度，不执行Tcl。追加源位置诊断入口及三文件检查器，以UTF-16行列/offset定位失败命令，保留旧解析API和错误；检查约束绑定，不代替完整STA图校验。
- 图与负载：校验身份、方向、驱动和实际组合环，按输出依赖处理多输出单元，聚合线电容、输入引脚电容及外部负载；寄存器反馈可合法切开。
- 双沿传播：复用上游标量/1D/2D NLDM查表，计算上升/下降沿到达与转换时间，多弧及non_unate保守展开；越界可外推、拒绝或钳位，采用集中电容、零线电阻/延迟。
- 顺序路径：支持单上升沿、无异步置复位的D/CLK/Q触发器，计算时钟到输出延迟及建立时间，覆盖PI→PO、PI→D、Q→PO、Q→D四类路径。
- 可解释报告：输出各引脚/沿的到达时间、转换时间、驱动网总负载、端点要求时间、裕量及逐弧路径；时间为秒、电容为法拉，未约束沿的裕量不补零，名称可逆转义且不做Unicode规范化。可选因果上下文把缺失arrival端点追到一条实际接受弧上的输入端口/边沿见证，保留SI弧延迟和DFF时钟发射边界；不枚举全部缺失来源或新增路径覆盖认证，默认报告与数学保持。
- 周期预算：固定非周期参数，给逐端点周期下界与限制沿；仅在约束覆盖完整、存在正下界且频率可表示时给整体频率，保留覆盖不足和无正限制等状态。
- 指定路径：一个原始名的 PI/Q 到 PO/D 边沿查询，即使来源在全局汇合处落选，仍返回该来源的一条最晚路径及明确命名的查询 arrival/slack。复用原 GBA slew/负载/已接受弧权和捕获约束，保留 Q 发射边界；NoPath、UnconstrainedLaunch 不补零。提供独立 typed/JSON/四文件入口和自编公开包/文件接收链；不作路径相关 slew 重算，不把查询值当全局 WNS。
- Pin电气上限：用完整原GBA的pin slew和输出全负载核对已声明的标量max_transition/max_capacitance及缺省transition上限，输出逐规则/pin/edge的SI实际值、上限、余量和声明来源。缺失/无效上限不补零、不新增旧输入拒绝；单独typed/JSON/三文件checker可区分setup Met但电气超限的设计。范围包含已支持FF的CLK/D/Q，保留原时序、范围策略和诊断；不新增时序模型或完整签核规则。
- 设计用量与面积：仅用现有Liberty和已映射Netlist统计全部flat实例、每种已用单元及声明面积，不要求SDC/时序单位或执行GBA。提供完整逐实例绑定、分组贡献、缺失/无效/未映射覆盖、有限已知小计和完整总量；未知数据不补零，算术溢出显式报告。typed/JSON/两文件入口与独立公开包、实际文件接收门禁齐备；面积保持库声明单位，Complete不等于连接、PPA或时序签核。
- 摘要与CI：统计端点/沿、违例、最坏裕量和WNS；显式检查Met退出0、违例3、覆盖不足或空端点4、输入/输出错误2；普通分析保留负裕量报告。

主实现为MoonBit的图、约束、传播和报告API，可复用STAEngine/STAResult；JS适配调用同一核心，Node仅承担文件/stdin、严格UTF-8与单首BOM输入、帮助和退出策略。可选Netlist字段诊断保留原错误并返回0-based语义JSON Pointer，附独立文件检查器；仅检查既有结构，不代替图/数值/时序校验，旧分析和SDC入口保留。
最短分析例：装好MoonBit与Node后，在项目根依次执行 `moon update`、`moon build --target js --release`、`node tools/sta.cjs --check-setup examples/sky130-demo.lib examples/setup-check-met.json`，得到完整JSON及Met摘要、退出0；`--help`无需构建。

与成熟OpenSTA功能有重叠，本项目提供限定模型下可嵌入MoonBit的接口、显式覆盖解释和JSON消费链。独立贡献是图校验、SI负载、弧级双沿传播、触发器适配、短约束精确累加后一次舍入、周期预算与摘要；未重写上游Liberty解析器。
完成度由JS、原生及Wasm-GC相关回归、真实Node消费者及固定OpenSTA 2.0.17对照支持，涉及四类路径、真实Sky130触发器、单位/名称、数值与覆盖边界。证据适用于已列模型和样例，不代表生产签核或赛事验收；可复现用法与依据见README、VALIDATION。
不支持保持时间、多/异步时钟、锁存器、RC/OCV、完整Tcl/Verilog、向量系统或TNS；用量统计不展开层次、校验pin连接或换算物理面积。输入不自动识别其他编码，成功写出也不证明下游持久化。相关局部检查与必需完整CI区分列在CI-PLAN.md，历史外部参考不重复计作新证据。

项目仓库：[yesuifengliu01/moonbit-liberty](https://github.com/yesuifengliu01/moonbit-liberty)，模块 `yesuifengliu01/sta`。实际复用仓库为[SongYZZZ/moon-liberty](https://github.com/SongYZZZ/moon-liberty) 0.4.1，解析/模型/查表及原作者NOTICE均保留。
根LICENSE为Apache-2.0，上游同许可；[Sky130数据仓库](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd)亦按Apache-2.0附独立许可和来源。OpenSTA以GPL-3.0-or-later外部进程验证，不作为运行时组件随包分发。
