# MoonBench（月衡）项目申报书

## 基本信息

| 字段 | 内容 |
|---|---|
| 项目名称 | MoonBench（月衡）：MoonBit 生态的基准测试与性能回归工具库 |
| 参赛者 | 李承燕 |
| 联系方式 | 19907288937 |
| GitHub | https://github.com/jackeyloveseven/moonbench |
| Gitlink | https://gitlink.org.cn/jackeylove7/moonbench |
| 项目方向 | MoonBit 工程基础设施 / Stopwatch 与 benchmark 工具 / CI 性能回归检查 |
| 是否移植 | 原创项目，参考成熟 benchmark 工具设计（见下方说明） |
| 许可证 | Apache-2.0 |

参考项目（仅设计参考，未复制代码）：

- Criterion.rs（Apache-2.0 / MIT）：https://github.com/bheisler/criterion.rs
- hyperfine（Apache-2.0 / MIT）：https://github.com/sharkdp/hyperfine
- pytest-benchmark（BSD-2-Clause）：https://github.com/ionelmc/pytest-benchmark
- github-action-benchmark（MIT）：https://github.com/benchmark-action/github-action-benchmark

---

## 项目简介

MoonBench（月衡）是一个面向 MoonBit 开源生态的 **benchmark 工具库**。它提供纳秒级计时、统计分析、性能回归判断、报告生成和 Web Dashboard，用户可以将任意 MoonBit 函数或库操作接入同一套工具链，持续追踪性能变化。

项目内置两类 benchmark 数据：

1. **默认 smoke suite**：涵盖数组、字符串、集合、解析、编码、图算法、数值、哈希、内存、字节处理、张量矩阵乘、神经网络激活算子、attention 等 MoonBit 生态常见负载类型的**演示样本**，用于验证工具链和 Web UI 展示效果，不代表真实 MoonBit 实现的性能数据。
2. **算法复杂度基准（`algo/` 包）**：用 MoonBit 实现的 17 个经典 CS 算法，真实可运行，每个 benchmark 运行 20 次，附理论时空复杂度标注，在 Web Dashboard 中按类别展示彩色徽章。

---

## 核心功能

### 基础时间与统计

- `Duration`：纳秒级时长，支持 ns / us / ms / s 构造、换算、格式化、差值计算。
- `Stopwatch`：确定性秒表，由调用方传入 tick，便于测试和跨后端移植。
- `Samples`：多次耗时样本存储，支持 percentile 计算与样本裁剪。
- `Stats`：min / max / mean / median / p90 / p95 / p99 / stddev / variance / MAD / relative stddev。

### Runner 与 Suite

- `BenchmarkConfig`：warmup 次数、测量次数、噪声阈值、样本裁剪策略。
- `BenchmarkSuite` / `SuiteResult`：组织多组结果，生成统一报告。
- `BenchmarkRunner` / `BenchmarkTask`：注册 `() -> Unit` 工作负载，自动 warmup / measure / batch 执行，支持 monotonic 真实计时。
- `CalibrationPolicy` / `CalibrationReport`：probe 自动选择 batch size，减少短任务计时噪声。
- `BenchmarkLifecycle`：suite / case / measurement 三层 hooks，记录生命周期事件。

### 分析与回归

- `OutlierSummary`：IQR fence 识别 mild / severe 离群值。
- `SuiteAssessment` / `BenchmarkAssessment`：稳定性、RSD 和 outlier 诊断，输出 stable / watch / review。
- `Comparison` / `RegressionRule`：baseline 与 candidate 对比，输出 faster / slower / similar 及 pass / warn / fail。
- `GatePolicy` / `GateReport`：把诊断结果转成 CI 门禁决策。

### 报告与产物

- `Report`：Markdown / CSV / plain text / JSON 报告。
- `BenchmarkArtifact`：封装单次运行的 Markdown / CSV / JSON 产物。
- `BaselineManifest` / `BenchmarkSnapshot`：可归档 baseline 清单（mean、median、p95、RSD、稳定性）。
- `TrendReport` / `TrendSeries`：多次运行趋势分析，识别 improved / regressed / flat。
- `BenchmarkRunPlan`：内置 smoke / CI / release 三类运行计划。

### 模型与元数据

- `BenchmarkModel`：19 种 benchmark 类别描述符，作为 benchmark 结果的分组和展示标签，涵盖 array-sort、string-scan、collection-lookup、parser、codec、graph、numeric、hashing、memory、bytes、tensor-matmul、nn-activation、attention 十三类通用类别，以及 algo-sort、algo-search、algo-string、algo-graph、algo-dp、algo-numeric 六类算法类别。
- `ComplexityTag` / `AlgoMeta`：时空复杂度枚举（O(1) ~ O(n³) / Custom），将 benchmark 名称映射到理论复杂度元数据。

### 算法复杂度基准（`algo/` 包）

用 MoonBit 原生实现 17 个经典 CS 算法，每个均有单元测试，可通过 `moon test` 验证正确性：

| 类别 | 算法 | 时间复杂度 | 空间复杂度 |
|---|---|---|---|
| 排序 | 冒泡排序 / 插入排序 | O(n²) | O(1) |
| 排序 | 快速排序 / 归并排序 / 堆排序 | O(n log n) | O(log n)～O(n) |
| 搜索 | 线性搜索 | O(n) | O(1) |
| 搜索 | 二分搜索 | O(log n) | O(1) |
| 字符串 | 朴素匹配 | O(nm) | O(1) |
| 字符串 | KMP | O(n+m) | O(m) |
| 图 | BFS / DFS | O(V+E) | O(V) |
| 图 | Dijkstra | O(V²) | O(V) |
| 动态规划 | Fibonacci 迭代 / memoized | O(n) | O(1) / O(n) |
| 动态规划 | LCS | O(mn) | O(mn) |
| 数值 | 向量点积 | O(n) | O(1) |
| 数值 | 矩阵乘 | O(n³) | O(n²) |

`algo_smoke_suite`：warmup=5 / measure=20，每个 benchmark 输出含 `algo_meta` 字段的 Web JSON。

### Web Dashboard

纯静态 HTML/CSS/JS，无服务端依赖。功能：

- 中英文切换、JSON 加载与 CSV 导出。
- Suite health、概要指标卡（用例数、最快/最慢均值、最高噪声、离群样本）。
- 均值横向柱状图、样本时序曲线、attention 权重热力图（演示可视化）。
- 结果明细表，每行附 stable / watch / review 信号。
- **算法复杂度基准**版块：按六大类别分组，展示 17 个算法的均值和彩色复杂度徽章（绿 = O(1)～O(n)、黄 = O(n log n)～O(mn)、红 = O(n²) 及以上）。

### 部署与 CI

- `deploy/`：Nginx 配置 + Dockerfile，直接部署静态 Web Dashboard。
- GitHub Actions CI：Ubuntu / macOS / Windows 三平台 `moon check --target all` + `moon test --target all`；Ubuntu 额外执行格式检查（`moon fmt`）、包元数据检查（`moon info`）、CLI 冒烟测试（`moon run cli`）、algo 套件输出正确性验证（断言 17 个 benchmark）、Web UI 语法检查（`node --check webui/app.js`）。
- GitHub Pages：push to main 自动部署 Web Dashboard。

---

## 原创说明

本项目为原创实现，不直接移植任何单一项目代码。参考上述工具的功能边界（多次采样、warmup/measure 分离、batch size 校准、outlier 检测、baseline 对比、CI regression gate、趋势分析、可视化报告），结合 MoonBit 语言特性重新设计实现：

- 使用 MoonBit 原生包结构、类型系统和测试框架。
- 以 MoonBit 函数级 / 库级 benchmark 为主要目标，而非命令行程序测速。
- 提供 deterministic 和 scripted 后端，便于测试和教学。
- 使用 MoonBit core bench 的 monotonic clock 做真实计时。
- 内置经典 CS 算法的 MoonBit 实现 + 复杂度标注，作为算法学习与性能直觉的参考基准。

---

## 交付状态

| 检查项 | 状态 |
|---|---|
| `moon check --target all` | 通过 |
| `moon test --target all` | 通过 |
| `moon run cli` | 通过 |
| `moon run webui`（输出 17 个算法 benchmark JSON） | 通过 |
| `node --check webui/app.js` | 通过 |
| GitHub Actions CI（Ubuntu / macOS / Windows） | 绿色 |
| GitHub Pages 自动部署 | 已启用 |
| root LICENSE 文件 | Apache-2.0 |
| 有意义提交数 | 22+ 次 |

`.mbt` 源码规模：核心库 + algo 包合计超过 7000 行。

后续计划：文件持久化 baseline 加载、CI exit-code、更多图表类型、async benchmark runner。
