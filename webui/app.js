const DEFAULT_DATA = {
  schema_version: 1,
  tool: "MoonBench",
  suite: "MoonBench default smoke suite",
  config: { warmup_runs: 3, measure_runs: 8, noise_threshold: 2, trim_extremes: false },
  benchmarks: [
    makeItem("array/sort/int-10k", [3000000, 3100000, 3020000, 2990000, 3060000, 3010000, 3040000, 3005000]),
    makeItem("string/scan/ascii-64k", [442000, 436000, 449000, 441000, 438000, 444000, 452000, 439000]),
    makeItem("collection/map-lookup/50k", [1880000, 1915000, 1850000, 1872000, 1894000, 1865000, 1930000, 1888000]),
    makeItem("parser/json-like/32k", [810000, 798000, 826000, 818000, 805000, 812000, 1220000, 809000]),
    makeItem("codec/csv-encode/10k", [1280000, 1265000, 1302000, 1274000, 1289000, 1268000, 1310000, 1279000]),
    makeItem("graph/bfs/grid-128", [5420000, 5350000, 5510000, 5390000, 5440000, 5370000, 5480000, 5410000]),
    makeItem("numeric/arithmetic-loop/1m", [720000, 708000, 715000, 726000, 711000, 718000, 722000, 713000]),
    makeItem("hashing/bytes-64k", [980000, 995000, 972000, 988000, 1002000, 979000, 991000, 984000]),
    makeItem("memory/alloc-small/10k", [2350000, 2410000, 2380000, 2365000, 2440000, 2375000, 2395000, 2360000]),
    makeItem("bytes/copy-64k", [515000, 506000, 522000, 511000, 509000, 518000, 524000, 512000]),
    makeItem("tensor/matmul/f32-64x64", [6120000, 6040000, 6190000, 6080000, 6150000, 6060000, 6210000, 6100000]),
    makeItem("nn/activation/relu-1m", [1360000, 1335000, 1378000, 1352000, 1344000, 1369000, 1385000, 1357000]),
    makeAttentionItem("attention/softmax-head-128", [4280000, 4210000, 4360000, 4250000, 4310000, 4230000, 4390000, 4270000])
  ]
};

let currentData = normalize(DEFAULT_DATA);
let selectedIndex = 0;
let currentLang = initialLanguage();
let statusState = { key: "status.defaultLoaded", args: {} };

const $ = (id) => document.getElementById(id);

const I18N = {
  en: {
    actions: {
      defaultSuite: "Default Suite",
      loadJson: "Load JSON",
      exportCsv: "Export CSV",
      applyJson: "Apply JSON"
    },
    metrics: {
      samples: "Samples",
      slowestMean: "Slowest Mean",
      config: "Config",
      cases: "Cases",
      fastestMean: "Fastest Mean",
      worstNoise: "Worst Noise",
      outlierSamples: "Outlier Samples"
    },
    sections: {
      subjects: "Detected Subjects",
      meanDuration: "Mean Duration",
      chartNote: "Mean runtime by benchmark case.",
      results: "Results",
      reportJson: "Report JSON"
    },
    sort: {
      meanAsc: "Mean ascending",
      meanDesc: "Mean descending",
      name: "Name",
      noiseDesc: "Noise descending"
    },
    detail: {
      runs: "Runs",
      min: "Min",
      median: "Median",
      p95: "P95",
      max: "Max"
    },
    table: {
      subject: "Subject",
      name: "Name",
      runs: "Runs",
      mean: "Mean",
      median: "Median",
      p95: "P95",
      stddev: "Stddev",
      outliers: "Outliers",
      signal: "Signal"
    },
    status: {
      defaultLoaded: "Default suite loaded",
      loaded: "Loaded {count} cases / {health}",
      error: "{message}"
    },
    suite: {
      defaultName: "MoonBench default smoke suite",
      emptySubtitle: "Load a MoonBench JSON report to inspect benchmark results.",
      subtitle: "Measures {subjects}. Load your own JSON to inspect project-specific MoonBit benchmarks."
    },
    algo: {
      title: "Algorithm Complexity Benchmark",
      subtitle: "Classic CS algorithms benchmarked with 20 runs. Complexity annotations show theoretical class.",
      colAlgo: "Algorithm",
      colTime: "Time",
      colSpace: "Space",
      colMean: "Mean",
      colSignal: "Signal",
      catSorting: "Sorting",
      catSearch: "Search",
      catString: "String Matching",
      catGraph: "Graph",
      catDp: "Dynamic Programming",
      catNumeric: "Numeric"
    },
    signal: {
      stable: "stable",
      watch: "watch",
      review: "review",
      healthStable: "Stable",
      healthWatch: "Watch",
      healthReview: "Review"
    },
    subject: {
      "array/": ["Array algorithms", "Sorting and indexed sequence operations"],
      "string/": ["String processing", "Scanning, splitting, and text traversal"],
      "collection/": ["Collections", "Map/set lookup and update workloads"],
      "parser/": ["Parsing", "JSON-like or structured input parsing"],
      "codec/": ["Encoding", "CSV, binary, or text serialization output"],
      "graph/": ["Graph algorithms", "Traversal and path-style workloads"],
      "numeric/": ["Numeric kernels", "Integer, floating-point, and tight arithmetic loops"],
      "hashing/": ["Hashing", "Hash calculation and digest-style byte traversal"],
      "memory/": ["Memory allocation", "Allocation, object construction, and short-lived buffers"],
      "bytes/": ["Bytes processing", "Byte copy, slicing, scanning, and buffer movement"],
      "tensor/": ["Tensor matrix multiplication", "Dense tensor multiply kernels used by neural-network layers"],
      "nn/": ["Neural-network activation", "Activation and normalization style forward-pass element kernels"],
      "attention/": ["Attention kernel", "Scaled dot-product attention score, softmax, and head-level weight workloads"],
      "custom": ["Custom workload", "User supplied benchmark case"]
    }
  },
  zh: {
    actions: {
      defaultSuite: "默认套件",
      loadJson: "加载 JSON",
      exportCsv: "导出 CSV",
      applyJson: "应用 JSON"
    },
    metrics: {
      samples: "样本数",
      slowestMean: "最慢均值",
      config: "配置",
      cases: "用例数",
      fastestMean: "最快均值",
      worstNoise: "最高噪声",
      outlierSamples: "离群样本"
    },
    sections: {
      subjects: "检测对象",
      meanDuration: "均值耗时",
      chartNote: "按 benchmark 用例展示平均运行时间。",
      results: "结果",
      reportJson: "报告 JSON"
    },
    sort: {
      meanAsc: "均值升序",
      meanDesc: "均值降序",
      name: "名称",
      noiseDesc: "噪声降序"
    },
    detail: {
      runs: "次数",
      min: "最小值",
      median: "中位数",
      p95: "P95",
      max: "最大值"
    },
    table: {
      subject: "对象",
      name: "名称",
      runs: "次数",
      mean: "均值",
      median: "中位数",
      p95: "P95",
      stddev: "标准差",
      outliers: "离群值",
      signal: "信号"
    },
    status: {
      defaultLoaded: "已加载默认套件",
      loaded: "已加载 {count} 个用例 / {health}",
      error: "{message}"
    },
    suite: {
      defaultName: "MoonBench 默认 smoke 套件",
      emptySubtitle: "加载 MoonBench JSON 报告以查看 benchmark 结果。",
      subtitle: "检测 {subjects}。也可以加载自己的 JSON 来查看项目专属 MoonBit benchmark。"
    },
    algo: {
      title: "算法复杂度基准",
      subtitle: "经典 CS 算法，每个 benchmark 运行 20 次，附理论复杂度标注。",
      colAlgo: "算法",
      colTime: "时间复杂度",
      colSpace: "空间复杂度",
      colMean: "均值",
      colSignal: "稳定性",
      catSorting: "排序算法",
      catSearch: "搜索算法",
      catString: "字符串匹配",
      catGraph: "图算法",
      catDp: "动态规划",
      catNumeric: "数值计算"
    },
    signal: {
      stable: "稳定",
      watch: "观察",
      review: "复查",
      healthStable: "稳定",
      healthWatch: "观察",
      healthReview: "复查"
    },
    subject: {
      "array/": ["数组算法", "排序和索引序列操作"],
      "string/": ["字符串处理", "扫描、拆分和文本遍历"],
      "collection/": ["集合", "Map/Set 查询和更新负载"],
      "parser/": ["解析", "JSON-like 或结构化输入解析"],
      "codec/": ["编码", "CSV、二进制或文本序列化输出"],
      "graph/": ["图算法", "遍历和路径类负载"],
      "numeric/": ["数值内核", "整数、浮点和紧循环计算"],
      "hashing/": ["哈希", "哈希计算和 digest 风格字节遍历"],
      "memory/": ["内存分配", "分配、对象构造和短生命周期缓冲区"],
      "bytes/": ["字节处理", "字节复制、切片、扫描和缓冲区移动"],
      "tensor/": ["张量矩阵乘", "神经网络层常用的稠密张量乘法内核"],
      "nn/": ["神经网络激活", "激活和归一化风格的前向逐元素算子"],
      "attention/": ["注意力内核", "缩放点积注意力分数、softmax 和 head 级权重负载"],
      "custom": ["自定义负载", "用户提供的 benchmark 用例"]
    }
  }
};

function initialLanguage() {
  try {
    const saved = localStorage.getItem("moonbench-lang");
    if (saved === "zh" || saved === "en") return saved;
  } catch (_error) {
    // localStorage may be unavailable in locked-down previews.
  }
  return navigator.language && navigator.language.toLowerCase().startsWith("zh") ? "zh" : "en";
}

function t(path, args = {}) {
  const parts = path.split(".");
  let value = I18N[currentLang];
  for (const part of parts) value = value && value[part];
  if (typeof value !== "string") value = path;
  return value.replace(/\{(\w+)\}/g, (_match, key) => String(args[key] ?? ""));
}

function translateSubject(subject) {
  const aliases = {
    "array-sort": "array/",
    "string-scan": "string/",
    "collection-lookup": "collection/",
    "parser": "parser/",
    "codec": "codec/",
    "graph": "graph/",
    "numeric": "numeric/",
    "hashing": "hashing/",
    "memory": "memory/",
    "bytes": "bytes/",
    "tensor-matmul": "tensor/",
    "nn-activation": "nn/",
    "attention": "attention/"
  };
  const key = aliases[subject.key] || subject.key || "custom";
  const entry = I18N[currentLang].subject[key] || I18N[currentLang].subject.custom;
  return { key, title: entry[0], description: entry[1] };
}

function signalText(label) {
  return t(`signal.${label}`);
}

function healthText(label) {
  if (label === "Stable") return t("signal.healthStable");
  if (label === "Watch") return t("signal.healthWatch");
  return t("signal.healthReview");
}

function suiteTitle(data) {
  if (data.suite === DEFAULT_DATA.suite || data.suite === I18N.zh.suite.defaultName) {
    return t("suite.defaultName");
  }
  return data.suite;
}

function setStatus(key, args = {}) {
  statusState = { key, args };
  $("status-line").textContent = t(key, args);
}

function applyTranslations() {
  document.documentElement.lang = currentLang === "zh" ? "zh-CN" : "en";
  document.querySelectorAll("[data-i18n]").forEach((node) => {
    node.textContent = t(node.dataset.i18n);
  });
  $("lang-button").textContent = currentLang === "zh" ? "EN" : "中文";
  $("lang-button").setAttribute("aria-label", currentLang === "zh" ? "Switch to English" : "切换到中文");
  $("status-line").textContent = t(statusState.key, statusState.args);
}

function makeItem(name, samples) {
  const sorted = [...samples].sort((a, b) => a - b);
  const mean = samples.reduce((sum, value) => sum + value, 0) / samples.length;
  const median = percentile(sorted, 0.5);
  const variance = samples.reduce((sum, value) => sum + Math.pow(value - mean, 2), 0) / samples.length;
  const stddev = Math.sqrt(variance);
  return {
    name,
    stats: {
      name,
      runs: samples.length,
      min_nanos: sorted[0],
      mean_nanos: mean,
      median_nanos: median,
      p95_nanos: percentile(sorted, 0.95),
      max_nanos: sorted[sorted.length - 1],
      stddev_nanos: stddev,
      relative_stddev: mean === 0 ? 0 : stddev / mean
    },
    samples_nanos: samples,
    outliers: outlierSummary(name, sorted)
  };
}

function makeAttentionItem(name, samples) {
  return {
    ...makeItem(name, samples),
    attention_matrix: defaultAttentionMatrix()
  };
}

function defaultAttentionMatrix() {
  return [
    [0.38, 0.20, 0.12, 0.08, 0.07, 0.05, 0.05, 0.05],
    [0.12, 0.34, 0.22, 0.11, 0.07, 0.05, 0.05, 0.04],
    [0.07, 0.15, 0.36, 0.20, 0.09, 0.05, 0.04, 0.04],
    [0.05, 0.08, 0.18, 0.37, 0.18, 0.07, 0.04, 0.03],
    [0.04, 0.05, 0.08, 0.18, 0.36, 0.19, 0.06, 0.04],
    [0.04, 0.04, 0.05, 0.08, 0.18, 0.37, 0.18, 0.06],
    [0.04, 0.04, 0.04, 0.05, 0.09, 0.20, 0.38, 0.20],
    [0.05, 0.04, 0.04, 0.04, 0.06, 0.10, 0.22, 0.45]
  ];
}

function percentile(sorted, percent) {
  if (!sorted.length) return 0;
  if (sorted.length === 1) return sorted[0];
  const pos = (sorted.length - 1) * percent;
  const lower = Math.floor(pos);
  const upper = Math.min(lower + 1, sorted.length - 1);
  const weight = pos - lower;
  return sorted[lower] + (sorted[upper] - sorted[lower]) * weight;
}

function outlierSummary(name, sorted) {
  const q1 = percentile(sorted, 0.25);
  const q3 = percentile(sorted, 0.75);
  const iqr = q3 - q1;
  const lower = q1 - iqr * 1.5;
  const upper = q3 + iqr * 1.5;
  const total = sorted.filter((value) => value < lower || value > upper).length;
  return { total, summary: `${name}: ${total} outliers by IQR fence` };
}

function subjectInfo(name) {
  const table = [
    ["array/", "Array algorithms", "Sorting and indexed sequence operations"],
    ["string/", "String processing", "Scanning, splitting, and text traversal"],
    ["collection/", "Collections", "Map/set lookup and update workloads"],
    ["parser/", "Parsing", "JSON-like or structured input parsing"],
    ["codec/", "Encoding", "CSV, binary, or text serialization output"],
    ["graph/", "Graph algorithms", "Traversal and path-style workloads"],
    ["numeric/", "Numeric kernels", "Integer, floating-point, and tight arithmetic loops"],
    ["hashing/", "Hashing", "Hash calculation and digest-style byte traversal"],
    ["memory/", "Memory allocation", "Allocation, object construction, and short-lived buffers"],
    ["bytes/", "Bytes processing", "Byte copy, slicing, scanning, and buffer movement"],
    ["tensor/", "Tensor matrix multiplication", "Dense tensor multiply kernels used by neural-network layers"],
    ["nn/", "Neural-network activation", "Activation and normalization style forward-pass element kernels"],
    ["attention/", "Attention kernel", "Scaled dot-product attention score, softmax, and head-level weight workloads"]
  ];
  const found = table.find(([prefix]) => name.startsWith(prefix));
  if (found) return { key: found[0], title: found[1], description: found[2] };
  return { key: "custom", title: "Custom workload", description: "User supplied benchmark case" };
}

function formatNanos(ns) {
  const value = Number(ns);
  if (!Number.isFinite(value)) return "0ns";
  if (Math.abs(value) < 1000) return `${Math.round(value)}ns`;
  if (Math.abs(value) < 1000000) return `${trimNumber(value / 1000)}us`;
  if (Math.abs(value) < 1000000000) return `${trimNumber(value / 1000000)}ms`;
  return `${trimNumber(value / 1000000000)}s`;
}

function trimNumber(value) {
  return Number(value.toFixed(3)).toString();
}

function asPercent(value) {
  return `${trimNumber((Number(value) || 0) * 100)}%`;
}

function getStats(item) {
  return item.stats || item;
}

function normalize(data) {
  if (!data || !Array.isArray(data.benchmarks)) throw new Error("Missing benchmarks array");
  return {
    ...data,
    suite: data.suite || data.title || "MoonBench Report",
    benchmarks: data.benchmarks.map((item) => {
      const stats = getStats(item);
      const samples = (item.samples_nanos || item.samples || []).map(Number).filter(Number.isFinite);
      const name = item.name || stats.name || "benchmark";
      const subject = item.subject || modelToSubject(item.model) || subjectInfo(name);
      return {
        ...item,
        name,
        subject,
        stats: {
          ...stats,
          runs: Number(stats.runs || stats.count || samples.length || 0),
          min_nanos: Number(stats.min_nanos || Math.min(...samples, 0)),
          mean_nanos: Number(stats.mean_nanos || 0),
          median_nanos: Number(stats.median_nanos || 0),
          p95_nanos: Number(stats.p95_nanos || 0),
          max_nanos: Number(stats.max_nanos || Math.max(...samples, 0)),
          stddev_nanos: Number(stats.stddev_nanos || 0),
          relative_stddev: Number(stats.relative_stddev || 0)
        },
        samples_nanos: samples,
        attention_matrix: item.attention_matrix || item.attention || null,
        outliers: item.outliers || { total: 0, summary: "" }
      };
    })
  };
}

function modelToSubject(model) {
  if (!model) return null;
  return {
    key: model.id || "custom",
    title: model.title || "Custom workload",
    description: model.description || "User supplied benchmark case"
  };
}

function stability(stats) {
  const rsd = stats.relative_stddev || 0;
  if (rsd >= 0.12) return { label: "review", tone: "danger" };
  if (rsd >= 0.05) return { label: "watch", tone: "warn" };
  return { label: "stable", tone: "" };
}

function itemSignal(item) {
  const state = stability(item.stats);
  const outliers = Number(item.outliers.total || 0);
  if (state.tone === "danger" || outliers >= 2) return { label: "review", tone: "danger" };
  if (state.tone === "warn" || outliers > 0) return { label: "watch", tone: "warn" };
  return { label: "stable", tone: "" };
}

function runAnalysis(benches) {
  const fastest = benches.reduce((best, item) => !best || item.stats.mean_nanos < best.stats.mean_nanos ? item : best, null);
  const slowest = benches.reduce((worst, item) => !worst || item.stats.mean_nanos > worst.stats.mean_nanos ? item : worst, null);
  const worstNoise = benches.reduce((worst, item) => !worst || item.stats.relative_stddev > worst.stats.relative_stddev ? item : worst, null);
  const outliers = benches.reduce((sum, item) => sum + Number(item.outliers.total || 0), 0);
  const samples = benches.reduce((sum, item) => sum + Number(item.stats.runs || 0), 0);
  const signals = benches.map(itemSignal);
  const reviews = signals.filter((signal) => signal.tone === "danger").length;
  const watches = signals.filter((signal) => signal.tone === "warn").length;
  let health = { label: "Stable", tone: "" };
  if (reviews > 0) health = { label: "Review", tone: "danger" };
  else if (watches > 0) health = { label: "Watch", tone: "warn" };
  return { fastest, slowest, worstNoise, outliers, samples, reviews, watches, health };
}

function sortedBenchmarks() {
  const mode = $("sort-select").value;
  const items = [...currentData.benchmarks];
  items.sort((a, b) => {
    if (mode === "mean-desc") return b.stats.mean_nanos - a.stats.mean_nanos;
    if (mode === "name") return a.name.localeCompare(b.name);
    if (mode === "rsd-desc") return b.stats.relative_stddev - a.stats.relative_stddev;
    return a.stats.mean_nanos - b.stats.mean_nanos;
  });
  return items;
}

function renderOverview() {
  const benches = currentData.benchmarks;
  const analysis = runAnalysis(benches);
  const config = currentData.config || {};
  $("suite-title").textContent = suiteTitle(currentData);
  $("suite-subtitle").textContent = subtitleFor(currentData);
  $("metric-count").textContent = benches.length.toString();
  $("metric-fastest").textContent = analysis.fastest ? formatNanos(analysis.fastest.stats.mean_nanos) : "0ns";
  $("metric-noisy").textContent = analysis.worstNoise ? asPercent(analysis.worstNoise.stats.relative_stddev) : "0%";
  $("metric-outliers").textContent = analysis.outliers.toString();
  $("metric-samples").textContent = analysis.samples.toString();
  $("metric-slowest").textContent = analysis.slowest ? formatNanos(analysis.slowest.stats.mean_nanos) : "0ns";
  $("metric-config").textContent = `${Number(config.warmup_runs || 0)}w / ${Number(config.measure_runs || 0)}m`;
  $("health-label").textContent = healthText(analysis.health.label);
  $("health-pill").className = `health-pill ${analysis.health.tone}`.trim();
}

function subtitleFor(data) {
  const subjects = uniqueSubjects(data.benchmarks).map((entry) => translateSubject(entry).title.toLowerCase());
  if (subjects.length === 0) return t("suite.emptySubtitle");
  return t("suite.subtitle", { subjects: subjects.join(", ") });
}

function uniqueSubjects(items) {
  const seen = new Set();
  const out = [];
  items.forEach((item) => {
    const info = item.subject || subjectInfo(item.name);
    if (!seen.has(info.title)) {
      seen.add(info.title);
      out.push(info);
    }
  });
  return out;
}

function renderSubjects() {
  const list = $("subject-list");
  list.innerHTML = "";
  uniqueSubjects(currentData.benchmarks).forEach((subject) => {
    const count = currentData.benchmarks.filter((item) => item.subject.title === subject.title).length;
    const translated = translateSubject(subject);
    const button = document.createElement("button");
    button.type = "button";
    button.className = "subject-item";
    if ((currentData.benchmarks[selectedIndex]?.subject.title || "") === subject.title) button.classList.add("active");
    button.innerHTML = `<strong>${escapeHtml(translated.title)} (${count})</strong><span>${escapeHtml(translated.description)}</span>`;
    button.addEventListener("click", () => {
      const next = currentData.benchmarks.findIndex((item) => item.subject.title === subject.title);
      selectBenchmark(next);
    });
    list.appendChild(button);
  });
}

function renderChart() {
  const chart = $("bar-chart");
  const items = sortedBenchmarks();
  const max = Math.max(...items.map((item) => item.stats.mean_nanos), 1);
  chart.innerHTML = "";
  items.forEach((item) => {
    const index = currentData.benchmarks.indexOf(item);
    const row = document.createElement("button");
    row.type = "button";
    row.className = "bar-row";
    if (index === selectedIndex) row.classList.add("selected");
    row.addEventListener("click", () => selectBenchmark(index));

    const name = document.createElement("span");
    name.className = "bar-name";
    name.textContent = item.name;

    const track = document.createElement("span");
    track.className = "bar-track";
    const fill = document.createElement("span");
    fill.className = "bar-fill";
    fill.style.width = `${Math.max((item.stats.mean_nanos / max) * 100, 1)}%`;
    track.appendChild(fill);

    const value = document.createElement("span");
    value.className = "bar-value";
    value.textContent = formatNanos(item.stats.mean_nanos);

    const signal = itemSignal(item);
    const marker = document.createElement("span");
    marker.className = `mini-signal ${signal.tone}`.trim();
    marker.textContent = signalText(signal.label);
    row.append(name, track, value, marker);
    chart.appendChild(row);
  });
}

function renderDetail() {
  const item = currentData.benchmarks[selectedIndex] || currentData.benchmarks[0];
  if (!item) return;
  const stats = item.stats;
  const state = itemSignal(item);
  $("detail-name").textContent = item.name;
  const translated = translateSubject(item.subject);
  $("detail-subject").textContent = `${translated.title}: ${translated.description}`;
  $("detail-badge").textContent = signalText(state.label);
  $("detail-badge").className = `badge ${state.tone}`.trim();
  $("detail-runs").textContent = stats.runs.toString();
  $("detail-min").textContent = formatNanos(stats.min_nanos);
  $("detail-median").textContent = formatNanos(stats.median_nanos);
  $("detail-p95").textContent = formatNanos(stats.p95_nanos);
  $("detail-max").textContent = formatNanos(stats.max_nanos);
  $("detail-rsd").textContent = asPercent(stats.relative_stddev);
  if (isAttentionItem(item)) {
    drawAttentionHeatmap(item);
  } else {
    drawSamples(item.samples_nanos, stats);
  }
}

function renderTable() {
  const body = $("result-body");
  body.innerHTML = "";
  currentData.benchmarks.forEach((item, index) => {
    const stats = item.stats;
    const signal = itemSignal(item);
    const row = document.createElement("tr");
    if (signal.tone) row.classList.add(signal.tone);
    if (index === selectedIndex) row.classList.add("selected");
    row.addEventListener("click", () => selectBenchmark(index));
    row.innerHTML = `
      <td>${escapeHtml(translateSubject(item.subject).title)}</td>
      <td>${escapeHtml(item.name)}</td>
      <td>${stats.runs}</td>
      <td>${formatNanos(stats.mean_nanos)}</td>
      <td>${formatNanos(stats.median_nanos)}</td>
      <td>${formatNanos(stats.p95_nanos)}</td>
      <td>${formatNanos(stats.stddev_nanos)}</td>
      <td>${asPercent(stats.relative_stddev)}</td>
      <td>${Number(item.outliers.total || 0)}</td>
      <td><span class="table-signal ${signal.tone}">${signalText(signal.label)}</span></td>
    `;
    body.appendChild(row);
  });
}

function isAttentionItem(item) {
  return item.name.includes("attention/") || item.subject?.key === "attention";
}

function attentionMatrix(item) {
  const matrix = item.attention_matrix;
  if (Array.isArray(matrix) && matrix.length > 0 && Array.isArray(matrix[0])) {
    return matrix.map((row) => row.map(Number).filter(Number.isFinite)).filter((row) => row.length > 0);
  }
  return defaultAttentionMatrix();
}

function attentionColor(value) {
  const v = Math.max(0, Math.min(Number(value) || 0, 0.5)) / 0.5;
  const r = Math.round(236 - v * 210);
  const g = Math.round(246 - v * 110);
  const b = Math.round(240 - v * 118);
  return `rgb(${r}, ${g}, ${b})`;
}

function drawAttentionHeatmap(item) {
  const canvas = $("sample-canvas");
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = Math.max(1, Math.floor(rect.width * dpr));
  canvas.height = Math.max(1, Math.floor(rect.height * dpr));
  const ctx = canvas.getContext("2d");
  ctx.scale(dpr, dpr);
  const width = rect.width;
  const height = rect.height;
  ctx.clearRect(0, 0, width, height);

  const matrix = attentionMatrix(item);
  const rows = matrix.length;
  const cols = Math.max(...matrix.map((row) => row.length), 1);
  const title = currentLang === "zh" ? "注意力权重热力图" : "Attention weight heatmap";
  const xLabel = currentLang === "zh" ? "Key token" : "Key token";
  const yLabel = currentLang === "zh" ? "Query" : "Query";
  const left = 54;
  const top = 34;
  const right = 22;
  const bottom = 30;
  const plotW = Math.max(1, width - left - right);
  const plotH = Math.max(1, height - top - bottom);
  const cell = Math.max(12, Math.min(plotW / cols, plotH / rows));
  const gridW = cell * cols;
  const gridH = cell * rows;
  const startX = left + Math.max(0, (plotW - gridW) / 2);
  const startY = top;

  ctx.fillStyle = "#16201d";
  ctx.font = "700 13px ui-sans-serif, system-ui";
  ctx.fillText(title, left, 18);
  ctx.fillStyle = "#65726b";
  ctx.font = "11px ui-sans-serif, system-ui";
  ctx.fillText(yLabel, 8, startY + 12);
  ctx.fillText(xLabel, startX, height - 8);

  for (let r = 0; r < rows; r += 1) {
    for (let c = 0; c < cols; c += 1) {
      const value = matrix[r][c] ?? 0;
      const x = startX + c * cell;
      const y = startY + r * cell;
      ctx.fillStyle = attentionColor(value);
      ctx.fillRect(x, y, cell - 1, cell - 1);
    }
  }

  ctx.strokeStyle = "#b7c2ba";
  ctx.lineWidth = 1;
  ctx.strokeRect(startX, startY, gridW, gridH);
  ctx.fillStyle = "#65726b";
  ctx.font = "11px ui-monospace, SFMono-Regular, Menlo, Consolas, monospace";
  for (let i = 0; i < rows; i += 1) {
    ctx.fillText(`q${i}`, 18, startY + i * cell + cell * 0.62);
  }
  for (let i = 0; i < cols; i += 1) {
    ctx.fillText(`k${i}`, startX + i * cell + 3, startY + gridH + 15);
  }
}

function drawSamples(samples, stats) {
  const canvas = $("sample-canvas");
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = Math.max(1, Math.floor(rect.width * dpr));
  canvas.height = Math.max(1, Math.floor(rect.height * dpr));
  const ctx = canvas.getContext("2d");
  ctx.scale(dpr, dpr);
  const width = rect.width;
  const height = rect.height;
  ctx.clearRect(0, 0, width, height);

  const values = samples.length ? samples : [stats.mean_nanos];
  const min = Math.min(...values, stats.min_nanos || values[0]);
  const max = Math.max(...values, stats.max_nanos || values[0], min + 1);
  const left = 46;
  const top = 22;
  const right = 18;
  const bottom = 34;
  const plotW = Math.max(1, width - left - right);
  const plotH = Math.max(1, height - top - bottom);

  ctx.strokeStyle = "#d7ddd8";
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.moveTo(left, top);
  ctx.lineTo(left, top + plotH);
  ctx.lineTo(left + plotW, top + plotH);
  ctx.stroke();

  ctx.fillStyle = "#65726b";
  ctx.font = "12px ui-sans-serif, system-ui";
  ctx.fillText(formatNanos(max), 8, top + 4);
  ctx.fillText(formatNanos(min), 8, top + plotH);

  ctx.strokeStyle = "#147866";
  ctx.lineWidth = 2;
  ctx.beginPath();
  values.forEach((value, index) => {
    const x = left + (values.length === 1 ? plotW / 2 : (index / (values.length - 1)) * plotW);
    const y = top + (1 - (value - min) / (max - min)) * plotH;
    if (index === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  });
  ctx.stroke();

  ctx.fillStyle = "#2f5b4f";
  values.forEach((value, index) => {
    const x = left + (values.length === 1 ? plotW / 2 : (index / (values.length - 1)) * plotW);
    const y = top + (1 - (value - min) / (max - min)) * plotH;
    ctx.beginPath();
    ctx.arc(x, y, 3.6, 0, Math.PI * 2);
    ctx.fill();
  });
}

function selectBenchmark(index) {
  selectedIndex = Math.max(0, Math.min(index, currentData.benchmarks.length - 1));
  renderSubjects();
  renderChart();
  renderDetail();
  renderTable();
}

const DEFAULT_ALGO_DATA = [
  { name: "algo/sort/bubble/1k",    category: "sorting", time: "O(n²)",      space: "O(1)",      samples: [4180000,4310000,4160000,4340000,4200000,4280000,4150000,4350000,4190000,4260000,4220000,4300000,4170000,4330000,4210000,4270000,4140000,4320000,4230000,4250000] },
  { name: "algo/sort/insertion/1k", category: "sorting", time: "O(n²)",      space: "O(1)",      samples: [3090000,3140000,3070000,3160000,3100000,3130000,3080000,3150000,3110000,3120000,3085000,3145000,3075000,3155000,3095000,3125000,3065000,3165000,3105000,3115000] },
  { name: "algo/sort/quick/10k",    category: "sorting", time: "O(n log n)", space: "O(log n)",  samples: [1042000,1058000,1038000,1062000,1045000,1055000,1036000,1064000,1048000,1052000,1040000,1060000,1034000,1066000,1046000,1054000,1032000,1068000,1050000,1056000] },
  { name: "algo/sort/merge/10k",    category: "sorting", time: "O(n log n)", space: "O(n)",      samples: [1242000,1258000,1238000,1262000,1245000,1255000,1236000,1264000,1248000,1252000,1240000,1260000,1234000,1266000,1246000,1254000,1232000,1268000,1250000,1256000] },
  { name: "algo/sort/heap/10k",     category: "sorting", time: "O(n log n)", space: "O(1)",      samples: [1372000,1388000,1368000,1392000,1375000,1385000,1366000,1394000,1378000,1382000,1370000,1390000,1364000,1396000,1376000,1384000,1362000,1398000,1380000,1386000] },
  { name: "algo/search/linear/10k", category: "search",  time: "O(n)",       space: "O(1)",      samples: [49800,50200,49500,50500,49900,50100,49600,50400,49700,50300,49850,50150,49450,50550,49950,50050,49300,50700,49750,50250] },
  { name: "algo/search/binary/100k",category: "search",  time: "O(log n)",   space: "O(1)",      samples: [820,860,810,870,830,850,805,875,825,855,835,845,800,880,840,840,790,890,815,865] },
  { name: "algo/string/naive/10k",  category: "string",  time: "O(nm)",      space: "O(1)",      samples: [182000,188000,180000,190000,183000,187000,179000,191000,181000,189000,184000,186000,177000,193000,185000,185000,176000,194000,182000,188000] },
  { name: "algo/string/kmp/10k",    category: "string",  time: "O(n+m)",     space: "O(m)",      samples: [96000,100000,95000,101000,97000,99000,94000,102000,96500,99500,97500,98500,93000,103000,98000,98000,92000,104000,96000,100000] },
  { name: "algo/graph/bfs/v512",    category: "graph",   time: "O(V+E)",     space: "O(V)",      samples: [198000,202000,197000,203000,199000,201000,196000,204000,198500,201500,199500,200500,195000,205000,200000,200000,194000,206000,198000,202000] },
  { name: "algo/graph/dfs/v512",    category: "graph",   time: "O(V+E)",     space: "O(V)",      samples: [178000,182000,177000,183000,179000,181000,176000,184000,178500,181500,179500,180500,175000,185000,180000,180000,174000,186000,178000,182000] },
  { name: "algo/graph/dijkstra/v256",category:"graph",   time: "O(V²)",      space: "O(V)",      samples: [492000,508000,490000,510000,494000,506000,488000,512000,496000,504000,498000,502000,486000,514000,500000,500000,484000,516000,492000,508000] },
  { name: "algo/dp/fib/iter/1k",    category: "dp",      time: "O(n)",       space: "O(1)",      samples: [2200,2400,2150,2450,2250,2350,2100,2500,2300,2300,2180,2420,2080,2520,2280,2320,2050,2550,2220,2380] },
  { name: "algo/dp/fib/memo/1k",    category: "dp",      time: "O(n)",       space: "O(n)",      samples: [6200,6400,6150,6450,6250,6350,6100,6500,6300,6300,6180,6420,6080,6520,6280,6320,6050,6550,6220,6380] },
  { name: "algo/dp/lcs/100x100",    category: "dp",      time: "O(mn)",      space: "O(mn)",     samples: [48000,52000,47500,52500,49000,51000,47000,53000,48500,51500,49500,50500,46500,53500,50000,50000,46000,54000,48000,52000] },
  { name: "algo/numeric/dot/100k",  category: "numeric", time: "O(n)",       space: "O(1)",      samples: [98000,102000,97500,102500,99000,101000,97000,103000,98500,101500,99500,100500,96500,103500,100000,100000,96000,104000,98000,102000] },
  { name: "algo/numeric/matmul/128",category: "numeric", time: "O(n³)",      space: "O(n²)",     samples: [1980000,2020000,1975000,2025000,1990000,2010000,1970000,2030000,1985000,2015000,1995000,2005000,1965000,2035000,2000000,2000000,1960000,2040000,1980000,2020000] }
];

const ALGO_CATEGORIES = [
  { key: "sorting", label: "catSorting" },
  { key: "search",  label: "catSearch"  },
  { key: "string",  label: "catString"  },
  { key: "graph",   label: "catGraph"   },
  { key: "dp",      label: "catDp"      },
  { key: "numeric", label: "catNumeric" }
];

function complexityBadgeClass(tag) {
  if (tag === "O(1)" || tag === "O(log n)" || tag === "O(n)" || tag === "O(n+m)") return "green";
  if (tag === "O(n log n)" || tag === "O(log n)" || tag === "O(V+E)" || tag === "O(mn)" || tag === "O(m)") return "yellow";
  return "red";
}

function algoItemStats(entry) {
  const sorted = [...entry.samples].sort((a, b) => a - b);
  const mean = entry.samples.reduce((s, v) => s + v, 0) / entry.samples.length;
  const variance = entry.samples.reduce((s, v) => s + (v - mean) ** 2, 0) / entry.samples.length;
  return { mean, rsd: Math.sqrt(variance) / mean };
}

function renderAlgoSection() {
  const container = $("algo-category-list");
  if (!container) return;
  container.innerHTML = "";

  ALGO_CATEGORIES.forEach(({ key, label }) => {
    const items = DEFAULT_ALGO_DATA.filter((e) => e.category === key);
    if (!items.length) return;

    const section = document.createElement("div");
    section.className = "algo-category";

    const header = document.createElement("div");
    header.className = "algo-category-header";
    header.textContent = t(`algo.${label}`);
    section.appendChild(header);

    const table = document.createElement("table");
    table.className = "algo-table";
    table.innerHTML = `<thead><tr>
      <th>${t("algo.colAlgo")}</th>
      <th>${t("algo.colTime")}</th>
      <th>${t("algo.colSpace")}</th>
      <th>${t("algo.colMean")}</th>
      <th>${t("algo.colSignal")}</th>
    </tr></thead>`;

    const tbody = document.createElement("tbody");
    items.forEach((entry) => {
      const { mean, rsd } = algoItemStats(entry);
      const sig = rsd >= 0.12 ? { label: "review", tone: "danger" } : rsd >= 0.05 ? { label: "watch", tone: "warn" } : { label: "stable", tone: "" };
      const shortName = entry.name.split("/").slice(-2).join(" / ");
      const tr = document.createElement("tr");
      tr.innerHTML = `
        <td>${escapeHtml(shortName)}</td>
        <td><span class="complexity-badge ${complexityBadgeClass(entry.time)}">${escapeHtml(entry.time)}</span></td>
        <td><span class="complexity-badge ${complexityBadgeClass(entry.space)}">${escapeHtml(entry.space)}</span></td>
        <td>${formatNanos(mean)}</td>
        <td><span class="table-signal ${sig.tone}">${signalText(sig.label)}</span></td>
      `;
      tr.addEventListener("click", () => {
        const idx = currentData.benchmarks.findIndex((b) => b.name === entry.name);
        if (idx >= 0) selectBenchmark(idx);
      });
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);
    section.appendChild(table);
    container.appendChild(section);
  });
}

function renderAll() {
  applyTranslations();
  renderOverview();
  renderSubjects();
  renderChart();
  renderDetail();
  renderTable();
  renderAlgoSection();
  $("json-input").value = JSON.stringify(currentData, null, 2);
}

function applyJsonText(text) {
  currentData = normalize(JSON.parse(text));
  selectedIndex = 0;
  renderAll();
  const analysis = runAnalysis(currentData.benchmarks);
  setStatus("status.loaded", {
    count: currentData.benchmarks.length,
    health: healthText(analysis.health.label).toLowerCase()
  });
}

function exportCsv() {
  const header = "subject,name,runs,min_nanos,mean_nanos,median_nanos,p95_nanos,max_nanos,stddev_nanos,relative_stddev,outliers,signal";
  const rows = currentData.benchmarks.map((item) => {
    const s = item.stats;
    return [
      csvCell(item.subject.title), csvCell(item.name), s.runs, s.min_nanos, s.mean_nanos, s.median_nanos,
      s.p95_nanos, s.max_nanos, s.stddev_nanos, s.relative_stddev, Number(item.outliers.total || 0), itemSignal(item).label
    ].join(",");
  });
  const blob = new Blob([[header, ...rows].join("\n")], { type: "text/csv" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "moonbench-report.csv";
  link.click();
  URL.revokeObjectURL(url);
}

function csvCell(value) {
  return `"${String(value).replaceAll('"', '""')}"`;
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

$("apply-button").addEventListener("click", () => {
  try { applyJsonText($("json-input").value); }
  catch (error) { setStatus("status.error", { message: error.message }); }
});

$("demo-button").addEventListener("click", () => {
  currentData = normalize(DEFAULT_DATA);
  selectedIndex = 0;
  setStatus("status.defaultLoaded");
  renderAll();
});

$("export-button").addEventListener("click", exportCsv);
$("sort-select").addEventListener("change", renderChart);
$("lang-button").addEventListener("click", () => {
  currentLang = currentLang === "zh" ? "en" : "zh";
  try { localStorage.setItem("moonbench-lang", currentLang); }
  catch (_error) {}
  renderAll();
});
$("file-input").addEventListener("change", async (event) => {
  const file = event.target.files[0];
  if (!file) return;
  try { applyJsonText(await file.text()); }
  catch (error) { setStatus("status.error", { message: error.message }); }
});
window.addEventListener("resize", () => renderDetail());

renderAll();
