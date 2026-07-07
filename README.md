# MoonBench（月衡）

[![CI](https://github.com/jackeyloveseven/moonbench/actions/workflows/ci.yml/badge.svg)](https://github.com/jackeyloveseven/moonbench/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)
[![MoonBit](https://img.shields.io/badge/language-MoonBit-brightgreen)](https://www.moonbitlang.com)

MoonBench（月衡）是一个面向 MoonBit 开源生态的 **benchmark 工具库**，提供纳秒级计时、统计分析、性能回归对比、算法复杂度基准，以及一个开箱即用的静态 Web Dashboard。

> 适用场景：算法库性能验证 · CI 回归防护 · 教学代码耗时演示 · 数据结构对比基准

---

## 核心能力

| 模块 | 功能 |
|---|---|
| `Duration` / `Stopwatch` | 纳秒级时长类型、确定性秒表，支持跨后端移植和测试注入 |
| `Samples` / `Stats` | 多次样本存储 + min/max/mean/median/p95/p99/stddev/MAD/RSD 统计 |
| `BenchmarkRunner` | 注册 `() -> Unit` 工作负载，自动 warmup / measure / batch 执行 |
| `CalibrationPolicy` | probe 自动选 batch size，防止短 workload 被计时噪声淹没 |
| `BenchmarkLifecycle` | suite / case / measurement 三层 hooks（setup / teardown / before / after）|
| `Comparison` / `RegressionRule` | baseline 与 candidate 对比，输出 pass / warn / fail CI gate |
| `TrendReport` | 多次运行的趋势分析，识别 improved / regressed / flat |
| `BenchmarkArtifact` | 输出 Markdown / CSV / JSON 发布产物 |
| **`algo/`** | **17 个经典 CS 算法实现，每个 benchmark 运行 20 次，附理论时空复杂度标注** |
| **Web Dashboard** | **纯静态 UI：suite health、均值图、样本曲线、算法复杂度徽章，中英双语** |

---

## 算法复杂度基准（`algo/` 包）

内置 17 个经典算法的 MoonBit 实现，config: warmup=5 / measure=20，输出含 `algo_meta` 的 JSON，Web UI 按类别分组展示彩色复杂度徽章。

| 类别 | 算法 | 时间 | 空间 |
|---|---|---|---|
| 排序 | 冒泡排序 / 插入排序 | O(n²) | O(1) |
| 排序 | 快速排序 / 归并排序 / 堆排序 | O(n log n) | O(log n)~O(n) |
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

---

## 快速开始

```bash
moon check
moon test
moon run webui        # 生成算法 benchmark JSON
```

本地预览 Web Dashboard：

```bash
python3 -m http.server 4173 --directory webui
# 访问 http://127.0.0.1:4173/
```

---

## 使用示例

### 基础：Samples + BenchmarkSuite

```moonbit
let baseline = Samples::new("baseline")
  .add(Duration::from_micros(120L))
  .add(Duration::from_micros(118L))

let candidate = Samples::new("candidate")
  .add(Duration::from_micros(92L))
  .add(Duration::from_micros(90L))

let suite = BenchmarkSuite::new("demo")
  .with_config(BenchmarkConfig::default().with_measure_runs(4))
  .add_samples(baseline)
  .add_samples(candidate)
  .finish()

println(suite.to_report().render_markdown())
```

### Runner：注册真实工作负载

```moonbit
let suite = BenchmarkRunner::new("my suite")
  .with_config(BenchmarkConfig::default().with_warmup_runs(3).with_measure_runs(10))
  .add_task(BenchmarkTask::new("array/sort/int-10k", fn() {
    // 你的 MoonBit 工作负载
  }).with_batch_size(32))
  .run()

println(suite.to_report().render_markdown())
```

`run()` 使用 monotonic backend 真实计时；测试场景可用 `MeasurementBackend::scripted` 注入确定性耗时。

### 全链路：Runner + Gate + Artifact

```moonbit
let result = BenchmarkWorkflow::new("run-001", "candidate", runner)
  .with_backend(MeasurementBackend::monotonic())
  .with_gate_policy(GatePolicy::default())
  .run()

println(result.artifact().render_markdown())
```

---

## 项目结构

```text
moonbench/
  src/                     ← 核心库（统计、Runner、回归、报告等）
    algo_meta.mbt          ← ComplexityTag 枚举 + benchmark 名称→复杂度映射
    model.mbt              ← 19 种 benchmark 模型（13 通用 + 6 algo）
    web_data.mbt           ← render_web_json（含 algo_meta 字段）
    ...
  algo/                    ← 算法复杂度基准包
    sort.mbt               ← 冒泡 / 插入 / 快速 / 归并 / 堆排序
    search.mbt             ← 线性 / 二分搜索
    string_match.mbt       ← 朴素 / KMP
    graph.mbt              ← BFS / DFS / Dijkstra
    dp.mbt                 ← Fibonacci × 2 / LCS
    numeric.mbt            ← 点积 / 矩阵乘
    suite.mbt              ← algo_smoke_suite（warmup=5, measure=20）
  webui/                   ← 静态 Dashboard
    index.html / app.js / styles.css
    main.mbt               ← 输出 algo_smoke_suite JSON
  cli/                     ← CLI 入口
  deploy/                  ← Nginx + Dockerfile
  docs/                    ← 设计文档、部署指南、申报书
```

---

## CI

GitHub Actions 三平台（Ubuntu / macOS / Windows）自动运行：

- `moon check --target all`
- `moon test --target all`
- `moon fmt` + `moon info` 工作区一致性检查（Ubuntu）
- `node --check webui/app.js` 静态语法检查（Ubuntu）

---

## 许可证

[Apache-2.0](LICENSE)
