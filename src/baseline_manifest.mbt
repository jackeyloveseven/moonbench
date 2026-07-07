///|
pub struct BenchmarkSnapshot {
  name : String
  runs : Int
  mean : Duration
  median : Duration
  p95 : Duration
  min : Duration
  max : Duration
  relative_stddev : Double
}

///|
pub struct BaselineEntry {
  name : String
  snapshot : BenchmarkSnapshot
  assessment : BenchmarkAssessment
}

///|
pub struct BaselineManifest {
  run_id : String
  label : String
  suite_name : String
  gate_summary : String
  entries : Array[BaselineEntry]
}

///|
fn baseline_json_escape(value : String) -> String {
  value.replace_all(old="\\", new="\\\\").replace_all(old="\"", new="\\\"")
}

///|
fn baseline_grade_label(grade : StabilityGrade) -> String {
  match grade {
    Stable => "stable"
    Watch => "watch"
    Noisy => "noisy"
  }
}

///|
pub fn BenchmarkSnapshot::from_stats(stats : Stats) -> BenchmarkSnapshot {
  {
    name: stats.name(),
    runs: stats.count(),
    mean: stats.mean(),
    median: stats.median(),
    p95: stats.p95(),
    min: stats.min(),
    max: stats.max(),
    relative_stddev: stats.relative_stddev(),
  }
}

///|
pub fn BenchmarkSnapshot::name(self : BenchmarkSnapshot) -> String {
  self.name
}

///|
pub fn BenchmarkSnapshot::runs(self : BenchmarkSnapshot) -> Int {
  self.runs
}

///|
pub fn BenchmarkSnapshot::mean(self : BenchmarkSnapshot) -> Duration {
  self.mean
}

///|
pub fn BenchmarkSnapshot::median(self : BenchmarkSnapshot) -> Duration {
  self.median
}

///|
pub fn BenchmarkSnapshot::p95(self : BenchmarkSnapshot) -> Duration {
  self.p95
}

///|
pub fn BenchmarkSnapshot::min(self : BenchmarkSnapshot) -> Duration {
  self.min
}

///|
pub fn BenchmarkSnapshot::max(self : BenchmarkSnapshot) -> Duration {
  self.max
}

///|
pub fn BenchmarkSnapshot::relative_stddev(self : BenchmarkSnapshot) -> Double {
  self.relative_stddev
}

///|
pub fn BenchmarkSnapshot::is_empty(self : BenchmarkSnapshot) -> Bool {
  self.runs == 0
}

///|
pub fn BenchmarkSnapshot::spread(self : BenchmarkSnapshot) -> Duration {
  self.max.abs_diff(self.min)
}

///|
pub fn BenchmarkSnapshot::slower_than(
  self : BenchmarkSnapshot,
  baseline : BenchmarkSnapshot,
) -> Bool {
  self.mean.nanos() > baseline.mean().nanos()
}

///|
pub fn BenchmarkSnapshot::change_percent_against(
  self : BenchmarkSnapshot,
  baseline : BenchmarkSnapshot,
) -> Double {
  let base = baseline.mean().nanos().to_double()
  let next = self.mean.nanos().to_double()
  if base == 0.0 {
    if next == 0.0 {
      0.0
    } else {
      100.0
    }
  } else {
    (next - base) / base * 100.0
  }
}

///|
pub fn BenchmarkSnapshot::render_json(self : BenchmarkSnapshot) -> String {
  "{ " +
  "\"name\": \"" +
  baseline_json_escape(self.name) +
  "\", " +
  "\"runs\": " +
  self.runs.to_string() +
  ", " +
  "\"mean_nanos\": \{self.mean.nanos()}, " +
  "\"median_nanos\": \{self.median.nanos()}, " +
  "\"p95_nanos\": \{self.p95.nanos()}, " +
  "\"min_nanos\": \{self.min.nanos()}, " +
  "\"max_nanos\": \{self.max.nanos()}, " +
  "\"relative_stddev\": \{self.relative_stddev} " +
  "}"
}

///|
pub fn BenchmarkSnapshot::summary(self : BenchmarkSnapshot) -> String {
  "\{self.name}: runs=\{self.runs}, mean=\{self.mean.format()}, p95=\{self.p95.format()}, rsd=\{self.relative_stddev}"
}

///|
pub fn BaselineEntry::new(
  snapshot : BenchmarkSnapshot,
  assessment : BenchmarkAssessment,
) -> BaselineEntry {
  { name: snapshot.name(), snapshot, assessment }
}

///|
pub fn BaselineEntry::name(self : BaselineEntry) -> String {
  self.name
}

///|
pub fn BaselineEntry::snapshot(self : BaselineEntry) -> BenchmarkSnapshot {
  self.snapshot
}

///|
pub fn BaselineEntry::assessment(self : BaselineEntry) -> BenchmarkAssessment {
  self.assessment
}

///|
pub fn BaselineEntry::is_stable(self : BaselineEntry) -> Bool {
  self.assessment.grade() == Stable
}

///|
pub fn BaselineEntry::has_outliers(self : BaselineEntry) -> Bool {
  self.assessment.outliers().outlier_count() > 0
}

///|
pub fn BaselineEntry::render_json(self : BaselineEntry) -> String {
  "{ " +
  "\"name\": \"" +
  baseline_json_escape(self.name) +
  "\", " +
  "\"snapshot\": " +
  self.snapshot.render_json() +
  ", " +
  "\"assessment\": \"" +
  baseline_json_escape(baseline_grade_label(self.assessment.grade())) +
  "\", " +
  "\"outliers\": " +
  self.assessment.outliers().outlier_count().to_string() +
  " }"
}

///|
pub fn BaselineEntry::summary(self : BaselineEntry) -> String {
  self.snapshot.summary() +
  ", assessment=" +
  baseline_grade_label(self.assessment.grade())
}

///|
pub fn BaselineManifest::new(
  run_id : String,
  label : String,
  suite_name : String,
) -> BaselineManifest {
  { run_id, label, suite_name, gate_summary: "not checked", entries: [] }
}

///|
pub fn BaselineManifest::from_artifact(
  artifact : BenchmarkArtifact,
) -> BaselineManifest {
  let suite = artifact.suite()
  let assessment = artifact.assessment()
  let entries : Array[BaselineEntry] = []
  for i = 0; i < suite.len(); i = i + 1 {
    let snapshot = BenchmarkSnapshot::from_stats(suite.get(i).stats())
    entries.push(BaselineEntry::new(snapshot, assessment.get(i)))
  }
  {
    run_id: artifact.run_id(),
    label: artifact.label(),
    suite_name: suite.name(),
    gate_summary: artifact.gate().summary(),
    entries,
  }
}

///|
pub fn BaselineManifest::from_suite(
  run_id : String,
  label : String,
  suite : SuiteResult,
) -> BaselineManifest {
  BaselineManifest::from_artifact(
    BenchmarkArtifact::from_suite(run_id, label, suite),
  )
}

///|
pub fn BaselineManifest::run_id(self : BaselineManifest) -> String {
  self.run_id
}

///|
pub fn BaselineManifest::label(self : BaselineManifest) -> String {
  self.label
}

///|
pub fn BaselineManifest::suite_name(self : BaselineManifest) -> String {
  self.suite_name
}

///|
pub fn BaselineManifest::gate_summary(self : BaselineManifest) -> String {
  self.gate_summary
}

///|
pub fn BaselineManifest::len(self : BaselineManifest) -> Int {
  self.entries.length()
}

///|
pub fn BaselineManifest::get(
  self : BaselineManifest,
  index : Int,
) -> BaselineEntry {
  self.entries[index]
}

///|
pub fn BaselineManifest::entries(
  self : BaselineManifest,
) -> Array[BaselineEntry] {
  self.entries.copy()
}

///|
pub fn BaselineManifest::add_entry(
  self : BaselineManifest,
  entry : BaselineEntry,
) -> BaselineManifest {
  let entries = self.entries.copy()
  entries.push(entry)
  {
    run_id: self.run_id,
    label: self.label,
    suite_name: self.suite_name,
    gate_summary: self.gate_summary,
    entries,
  }
}

///|
pub fn BaselineManifest::with_gate_summary(
  self : BaselineManifest,
  gate_summary : String,
) -> BaselineManifest {
  {
    run_id: self.run_id,
    label: self.label,
    suite_name: self.suite_name,
    gate_summary,
    entries: self.entries,
  }
}

///|
pub fn BaselineManifest::find_index(
  self : BaselineManifest,
  name : String,
) -> Int {
  let mut found = -1
  for i = 0; i < self.entries.length(); i = i + 1 {
    if found < 0 && self.entries[i].name() == name {
      found = i
    }
  }
  found
}

///|
pub fn BaselineManifest::contains(
  self : BaselineManifest,
  name : String,
) -> Bool {
  self.find_index(name) >= 0
}

///|
pub fn BaselineManifest::stable_count(self : BaselineManifest) -> Int {
  let mut count = 0
  for entry in self.entries {
    if entry.is_stable() {
      count = count + 1
    }
  }
  count
}

///|
pub fn BaselineManifest::outlier_count(self : BaselineManifest) -> Int {
  let mut count = 0
  for entry in self.entries {
    if entry.has_outliers() {
      count = count + 1
    }
  }
  count
}

///|
pub fn BaselineManifest::slowest_entry(
  self : BaselineManifest,
) -> BaselineEntry {
  if self.entries.length() == 0 {
    BaselineEntry::new(
      BenchmarkSnapshot::from_stats(Samples::new("empty").stats()),
      BenchmarkAssessment::from_result(
        BenchmarkResult::from_samples(
          "empty",
          Samples::new("empty"),
          BenchmarkConfig::default(),
        ),
      ),
    )
  } else {
    let mut index = 0
    for i = 1; i < self.entries.length(); i = i + 1 {
      if self.entries[i].snapshot().mean().nanos() >
        self.entries[index].snapshot().mean().nanos() {
        index = i
      }
    }
    self.entries[index]
  }
}

///|
pub fn BaselineManifest::fastest_entry(
  self : BaselineManifest,
) -> BaselineEntry {
  if self.entries.length() == 0 {
    BaselineEntry::new(
      BenchmarkSnapshot::from_stats(Samples::new("empty").stats()),
      BenchmarkAssessment::from_result(
        BenchmarkResult::from_samples(
          "empty",
          Samples::new("empty"),
          BenchmarkConfig::default(),
        ),
      ),
    )
  } else {
    let mut index = 0
    for i = 1; i < self.entries.length(); i = i + 1 {
      if self.entries[i].snapshot().mean().nanos() <
        self.entries[index].snapshot().mean().nanos() {
        index = i
      }
    }
    self.entries[index]
  }
}

///|
pub fn BaselineManifest::render_json(self : BaselineManifest) -> String {
  let mut out = "{\n"
  out = out + "  \"run_id\": \"" + baseline_json_escape(self.run_id) + "\",\n"
  out = out + "  \"label\": \"" + baseline_json_escape(self.label) + "\",\n"
  out = out +
    "  \"suite\": \"" +
    baseline_json_escape(self.suite_name) +
    "\",\n"
  out = out +
    "  \"gate\": \"" +
    baseline_json_escape(self.gate_summary) +
    "\",\n"
  out = out + "  \"benchmarks\": [\n"
  for i = 0; i < self.entries.length(); i = i + 1 {
    out = out + "    " + self.entries[i].render_json()
    if i + 1 < self.entries.length() {
      out = out + ","
    }
    out = out + "\n"
  }
  out = out + "  ]\n"
  out = out + "}"
  out
}

///|
pub fn BaselineManifest::render_markdown(self : BaselineManifest) -> String {
  let mut out = "# Baseline manifest: " + self.label + "\n\n"
  out = out + "- run_id: `" + self.run_id + "`\n"
  out = out + "- suite: `" + self.suite_name + "`\n"
  out = out + "- gate: `" + self.gate_summary + "`\n"
  out = out +
    "- stable: `" +
    self.stable_count().to_string() +
    "/" +
    self.entries.length().to_string() +
    "`\n"
  out = out + "- outlier_cases: `" + self.outlier_count().to_string() + "`\n\n"
  out = out + "| benchmark | runs | mean | p95 | rsd | assessment |\n"
  out = out + "| --- | ---: | ---: | ---: | ---: | --- |\n"
  for entry in self.entries {
    let snap = entry.snapshot()
    out = out +
      "| " +
      snap.name() +
      " | " +
      snap.runs().to_string() +
      " | " +
      snap.mean().format() +
      " | " +
      snap.p95().format() +
      " | " +
      snap.relative_stddev().to_string() +
      " | " +
      baseline_grade_label(entry.assessment().grade()) +
      " |\n"
  }
  out
}

///|
pub fn BaselineManifest::summary(self : BaselineManifest) -> String {
  "baseline run=\{self.run_id}, label=\{self.label}, cases=\{self.entries.length()}, stable=\{self.stable_count()}, outlier_cases=\{self.outlier_count()}"
}

///|
test "baseline manifest captures suite snapshots" {
  let manifest = BaselineManifest::from_suite(
    "run-1",
    "baseline",
    BenchmarkSuite::new("suite")
    .add_samples(Samples::new("a").add_nanos(10L).add_nanos(12L))
    .add_samples(Samples::new("b").add_nanos(20L).add_nanos(22L))
    .finish(),
  )
  assert_eq(manifest.len(), 2)
  assert_true(manifest.contains("a"))
  assert_eq(manifest.fastest_entry().name(), "a")
  assert_eq(manifest.slowest_entry().name(), "b")
}

///|
test "baseline manifest renders json and markdown" {
  let manifest = BaselineManifest::from_suite(
    "run-1",
    "baseline",
    default_smoke_suite(),
  )
  assert_true(manifest.render_json().contains("\"benchmarks\""))
  assert_true(manifest.render_markdown().contains("Baseline manifest"))
  assert_true(manifest.summary().contains("cases="))
}

///|
test "benchmark snapshot computes change percent" {
  let baseline = BenchmarkSnapshot::from_stats(
    Samples::new("case").add_nanos(100L).stats(),
  )
  let candidate = BenchmarkSnapshot::from_stats(
    Samples::new("case").add_nanos(125L).stats(),
  )
  assert_true(candidate.slower_than(baseline))
  assert_true(candidate.change_percent_against(baseline) == 25.0)
}
