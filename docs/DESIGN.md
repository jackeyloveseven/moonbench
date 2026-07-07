# Design Notes

MoonBench 的核心设计目标是 **确定性、可移植、可组合**。

很多 benchmark 工具会把计时、任务调度、统计和报告输出揉在一起。MoonBench 把这些职责拆开，让核心库不依赖具体运行时，也方便未来接入 native、wasm 或 JavaScript 后端。

## 模块边界

- `Duration` 只表示时长，并提供单位换算和格式化。
- `Stopwatch` 只维护开始、暂停、继续和结束状态。
- `Samples` 只收集样本，并提供基础样本变换。
- `Stats` 只从样本里计算统计指标。
- `BenchmarkConfig` 只描述 benchmark 策略，不直接执行代码。
- `BenchmarkSuite` / `SuiteResult` 只组织批量 benchmark 结果。
- `BenchmarkRunner` / `BenchmarkTask` 负责注册函数、warmup、measure、batch 执行和生成样本。
- `MeasurementBackend` 把真实计时和确定性测试计时隔离开。
- `CalibrationPolicy` / `CalibrationReport` 负责 probe、选择 batch size 和解释校准结果。
- `BenchmarkLifecycle` / `LifecycleRunSummary` 负责 suite、case、measurement 级 hook 和事件日志。
- `BenchmarkModel` 描述默认支持的 benchmark workload 模型。
- `SuiteAssessment` / `BenchmarkAssessment` 负责稳定性和 outlier 诊断。
- `GatePolicy` / `GateReport` 负责 CI 门禁，不直接关心报告渲染。
- `BenchmarkArtifact` 封装一次运行的可发布产物。
- `BenchmarkWorkflow` 只负责全链路编排，不直接实现统计细节。
- `BaselineManifest` / `BenchmarkSnapshot` 负责可归档 baseline 摘要。
- `TrendReport` / `TrendSeries` 负责跨多次 baseline 的趋势分析。
- `BenchmarkRunPlan` 负责 smoke / CI / release 三类运行计划。
- `Comparison` 只比较两组统计结果。
- `RegressionRule` 只把比较结果转成 pass / warn / fail。
- `OutlierSummary` 使用 IQR fence 给样本稳定性做诊断。
- `MetricSet` / `Throughput` 存放自定义指标和吞吐量。
- `ParameterSet` / `ParameterSweep` 表达参数化 benchmark。
- `HistoricalRun` 表达历史运行快照和跨运行对比。
- `Report` 只负责把结果渲染成 Markdown、CSV、text 或 JSON-like 文本。
- `web_data` 把 `SuiteResult` 渲染成稳定 Web JSON schema，供静态 dashboard 或外部服务消费。
- `webui` 是独立静态页面，不参与核心统计逻辑，只负责加载 JSON、展示图表和导出 CSV。
- `default_smoke_suite` 提供内置检测对象，用来验证报告链路和展示常见 MoonBit 负载类型。

## 数据流

典型流程如下：

1. 调用方决定 benchmark 配置，或选择 `BenchmarkRunPlan` 的 smoke / CI / release profile。
2. 调用方可以直接提供 `Samples`，也可以把 `() -> Unit` 注册到 `BenchmarkRunner`。
3. Runner 可通过 `CalibrationPolicy` probe 短任务并选择 batch size。
4. Runner 执行 lifecycle hooks，warm up 被测逻辑。
5. Runner 通过 `MeasurementBackend` 测量每轮耗时，并按 batch size 归一化。
6. 将耗时写入 `Samples`。
7. 把多组 `Samples` 放入 `BenchmarkSuite`。
8. `SuiteResult` 生成 `Stats` 和 `Report`。
9. `Comparison` 比较 baseline 与 candidate。
10. `RegressionRule` 判断是否通过性能门禁。
11. `SuiteAssessment` 诊断稳定性和 outlier。
12. `GatePolicy` 生成 CI gate 结果。
13. `BaselineManifest` 生成可归档 snapshot，`TrendReport` 汇总多次运行趋势。
14. `BenchmarkArtifact` 产出 Markdown / CSV / JSON。
15. `SuiteResult::render_web_json` 输出 Web UI 数据和 model metadata。
16. `webui/index.html` 在浏览器中做交互式查看，attention case 可切换到 heatmap。

当前版本同时支持“外部传入样本”和“注册函数后由 runner 测量”。真实计时使用 MoonBit core bench 的 monotonic clock；测试使用 fixed/scripted backend，保证核心行为可重复验证。


## 默认检测模型

MoonBench 的检测对象是调用方提供的 MoonBit 代码路径，不限定具体库。为了让项目开箱即用，当前提供十三类默认 benchmark model 和 default smoke suite：

- `array-sort`：代表基础算法和顺序内存访问。
- `string-scan`：代表文本处理和字符遍历。
- `collection-lookup`：代表 Map/Set 类基础数据结构访问。
- `parser`：代表结构化输入解析。
- `codec`：代表序列化和字符串构造。
- `graph`：代表图遍历和路径类算法。
- `numeric`：代表整数、浮点和紧循环计算。
- `hashing`：代表哈希计算和 digest 风格字节遍历。
- `memory`：代表小对象分配和短生命周期缓冲区。
- `bytes`：代表字节复制、切片、扫描和缓冲区移动。
- `tensor-matmul`：代表神经网络层常用的稠密张量矩阵乘。
- `nn-activation`：代表 ReLU/GELU/softmax 风格的前向逐元素算子。
- `attention`：代表 scaled dot-product attention、softmax 和 head 级权重负载。

这些默认负载的目标不是替代用户项目的真实 benchmark，而是让工具本身具备可演示、可测试、可部署的默认数据面。正式接入时，runner 应把用户自己的 MoonBit 函数测量结果写入 `Samples`，再交给同一套统计和报告管线。

Web UI 对 attention case 会把样本曲线区域切换为 8x8 attention heatmap。加载外部 JSON 时，如果提供 `attention_matrix` 字段，页面会直接使用该矩阵；否则会为 attention case 生成默认示例矩阵。

## 统计策略

MoonBench 同时展示平均值、中位数、p95 和标准差。平均值方便做 baseline 对比，但容易受异常值影响；中位数和 MAD 更适合观察稳定表现；p95 用于快速发现尾部延迟；relative stddev 用于判断样本抖动是否过大。

当前 `p90/p95/p99` 使用 nearest-rank 风格，`Samples::percentile` 提供线性插值版本。这个设计保留了报告稳定性，也让调用方可以按需取得更细粒度的 percentile。

## 回归判断

`Comparison` 以均值为主进行倍率比较，并允许调用方设置噪声阈值。默认建议把 2% 左右的变化视为持平，避免把运行时噪声误判成真实优化或退化。

`RegressionRule` 在 `Comparison` 之上增加 CI 语义：

- candidate 更快或在噪声阈值内：`Pass`
- slowdown 超过 warning 阈值但没有超过 fail 阈值：`Warn`
- slowdown 超过 fail 阈值：`Fail`

## 后续路线

下一轮更适合把已有的 baseline manifest、trend report 和 gate policy 接入文件持久化与 CLI exit code，让本地运行、CI 回归、Web UI 查看形成闭环。Web UI 还可以继续补 histogram、box plot、历史报告索引和可下载 artifact bundle。


## 成熟工具对标

本轮参考了 Criterion.rs、Go `testing` benchmark、hyperfine 和 pytest-benchmark 的公开设计。MoonBench 目前吸收了适合核心库阶段的部分：

- Criterion.rs / hyperfine 常见的 outlier 诊断：MoonBench 用 Q1/Q3/IQR 计算 mild/severe fence。
- Go benchmark 的自定义指标思想：MoonBench 用 `MetricSet` 和 `Throughput` 表达 ops/s、bytes/s 等指标。
- hyperfine 的参数化运行思想：MoonBench 用 `ParameterSweep` 先表达参数矩阵，后续 runner 可以据此展开执行。
- pytest-benchmark 的历史保存和对比思想：MoonBench 用 `HistoricalRun` 保存统计快照，并按 benchmark 名称对齐比较。
- Criterion.rs 的 HTML report 思路：MoonBench 当前用静态 Web UI 展示 benchmark 表、均值图、样本曲线和 attention heatmap。

这些模块仍保持确定性，不做文件 IO，不绑定某个运行时。真实计时、配置解析和历史文件存储应放到下一层 runner/report 工具里；Web UI 通过 JSON 边界接入，避免污染核心库。
