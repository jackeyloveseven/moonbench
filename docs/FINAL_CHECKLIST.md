# MoonBench Final Checklist

## Project Identity

- Name: MoonBench（月衡）
- Track: Stopwatch / benchmark tool
- Target users: MoonBit library authors, algorithm projects, CI performance review, teaching examples
- Core value: repeatable benchmark data model, statistics, reports, regression gates, Web UI, deployment path

## What It Benchmarks

MoonBench benchmarks repeatable MoonBit workloads. The built-in smoke suite covers:

- array sorting
- string scanning
- collection lookup
- parser workload
- codec workload
- graph traversal
- numeric loop
- hashing
- small allocation
- bytes copy
- tensor matrix multiplication
- neural-network activation
- attention softmax head

The default suite is for smoke testing and report demonstration. Real users should register their own `BenchmarkTask` workloads or load their own MoonBench JSON.

## Full Pipeline

1. Define benchmark config.
2. Register benchmark tasks.
3. Run warmup and measurement loops.
4. Optionally calibrate batch size with probe measurements.
5. Run lifecycle hooks around suite, cases, and measurements.
6. Collect nanosecond samples.
7. Compute distribution statistics.
8. Detect outliers and unstable measurements.
9. Compare against baseline or historical runs.
10. Generate baseline manifest and trend report.
11. Apply CI gate policy.
12. Render Markdown, CSV, JSON, and Web UI report data.
13. Deploy static Web UI through Nginx or any static host.

## Web UI Preflight

- Dashboard is the first screen, no marketing landing page.
- Top strip shows suite health, sample count, slowest mean, and config.
- Summary cards show cases, fastest mean, worst noise, and outlier samples.
- Chart rows and table rows expose stable/watch/review signal.
- Attention cases render an attention heatmap in the detail canvas.
- User can load JSON, apply pasted JSON, inspect samples, sort rows, and export CSV.
- Palette uses one primary accent, with amber/red reserved for semantic warning and review states.
- No em-dash characters in visible copy.
- No fake screenshots, fake company names, or decorative status labels.

## Verification

```bash
/home/ubuntu/.moon/bin/moon check
/home/ubuntu/.moon/bin/moon test
/home/ubuntu/.moon/bin/moon check --target all
/home/ubuntu/.moon/bin/moon test --target all
node --check webui/app.js
/home/ubuntu/.moon/bin/moon run webui
curl -I http://127.0.0.1:4173/
```

Current verified result:

```text
moon check: passed
moon test: Total tests: 57, passed: 57, failed: 0
moon check --target all: passed
moon test --target all: wasm / wasm-gc / js / native passed
node --check webui/app.js: passed
webui HTML/CSS/JS: HTTP 200 from local static server
```

## CI

- GitHub Actions workflow exists at `.github/workflows/ci.yml`.
- CI pins MoonBit toolchain and core to `0.10.3+16975d007`.
- CI runs `moon check --target all` and `moon test --target all` on Ubuntu, macOS, and Windows.
- CI runs `moon fmt`, `moon info`, and `node --check webui/app.js`.

## Contest Readiness

Current state is a usable contest prototype with real reuse value:

- It is not a single demo script.
- It has a MoonBit core library and examples.
- It has default benchmark models.
- It has a CLI report path.
- It has Web JSON and a static report UI.
- It has deployment docs and Docker/Nginx config.
- It has more than 4k lines of MoonBit code under the strict `.mbt` count.
- It has CI covering all MoonBit targets and Web UI JavaScript syntax.
- It has 13 built-in benchmark models, including tensor, neural-network activation, and attention workloads.

Risk:

- The project is now above the minimum reference size even under a strict MoonBit-only count: 6140 `.mbt` source lines excluding `_build`.
- For a stronger final submission, the next MoonBit-heavy iteration should connect baseline manifest and trend report to real file persistence and CI exit codes.
