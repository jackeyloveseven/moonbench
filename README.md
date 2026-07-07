# MoonBench（月衡）

MoonBench（月衡）是一个面向 MoonBit 开源生态的 deterministic benchmark / stopwatch 工具库。它用于记录耗时样本、计算统计指标、生成报告，并对 baseline 与 candidate 做性能回归判断。

本项目选择赛事推荐方向里的 **Stopwatch / benchmark 小工具**。这个方向边界清晰、真实可复用，适合算法库、数据结构库、编译器练习项目、CI 性能回归检查和教学代码。

## 名字

项目名叫 **MoonBench（月衡）**。英文名表达 MoonBit benchmark 工具库；中文名“月衡”表示对 MoonBit 程序性能进行轻量、稳定的衡量。


## 检测对象

MoonBench 检测的是 **MoonBit 项目中可被重复执行的代码片段或库操作**。它本身不是只检测 MoonBench 自己，而是提供 benchmark 数据模型、统计、回归判断、报告和 Web UI；用户把自己的样本或 runner 结果喂给它。

为了开箱即用，项目内置了一个 default smoke suite，覆盖 MoonBit 生态里常见的基础负载：

- `array-sort` / `array/sort/int-10k`：数组排序和顺序数据处理。
- `string-scan` / `string/scan/ascii-64k`：字符串扫描、遍历、文本处理。
- `collection-lookup` / `collection/map-lookup/50k`：Map/Set 类集合查询。
- `parser` / `parser/json-like/32k`：结构化文本解析。
- `codec` / `codec/csv-encode/10k`：CSV / 文本编码输出。
- `graph` / `graph/bfs/grid-128`：图遍历和路径类算法基础负载。
- `numeric` / `numeric/arithmetic-loop/1m`：整数、浮点和紧循环计算。
- `hashing` / `hashing/bytes-64k`：哈希计算和 digest 风格字节遍历。
- `memory` / `memory/alloc-small/10k`：小对象分配和短生命周期缓冲区。
- `bytes` / `bytes/copy-64k`：字节复制、切片、扫描和缓冲区移动。
- `tensor-matmul` / `tensor/matmul/f32-64x64`：神经网络层常用的稠密张量矩阵乘。
- `nn-activation` / `nn/activation/relu-1m`：ReLU/GELU/softmax 风格的前向逐元素算子。
- `attention` / `attention/softmax-head-128`：scaled dot-product attention、softmax 和 head 级权重负载。

这些默认项不是最终性能结论，而是 smoke benchmark：用于验证工具链、报告链路、统计稳定性和 Web UI 展示。正式使用时，用户应把自己的 MoonBit 函数、库操作或 CI 采样结果接入 `Samples` / `BenchmarkSuite`。

## 当前功能

- `Duration`：纳秒级时长类型，支持 ns / us / ms / s 构造、换算、格式化和差值计算。
- `Stopwatch`：确定性秒表模型，由调用方传入 tick，便于测试和跨后端移植。
- `Samples`：存储一次 benchmark 的多次耗时样本，并支持 percentile 和去掉最大/最小值。
- `Stats`：计算 min / max / mean / median / p90 / p95 / p99 / stddev / variance / MAD / relative stddev。
- `BenchmarkConfig`：描述 warmup 次数、测量次数、噪声阈值、输出单位和样本裁剪策略。
- `BenchmarkSuite` / `SuiteResult`：组织一组 benchmark 结果，生成统一报告。
- `BenchmarkRunner` / `BenchmarkTask`：注册 `() -> Unit` 工作负载，自动 warmup、measure、batch 执行和样本收集。
- `MeasurementBackend`：支持 monotonic 真实计时，以及 fixed/scripted 确定性测试后端。
- `CalibrationPolicy` / `CalibrationReport`：通过 probe 自动选择 batch size，避免短 workload 被计时噪声淹没。
- `BenchmarkLifecycle` / `LifecycleRunSummary`：支持 suite/case/measurement 级 setup、teardown、before、after hooks，并记录事件日志。
- `SuiteAssessment` / `BenchmarkAssessment`：对稳定性、RSD 和 outlier 做诊断。
- `GatePolicy` / `GateReport`：把诊断和历史回归对比转成 CI gate 结果。
- `BenchmarkArtifact`：封装一次 benchmark 运行的 Markdown / CSV / JSON 发布产物。
- `BenchmarkWorkflow`：串起 runner、backend、assessment、gate 和 artifact，形成全链路 benchmark。
- `BaselineManifest` / `BenchmarkSnapshot`：把一次运行浓缩成可归档 baseline 清单，记录 mean、median、p95、RSD 和稳定性诊断。
- `TrendReport` / `TrendSeries`：把多次 baseline manifest 组合成趋势报告，识别 improved / regressed / flat。
- `BenchmarkRunPlan`：提供 smoke / CI / release 三类运行计划，关联默认模型、配置、校准策略和预计执行次数。
- `Comparison`：比较 baseline 与 candidate，判断 faster / slower / similar。
- `RegressionRule`：按性能下降阈值输出 pass / warn / fail，适合 CI 使用。
- `Report`：输出 Markdown、CSV、plain text 和 JSON-like 文本报告。
- `OutlierSummary`：使用 IQR fence 识别 mild / severe 离群值。
- `MetricSet` / `Throughput`：记录自定义指标和吞吐量，适合 ops/s、bytes/s、allocs/op。
- `ParameterSet` / `ParameterSweep`：表达参数化 benchmark，例如 size=small/medium/large。
- `HistoricalRun`：保存一次运行的统计快照，并按 benchmark 名称与历史 baseline 对比。
- `BenchmarkModel`：默认支持 array-sort、string-scan、collection-lookup、parser、codec、graph、numeric、hashing、memory、bytes、tensor-matmul、nn-activation、attention 十三类 + algo 六类共十九种 benchmark 模型。
- `ComplexityTag` / `AlgoMeta`：枚举时空复杂度标注（O(1) / O(log n) / O(n) / O(n log n) / O(n²) / O(n³) / Custom），并把 benchmark 名称映射到理论复杂度元数据。
- `algo/` 包：17 个经典算法实现（冒泡 / 插入 / 快速 / 归并 / 堆排序、线性 / 二分搜索、朴素 / KMP 字符串匹配、BFS / DFS / Dijkstra、Fibonacci 迭代与 memoized、LCS、点积、矩阵乘），每个 benchmark 运行 20 次，附理论复杂度标注。
- `algo_smoke_suite`：算法复杂度 benchmark 套件，warmup=5 / measure=20，覆盖排序、搜索、字符串、图、动态规划和数值六大类别。
- `default_smoke_suite`：内置默认检测对象，覆盖数组、字符串、集合、解析、编码、图、数值、哈希、内存、字节处理、张量矩阵乘、神经网络激活算子和 attention。
- `SuiteResult::render_web_json`：输出稳定 schema 的 Web UI 数据，包含统计值、原始样本和 outlier 摘要；algo benchmark 额外携带 `algo_meta` 字段（类别、时间复杂度、空间复杂度）。
- `webui/`：纯静态 benchmark dashboard，支持中英文切换、加载 JSON、查看 suite health、概要指标、均值图、样本曲线、attention heatmap、明细表、stable/watch/review 信号和 CSV 导出；另含 **算法复杂度基准** 版块，按类别分组展示 17 种算法的均值和彩色复杂度徽章。
- `deploy/`：提供 Nginx 配置和 Dockerfile，可直接部署静态 Web UI。

## 项目结构

```text
moonbench/
  moon.mod
  src/
    duration.mbt
    stopwatch.mbt
    samples.mbt
    stats.mbt
    config.mbt
    suite.mbt
    compare.mbt
    regression.mbt
    outlier.mbt
    metric.mbt
    parameter.mbt
    history.mbt
    report.mbt
    runner.mbt
    calibration.mbt
    lifecycle.mbt
    model.mbt          ← 19 benchmark 模型（含 6 个 algo 分类）
    algo_meta.mbt      ← ComplexityTag 枚举与 AlgoMeta 映射
    assessment.mbt
    gate.mbt
    artifact.mbt
    workflow.mbt
    baseline_manifest.mbt
    trend.mbt
    run_plan.mbt
    web_data.mbt       ← render_web_json 含 algo_meta 字段
  algo/
    moon.pkg
    sort.mbt           ← 冒泡 / 插入 / 快速 / 归并 / 堆排序
    search.mbt         ← 线性 / 二分搜索
    string_match.mbt   ← 朴素 / KMP 字符串匹配
    graph.mbt          ← BFS / DFS / Dijkstra
    dp.mbt             ← Fibonacci 迭代 + memoized / LCS
    numeric.mbt        ← 点积 / 矩阵乘
    suite.mbt          ← algo_smoke_suite（20 次测量）
  cli/
    main.mbt
  webui/
    index.html         ← 含算法复杂度基准版块
    app.js             ← renderAlgoSection + 复杂度徽章 + i18n
    styles.css
    main.mbt           ← 输出 algo_smoke_suite JSON
  examples/
    sorting_samples.mbt
  deploy/
    Dockerfile
    nginx.conf
  docs/
    DESIGN.md
    DEPLOY.md
    FINAL_CHECKLIST.md
    PROJECT_APPLICATION.md
```

## 使用示例

```moonbit
let config = BenchmarkConfig::default()
  .with_measure_runs(4)
  .with_noise_threshold(2.0)

let baseline = Samples::new("baseline")
  .add(Duration::from_micros(120L))
  .add(Duration::from_micros(118L))

let candidate = Samples::new("candidate")
  .add(Duration::from_micros(92L))
  .add(Duration::from_micros(90L))

let suite = BenchmarkSuite::new("demo")
  .with_config(config)
  .add_samples(baseline)
  .add_samples(candidate)
  .finish()

println(suite.to_report().render_markdown())
```


## Runner 示例

```moonbit
let suite = BenchmarkRunner::new("my suite")
  .with_config(BenchmarkConfig::default().with_warmup_runs(3).with_measure_runs(10))
  .add_task(BenchmarkTask::new("array/sort/int-10k", fn() {
    // call your MoonBit workload here
  }).with_batch_size(32))
  .run()

println(suite.to_report().render_markdown())
```

`run()` 使用 monotonic backend 做真实计时；测试或教学场景可用 `MeasurementBackend::scripted` 注入确定性耗时。

## 全链路示例

```moonbit
let result = BenchmarkWorkflow::new("run-001", "candidate", runner)
  .with_backend(MeasurementBackend::monotonic())
  .with_gate_policy(GatePolicy::default())
  .run()

println(result.artifact().render_markdown())
```

这个链路会依次完成：注册任务、执行 warmup/measure、生成 `SuiteResult`、做稳定性诊断、执行 gate、生成 artifact。

## 运行

```bash
moon check
moon test
moon check --target all
moon test --target all
moon run cli
moon run webui
```

## CI

项目已补充 GitHub Actions：

```text
.github/workflows/ci.yml
```

CI 参考 `moonbit-community/.github` 的 workflow template，并固定 MoonBit 工具链：

```text
MOONBIT_VERSION=0.10.3+16975d007
MOONBIT_CORE_VERSION=0.10.3+16975d007
```

CI 内容：

- Ubuntu / macOS / Windows 三平台运行 `moon check --target all`。
- Ubuntu / macOS / Windows 三平台运行 `moon test --target all`。
- Ubuntu 上运行 `moon fmt`、`moon info` 并检查工作区无 diff。
- Ubuntu 上运行 `node --check webui/app.js` 检查静态 Web UI。

## Web UI

本地预览：

```bash
cd moonbench
python3 -m http.server 4173 --bind 127.0.0.1 --directory webui
```

访问：

```text
http://127.0.0.1:4173/
```

生成可加载数据：

```bash
moon run webui > webui/report-data.json
```

更多部署方式见 `docs/DEPLOY.md`。

## 许可证

Apache-2.0
