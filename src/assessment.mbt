///|
pub enum StabilityGrade {
  Stable
  Watch
  Noisy
} derive(Eq, Debug)

///|
pub struct BenchmarkAssessment {
  name : String
  model : BenchmarkModel
  stats : Stats
  outliers : OutlierSummary
  grade : StabilityGrade
  reason : String
}

///|
pub struct SuiteAssessment {
  suite_name : String
  items : Array[BenchmarkAssessment]
}

///|
fn grade_label(grade : StabilityGrade) -> String {
  match grade {
    Stable => "stable"
    Watch => "watch"
    Noisy => "noisy"
  }
}

///|
fn classify_stability(
  stats : Stats,
  outliers : OutlierSummary,
) -> StabilityGrade {
  if stats.relative_stddev() >= 0.12 ||
    outliers.high_severe() + outliers.low_severe() > 0 {
    Noisy
  } else if stats.relative_stddev() >= 0.05 || outliers.outlier_count() > 0 {
    Watch
  } else {
    Stable
  }
}

///|
fn stability_reason(
  stats : Stats,
  outliers : OutlierSummary,
  grade : StabilityGrade,
) -> String {
  match grade {
    Stable => "stable: low relative stddev and no relevant outliers"
    Watch =>
      "watch: rsd=\{stats.relative_stddev()}, outliers=\{outliers.outlier_count()}"
    Noisy =>
      "noisy: rsd=\{stats.relative_stddev()}, severe=\{outliers.high_severe() + outliers.low_severe()}"
  }
}

///|
pub fn BenchmarkAssessment::from_result(
  result : BenchmarkResult,
) -> BenchmarkAssessment {
  let stats = result.stats()
  let outliers = result.samples().outliers()
  let grade = classify_stability(stats, outliers)
  {
    name: result.name(),
    model: benchmark_model_for_name(result.name()),
    stats,
    outliers,
    grade,
    reason: stability_reason(stats, outliers, grade),
  }
}

///|
pub fn BenchmarkAssessment::name(self : BenchmarkAssessment) -> String {
  self.name
}

///|
pub fn BenchmarkAssessment::model(self : BenchmarkAssessment) -> BenchmarkModel {
  self.model
}

///|
pub fn BenchmarkAssessment::stats(self : BenchmarkAssessment) -> Stats {
  self.stats
}

///|
pub fn BenchmarkAssessment::outliers(
  self : BenchmarkAssessment,
) -> OutlierSummary {
  self.outliers
}

///|
pub fn BenchmarkAssessment::grade(self : BenchmarkAssessment) -> StabilityGrade {
  self.grade
}

///|
pub fn BenchmarkAssessment::reason(self : BenchmarkAssessment) -> String {
  self.reason
}

///|
pub fn BenchmarkAssessment::is_noisy(self : BenchmarkAssessment) -> Bool {
  self.grade == Noisy
}

///|
pub fn BenchmarkAssessment::has_outliers(self : BenchmarkAssessment) -> Bool {
  self.outliers.has_outliers()
}

///|
pub fn BenchmarkAssessment::summary(self : BenchmarkAssessment) -> String {
  "\{self.name}: \{grade_label(self.grade)} model=\{self.model.id()} mean=\{self.stats.mean().format()} p95=\{self.stats.p95().format()}"
}

///|
pub fn SuiteAssessment::from_suite(suite : SuiteResult) -> SuiteAssessment {
  let items : Array[BenchmarkAssessment] = []
  for result in suite.results() {
    items.push(BenchmarkAssessment::from_result(result))
  }
  { suite_name: suite.name(), items }
}

///|
pub fn SuiteAssessment::suite_name(self : SuiteAssessment) -> String {
  self.suite_name
}

///|
pub fn SuiteAssessment::len(self : SuiteAssessment) -> Int {
  self.items.length()
}

///|
pub fn SuiteAssessment::get(
  self : SuiteAssessment,
  index : Int,
) -> BenchmarkAssessment {
  self.items[index]
}

///|
pub fn SuiteAssessment::items(
  self : SuiteAssessment,
) -> Array[BenchmarkAssessment] {
  self.items.copy()
}

///|
pub fn SuiteAssessment::noisy_count(self : SuiteAssessment) -> Int {
  let mut count = 0
  for item in self.items {
    if item.grade() == Noisy {
      count = count + 1
    }
  }
  count
}

///|
pub fn SuiteAssessment::watch_count(self : SuiteAssessment) -> Int {
  let mut count = 0
  for item in self.items {
    if item.grade() == Watch {
      count = count + 1
    }
  }
  count
}

///|
pub fn SuiteAssessment::outlier_count(self : SuiteAssessment) -> Int {
  let mut count = 0
  for item in self.items {
    count = count + item.outliers().outlier_count()
  }
  count
}

///|
pub fn SuiteAssessment::summary(self : SuiteAssessment) -> String {
  "assessment \{self.suite_name}: benchmarks=\{self.len()}, watch=\{self.watch_count()}, noisy=\{self.noisy_count()}, outliers=\{self.outlier_count()}"
}

///|
pub fn SuiteAssessment::render_markdown(self : SuiteAssessment) -> String {
  let mut out = "## Stability assessment\n\n"
  out = out + "| benchmark | model | grade | mean | p95 | outliers |\n"
  out = out + "| --- | --- | --- | ---: | ---: | ---: |\n"
  for item in self.items {
    out = out + "| " + item.name()
    out = out + " | " + item.model().id()
    out = out + " | " + grade_label(item.grade())
    out = out + " | " + item.stats().mean().format()
    out = out + " | " + item.stats().p95().format()
    out = out + " | " + item.outliers().outlier_count().to_string()
    out = out + " |\n"
  }
  out
}

///|
test "assessment classifies stable and noisy benchmarks" {
  let stable = BenchmarkResult::from_samples(
    "array/sort/int-10k",
    Samples::new("array/sort/int-10k")
    .add_nanos(100L)
    .add_nanos(101L)
    .add_nanos(99L),
    BenchmarkConfig::default(),
  )
  let noisy = BenchmarkResult::from_samples(
    "parser/json-like/32k",
    Samples::new("parser/json-like/32k")
    .add_nanos(100L)
    .add_nanos(101L)
    .add_nanos(102L)
    .add_nanos(500L),
    BenchmarkConfig::default(),
  )
  assert_true(BenchmarkAssessment::from_result(stable).grade() == Stable)
  assert_true(BenchmarkAssessment::from_result(noisy).grade() != Stable)
}

///|
test "suite assessment summarizes result health" {
  let suite = default_smoke_suite()
  let assessment = SuiteAssessment::from_suite(suite)
  assert_eq(assessment.len(), 13)
  assert_true(assessment.summary().contains("benchmarks=13"))
  assert_true(assessment.render_markdown().contains("Stability assessment"))
}
