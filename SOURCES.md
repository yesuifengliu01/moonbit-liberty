# 来源和许可

| 内容 | 身份/来源 | 许可与使用范围 |
| --- | --- | --- |
| 图、约束、传播、周期预算、setup 摘要、JSON API | 本项目原创 MoonBit 实现 | Apache-2.0，根 LICENSE |
| CLI 帮助、setup 检查、请求 stdin、报告写入错误、UTF-8 验证/BOM 输入与 JS 桥接 | 本项目原创 Node IO/退出策略及 MoonBit JSON 适配；复用既有摘要；字节验证与 stdin/stdout 使用 Node 标准库，Python 管道示例使用标准库 | Apache-2.0，根 LICENSE；没有复制参考工具实现、UTF-8 解析器或增加领域依赖 |
| Liberty parser / model / table | SongYZZZ/moon-liberty 0.4.1；已读提交 3f64c5a23d2572e910402a00b23ec62ba7d0a2cb，实际依赖从 Mooncakes 解析 | Apache-2.0；上游版权/NOTICE 保持；不是自研成果 |
| Sky130 HD 真实数据 | google/skywater-pdk-libs-sky130_fd_sc_hd，commit ac7fb61f06e6470b94e8afdf7c25268f62fbd7b1 | Apache-2.0；examples/SKY130-LICENSE、data-sources.json 含 URL/源文件哈希 |
| 库子集生成 | 原始 common/corner 与 inv/nand2/xor2/and2/or2/dfxtp_1 JSON，确定性转写为 Liberty | 仅序列化，没有重算表值；非完整库、非工艺资格证明；生成代码见执行回执 make-fixtures.py |
| OpenSTA | Ubuntu resolute/universe opensta_0~20191111gitc018cb2+dfsg-1.1_amd64.deb；sta 2.0.17 | GPL-3.0-or-later，外部验证进程；包 SHA256 9ec29cc74cc66cd82e6fa85aad2d3897c6315aa26adbc380892416e7a5e87a1b；独立源码包与许可存执行报告依赖目录 |
| 自编图 | chain、RCA4、sequential、four_paths、setup-summary/setup-check 标量别名图的结构与约束 | 本项目 Apache-2.0，与真实单元数据许可分开 |
| c17 | TalTech 学术镜像的 ISCAS-85 六 NAND 连接图，只作本地参考 | 原分发许可未确认；产品不携带该图。报告中保留原始来源/本地差分，不能推定为 MIT/公有领域 |

上游：https://github.com/SongYZZZ/moon-liberty

真实数据：https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd

参考：https://github.com/The-OpenROAD-Project/OpenSTA 。本期以实际固定 Ubuntu 包为数值参考，未冒称当前 master 运行结果。

没有取得 Synopsys 官方完整手册下载授权或签核认证；行为边界是本项目公开的受限 profile 和真实互操作证据。IEEE 1481 是 OLA，未用作 Liberty 格式编号。实现、规范、数据和 oracle 的许可各自独立，参考工具不作为运行时组件。
