# MoonBench Roadmap

This document records the gap between MoonBench and mature benchmark tools.

## Current Coverage

MoonBench now has a full in-process benchmark pipeline:

1. `BenchmarkModel` describes supported workload models.
2. `BenchmarkTask` registers user workloads.
3. `BenchmarkRunner` executes warmup and measurement loops.
4. `CalibrationPolicy` probes and selects batch size.
5. `BenchmarkLifecycle` runs setup, teardown, and measurement hooks.
6. `MeasurementBackend` separates real monotonic timing from deterministic tests.
7. `SuiteResult` stores measured samples.
8. `Stats` computes distribution metrics.
9. `SuiteAssessment` diagnoses stability and outliers.
10. `BaselineManifest` records compact baseline snapshots.
11. `TrendReport` summarizes multi-run improvement and regression trends.
12. `GatePolicy` converts diagnostics and regressions into CI gate status.
13. `BenchmarkArtifact` renders Markdown, CSV, and JSON.
14. `BenchmarkRunPlan` defines smoke, CI, and release profiles.
15. `webui/` displays interactive reports.

Default workload models:

- `array-sort`
- `string-scan`
- `collection-lookup`
- `parser`
- `codec`
- `graph`
- `numeric`
- `hashing`
- `memory`
- `bytes`
- `tensor-matmul`
- `nn-activation`
- `attention`

## Comparison Notes

Criterion.rs highlights advanced statistical settings, throughput, parameterized groups, HTML reports, plots, sampling modes, custom measurements, profiling, and async benchmarking.

hyperfine highlights arbitrary command benchmarks, warmup, prepare/setup/cleanup hooks, automatic run counts, outlier detection, parameter scans/lists, and CSV/JSON/Markdown/AsciiDoc export.

pytest-benchmark highlights autosaved historical runs, compare commands, compare-fail thresholds, multi-metric comparisons, and histogram plots.

## Missing High-Value Features

1. Parameter matrix:
   - Cartesian product of multiple parameters.
   - Per-parameter labels in reports and Web UI.
   - Optional throughput metadata per parameter.

2. Persistence:
   - Save artifact JSON to disk.
   - Load previous artifact JSON.
   - Compare current run against saved baseline.
   - Keep machine/runtime metadata.

3. Report depth:
   - Trend report across many runs.
   - Histogram or box plot in Web UI.
   - Dedicated regression summary page.
   - Downloadable artifact bundle.

4. CI release polish:
   - Exit-code oriented CLI wrapper.
   - Configurable compare-fail rules by metric.
   - JUnit-style or GitHub Actions summary output.

5. Measurement API:
   - Custom measurement units.
   - Allocation counters if MoonBit runtime exposes them.
   - Async benchmark runner for `moonbitlang/async`.

## Next Best Iteration

The next best implementation step is persistence plus CI exit-code behavior. The GitHub Actions workflow already covers `moon check --target all`, `moon test --target all`, formatting, toolchain metadata, and Web UI JavaScript syntax. The remaining work is wiring benchmark artifact files into command-line comparison and making CI fail directly on configured performance regressions.
