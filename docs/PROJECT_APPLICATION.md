# MoonBench（月衡）项目申报书

## 基本信息

项目名称：MoonBench（月衡）：MoonBit 生态的基准测试与性能回归工具库

参赛者：李承燕

联系方式：19907288937

GitHub 仓库链接：https://github.com/jackeyloveseven/moonbench

Gitlink 仓库链接：https://gitlink.org.cn/jackeylove7/moonbench

项目方向：MoonBit 工程基础设施 / Stopwatch 与 benchmark 工具 / CI 性能回归检查

是否为移植项目：原创项目，参考成熟 benchmark 工具设计

参考项目：

- Criterion.rs：https://github.com/bheisler/criterion.rs，许可证 Apache-2.0 / MIT
- hyperfine：https://github.com/sharkdp/hyperfine，许可证 Apache-2.0 / MIT
- pytest-benchmark：https://github.com/ionelmc/pytest-benchmark，许可证 BSD-2-Clause
- github-action-benchmark：https://github.com/benchmark-action/github-action-benchmark，许可证 MIT

本项目许可证：Apache-2.0

---

## 项目简介

MoonBench（月衡）是一个面向 MoonBit 开源生态的 benchmark 工具库，用于记录 MoonBit 程序的耗时样本、计算统计指标、生成报告，并在 CI 中判断性能回归。项目同时内置了一个算法复杂度基准模块（`algo/`），用 MoonBit 实现了 17 个经典 CS 算法，每个 benchmark 运行 20 次，结合理论时空复杂度标注，并在 Web Dashboard 中按类别展示。

适用场景：算法库性能验证、数据结构对比基准、解析器与编译器练习、CI 性能回归检查、教学代码耗时演示。

---

## 核心功能范围

**基础时间与统计**

- `Duration`：纳秒级时长类型，支持 ns / us / ms / s 构造、换算、格式化、差值计算。
- `Stopwatch`：确定性秒表，由调用方传入 tick，支持跨后端移植和测试注入。
- `Samples`：存储多次耗时样本，支持 percentile 计算和样本裁剪。
- `Stats`：计算 min / max / mean / median / p90 / p95 / p99 / stddev / variance / MAD / relative stddev。

**Runner 与 Suite**

- `BenchmarkConfig`：描述 warmup 次数、测量次数、噪声阈值和样本裁剪策略。
- `BenchmarkSuite` / `SuiteResult`：组织多组 benchmark 结果，生成统一报告。
- `BenchmarkRunner` / `BenchmarkTask`：注册 `() -> Unit` 工作负载，自动 warmup / measure / batch 执行，支持 monotonic 真实计时。
- `CalibrationPolicy` / `CalibrationReport`：probe 自动选择 batch size，减少短任务计时噪声。
- `BenchmarkLifecycle`：suite / case / measurement 三层 hooks（setup / teardown / before / after），记录生命周期事件。

**分析与回归**

- `OutlierSummary`：IQR fence 识别 mild / severe 离群值。
- `SuiteAssessment` / `BenchmarkAssessment`：稳定性、RSD 和 outlier 诊断。
- `Comparison` / `RegressionRule`：baseline 与 candidate 对比，输出 faster / slower / similar 及 pass / warn / fail CI gate。
- `GatePolicy` / `GateReport`：诊断结合历史回归对比，转成 CI 门禁结果。

**报告与产物**

- `Report`：输出 Markdown / CSV / plain text / JSON 报告。
- `BenchmarkArtifact`：封装单次运行的 Markdown / CSV / JSON 产物。
- `BaselineManifest` / `BenchmarkSnapshot`：浓缩单次运行为可归档 baseline 清单。
- `TrendReport` / `TrendSeries`：多次运行趋势，识别 improved / regressed / flat。
- `BenchmarkRunPlan`：内置 smoke / CI / release 三类运行计划。

**模型与元数据**

- `BenchmarkModel`：19 种 benchmark 模型，涵盖 array-sort、string-scan、collection-lookup、parser、codec、graph、numeric、hashing、memory、bytes、tensor-matmul、nn-activation、attention 十三类通用模型，以及 algo-sort、algo-search、algo-string、algo-graph、algo-dp、algo-numeric 六类算法模型。
- `ComplexityTag` / `AlgoMeta`：枚举时空复杂度标注（O(1) / O(log n) / O(n) / O(n log n) / O(n²) / O(n³) / Custom），将 benchmark 名称映射到理论复杂度元数据。

**算法复杂度基准（`algo/` 包）**

- 用 MoonBit 原生实现 17 个经典 CS 算法，分六大类：
  - 排序：冒泡 / 插入 / 快速 / 归并 / 堆排序
  - 搜索：线性搜索 / 二分搜索
  - 字符串匹配：朴素 / KMP
  - 图算法：BFS / DFS / Dijkstra
  - 动态规划：Fibonacci 迭代 + memoized / LCS
  - 数值计算：向量点积 / 矩阵乘
- `algo_smoke_suite`：warmup=5 / measure=20，输出含 `algo_meta` 字段（类别、时间复杂度、空间复杂度）的 Web JSON。

**Web Dashboard**

- 纯静态 HTML/CSS/JS，无服务端依赖。
- 支持中英文切换、JSON 加载与导出、suite health、概要指标、均值图、样本曲线、attention heatmap、明细结果表、stable/watch/review 信号和 CSV 导出。
- 新增**算法复杂度基准**版块：按排序 / 搜索 / 字符串 / 图 / 动态规划 / 数值六类分组，展示 17 个算法的均值和彩色复杂度徽章（绿=线性及以下 / 黄=多项对数 / 红=二次及以上）。

**部署与 CI**

- `deploy/`：Nginx 配置 + Dockerfile，可直接部署静态 Web UI。
- GitHub Actions CI：Ubuntu / macOS / Windows 三平台 `moon check --target all` + `moon test --target all`；Ubuntu 额外执行 `moon fmt` / `moon info` 格式检查、`moon run cli` 冒烟测试、`moon run webui` 输出正确性验证（断言 17 个算法 benchmark）；`node --check webui/app.js` 静态语法检查。
- GitHub Pages：push to main 自动部署 Web Dashboard。

---

## 原创或参考说明

本项目为原创实现，不直接移植任何单一项目代码。设计参考 Criterion.rs、hyperfine、pytest-benchmark 和 github-action-benchmark 的功能边界（多次采样、warmup/measure 分离、batch size 校准、outlier 检测、baseline 对比、CI regression gate、JSON/CSV/Markdown 报告、历史趋势分析、可视化报告）。

与参考项目相比，MoonBench 的 MoonBit 化设计包括：

- 使用 MoonBit 原生包结构、类型系统和测试方式组织代码。
- 以 MoonBit 函数级 / 库级 benchmark 为主要目标，而不是命令行程序测速。
- 提供 deterministic backend 和 scripted backend，方便测试和教学。
- 使用 MoonBit core bench 的 monotonic clock 做真实计时。
- 内置经典 CS 算法的 MoonBit 实现 + 理论复杂度标注，作为算法学习与性能直觉建立的参考基准。
- 通过静态 Web Dashboard 直接展示 MoonBit benchmark JSON，含复杂度徽章可视化。
- 面向 MoonBit 生态补齐 benchmark、CI 性能回归和报告基础设施。

---

## 当前交付状态

项目已完成核心库、算法复杂度基准模块、默认 benchmark 模型、runner、统计分析、CI gate、baseline manifest、trend report、Web JSON、Web Dashboard、部署文件和 CI 配置。

代码规模：严格 `.mbt` 源码超过 7000 行，含 `algo/` 包实现及套件。已通过：

```text
moon check --target all
moon test --target all
moon run cli
moon run webui  （输出含 17 个算法 benchmark 的 JSON，含 algo_meta 字段）
node --check webui/app.js
```

GitHub Actions CI 三平台绿色，GitHub Pages 自动部署 Web Dashboard。

后续计划继续补充文件持久化 baseline、真实 baseline 加载、CI exit-code CLI、更多图表和 async benchmark runner。
