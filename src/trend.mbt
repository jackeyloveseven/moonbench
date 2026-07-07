///|
pub enum TrendDirection {
  TrendImproved
  TrendRegressed
  TrendFlat
  TrendInsufficient
} derive(Eq, Debug)

///|
pub struct TrendPoint {
  run_id : String
  label : String
  snapshot : BenchmarkSnapshot
}

///|
pub struct TrendSeries {
  benchmark_name : String
  points : Array[TrendPoint]
}

///|
pub struct TrendSummary {
  benchmark_name : String
  direction : TrendDirection
  first_mean : Duration
  latest_mean : Duration
  best_mean : Duration
  worst_mean : Duration
  change_percent : Double
}

///|
pub struct TrendReport {
  series : Array[TrendSeries]
}

///|
pub fn TrendPoint::new(
  run_id : String,
  label : String,
  snapshot : BenchmarkSnapshot,
) -> TrendPoint {
  { run_id, label, snapshot }
}

///|
pub fn TrendPoint::from_manifest_entry(
  manifest : BaselineManifest,
  entry : BaselineEntry,
) -> TrendPoint {
  {
    run_id: manifest.run_id(),
    label: manifest.label(),
    snapshot: entry.snapshot(),
  }
}

///|
pub fn TrendPoint::run_id(self : TrendPoint) -> String {
  self.run_id
}

///|
pub fn TrendPoint::label(self : TrendPoint) -> String {
  self.label
}

///|
pub fn TrendPoint::snapshot(self : TrendPoint) -> BenchmarkSnapshot {
  self.snapshot
}

///|
pub fn TrendPoint::mean(self : TrendPoint) -> Duration {
  self.snapshot.mean()
}

///|
pub fn TrendPoint::p95(self : TrendPoint) -> Duration {
  self.snapshot.p95()
}

///|
pub fn TrendPoint::summary(self : TrendPoint) -> String {
  "\{self.run_id}/\{self.label}: mean=\{self.mean().format()}, p95=\{self.p95().format()}"
}

///|
pub fn TrendSeries::new(benchmark_name : String) -> TrendSeries {
  { benchmark_name, points: [] }
}

///|
pub fn TrendSeries::benchmark_name(self : TrendSeries) -> String {
  self.benchmark_name
}

///|
pub fn TrendSeries::len(self : TrendSeries) -> Int {
  self.points.length()
}

///|
pub fn TrendSeries::get(self : TrendSeries, index : Int) -> TrendPoint {
  self.points[index]
}

///|
pub fn TrendSeries::points(self : TrendSeries) -> Array[TrendPoint] {
  self.points.copy()
}

///|
pub fn TrendSeries::add_point(
  self : TrendSeries,
  point : TrendPoint,
) -> TrendSeries {
  let points = self.points.copy()
  points.push(point)
  { benchmark_name: self.benchmark_name, points }
}

///|
pub fn TrendSeries::add_snapshot(
  self : TrendSeries,
  run_id : String,
  label : String,
  snapshot : BenchmarkSnapshot,
) -> TrendSeries {
  self.add_point(TrendPoint::new(run_id, label, snapshot))
}

///|
pub fn TrendSeries::first(self : TrendSeries) -> TrendPoint {
  if self.points.length() == 0 {
    TrendPoint::new(
      "none",
      "none",
      BenchmarkSnapshot::from_stats(Samples::new(self.benchmark_name).stats()),
    )
  } else {
    self.points[0]
  }
}

///|
pub fn TrendSeries::latest(self : TrendSeries) -> TrendPoint {
  if self.points.length() == 0 {
    self.first()
  } else {
    self.points[self.points.length() - 1]
  }
}

///|
pub fn TrendSeries::best(self : TrendSeries) -> TrendPoint {
  if self.points.length() == 0 {
    self.first()
  } else {
    let mut index = 0
    for i = 1; i < self.points.length(); i = i + 1 {
      if self.points[i].mean().nanos() < self.points[index].mean().nanos() {
        index = i
      }
    }
    self.points[index]
  }
}

///|
pub fn TrendSeries::worst(self : TrendSeries) -> TrendPoint {
  if self.points.length() == 0 {
    self.first()
  } else {
    let mut index = 0
    for i = 1; i < self.points.length(); i = i + 1 {
      if self.points[i].mean().nanos() > self.points[index].mean().nanos() {
        index = i
      }
    }
    self.points[index]
  }
}

///|
pub fn TrendSeries::mean_of_means(self : TrendSeries) -> Duration {
  if self.points.length() == 0 {
    Duration::zero()
  } else {
    let mut total = 0L
    for point in self.points {
      total = total + point.mean().nanos()
    }
    Duration::from_nanos(total / self.points.length().to_int64())
  }
}

///|
pub fn TrendSeries::latest_change_percent(self : TrendSeries) -> Double {
  if self.points.length() < 2 {
    0.0
  } else {
    self.latest().snapshot().change_percent_against(self.first().snapshot())
  }
}

///|
pub fn TrendSeries::direction(
  self : TrendSeries,
  threshold_percent : Double,
) -> TrendDirection {
  if self.points.length() < 2 {
    TrendInsufficient
  } else {
    let change = self.latest_change_percent()
    let threshold = if threshold_percent < 0.0 {
      0.0
    } else {
      threshold_percent
    }
    if change > threshold {
      TrendRegressed
    } else if change < 0.0 - threshold {
      TrendImproved
    } else {
      TrendFlat
    }
  }
}

///|
pub fn TrendSeries::summary(
  self : TrendSeries,
  threshold_percent : Double,
) -> TrendSummary {
  let direction = self.direction(threshold_percent)
  {
    benchmark_name: self.benchmark_name,
    direction,
    first_mean: self.first().mean(),
    latest_mean: self.latest().mean(),
    best_mean: self.best().mean(),
    worst_mean: self.worst().mean(),
    change_percent: self.latest_change_percent(),
  }
}

///|
pub fn TrendSeries::render_markdown(
  self : TrendSeries,
  threshold_percent : Double,
) -> String {
  let summary = self.summary(threshold_percent)
  let mut out = "### " + self.benchmark_name + "\n\n"
  out = out + "- direction: `" + summary.direction_text() + "`\n"
  out = out + "- first_mean: `" + summary.first_mean().format() + "`\n"
  out = out + "- latest_mean: `" + summary.latest_mean().format() + "`\n"
  out = out +
    "- change_percent: `" +
    summary.change_percent().to_string() +
    "`\n\n"
  out = out + "| run | label | mean | p95 |\n"
  out = out + "| --- | --- | ---: | ---: |\n"
  for point in self.points {
    out = out +
      "| " +
      point.run_id() +
      " | " +
      point.label() +
      " | " +
      point.mean().format() +
      " | " +
      point.p95().format() +
      " |\n"
  }
  out
}

///|
pub fn TrendSummary::benchmark_name(self : TrendSummary) -> String {
  self.benchmark_name
}

///|
pub fn TrendSummary::direction(self : TrendSummary) -> TrendDirection {
  self.direction
}

///|
pub fn TrendSummary::first_mean(self : TrendSummary) -> Duration {
  self.first_mean
}

///|
pub fn TrendSummary::latest_mean(self : TrendSummary) -> Duration {
  self.latest_mean
}

///|
pub fn TrendSummary::best_mean(self : TrendSummary) -> Duration {
  self.best_mean
}

///|
pub fn TrendSummary::worst_mean(self : TrendSummary) -> Duration {
  self.worst_mean
}

///|
pub fn TrendSummary::change_percent(self : TrendSummary) -> Double {
  self.change_percent
}

///|
pub fn TrendSummary::direction_text(self : TrendSummary) -> String {
  match self.direction {
    TrendImproved => "improved"
    TrendRegressed => "regressed"
    TrendFlat => "flat"
    TrendInsufficient => "insufficient"
  }
}

///|
pub fn TrendSummary::summary(self : TrendSummary) -> String {
  "\{self.benchmark_name}: \{self.direction_text()}, first=\{self.first_mean.format()}, latest=\{self.latest_mean.format()}, change=\{self.change_percent}%"
}

///|
pub fn TrendReport::new() -> TrendReport {
  { series: [] }
}

///|
pub fn TrendReport::len(self : TrendReport) -> Int {
  self.series.length()
}

///|
pub fn TrendReport::get(self : TrendReport, index : Int) -> TrendSeries {
  self.series[index]
}

///|
pub fn TrendReport::series(self : TrendReport) -> Array[TrendSeries] {
  self.series.copy()
}

///|
pub fn TrendReport::find_index(
  self : TrendReport,
  benchmark_name : String,
) -> Int {
  let mut found = -1
  for i = 0; i < self.series.length(); i = i + 1 {
    if found < 0 && self.series[i].benchmark_name() == benchmark_name {
      found = i
    }
  }
  found
}

///|
pub fn TrendReport::add_point(
  self : TrendReport,
  benchmark_name : String,
  point : TrendPoint,
) -> TrendReport {
  let series = self.series.copy()
  let index = self.find_index(benchmark_name)
  if index < 0 {
    series.push(TrendSeries::new(benchmark_name).add_point(point))
  } else {
    series[index] = series[index].add_point(point)
  }
  { series, }
}

///|
pub fn TrendReport::add_manifest(
  self : TrendReport,
  manifest : BaselineManifest,
) -> TrendReport {
  let mut report = self
  for entry in manifest.entries() {
    report = report.add_point(
      entry.name(),
      TrendPoint::from_manifest_entry(manifest, entry),
    )
  }
  report
}

///|
pub fn TrendReport::from_manifests(
  manifests : Array[BaselineManifest],
) -> TrendReport {
  let mut report = TrendReport::new()
  for manifest in manifests {
    report = report.add_manifest(manifest)
  }
  report
}

///|
pub fn TrendReport::summary_count(
  self : TrendReport,
  direction : TrendDirection,
  threshold_percent : Double,
) -> Int {
  let mut count = 0
  for series in self.series {
    if series.direction(threshold_percent) == direction {
      count = count + 1
    }
  }
  count
}

///|
pub fn TrendReport::regression_count(
  self : TrendReport,
  threshold_percent : Double,
) -> Int {
  self.summary_count(TrendRegressed, threshold_percent)
}

///|
pub fn TrendReport::improvement_count(
  self : TrendReport,
  threshold_percent : Double,
) -> Int {
  self.summary_count(TrendImproved, threshold_percent)
}

///|
pub fn TrendReport::render_markdown(
  self : TrendReport,
  threshold_percent : Double,
) -> String {
  let mut out = "# Trend report\n\n"
  out = out + "- benchmarks: `" + self.series.length().to_string() + "`\n"
  out = out +
    "- regressions: `" +
    self.regression_count(threshold_percent).to_string() +
    "`\n"
  out = out +
    "- improvements: `" +
    self.improvement_count(threshold_percent).to_string() +
    "`\n\n"
  for series in self.series {
    out = out + series.render_markdown(threshold_percent) + "\n"
  }
  out
}

///|
pub fn TrendReport::summary(
  self : TrendReport,
  threshold_percent : Double,
) -> String {
  "trend benchmarks=\{self.series.length()}, regressions=\{self.regression_count(threshold_percent)}, improvements=\{self.improvement_count(threshold_percent)}"
}

///|
test "trend series detects regression and improvement" {
  let base = BenchmarkSnapshot::from_stats(
    Samples::new("case").add_nanos(100L).stats(),
  )
  let slow = BenchmarkSnapshot::from_stats(
    Samples::new("case").add_nanos(130L).stats(),
  )
  let fast = BenchmarkSnapshot::from_stats(
    Samples::new("case").add_nanos(80L).stats(),
  )
  let regressed = TrendSeries::new("case")
    .add_snapshot("r1", "base", base)
    .add_snapshot("r2", "slow", slow)
  let improved = TrendSeries::new("case")
    .add_snapshot("r1", "base", base)
    .add_snapshot("r2", "fast", fast)
  assert_true(regressed.direction(5.0) == TrendRegressed)
  assert_true(improved.direction(5.0) == TrendImproved)
  assert_eq(regressed.best().label(), "base")
  assert_eq(improved.best().label(), "fast")
}

///|
test "trend report groups manifests by benchmark name" {
  let baseline = BaselineManifest::from_suite(
    "r1",
    "base",
    BenchmarkSuite::new("suite")
    .add_samples(Samples::new("case").add_nanos(100L))
    .finish(),
  )
  let candidate = BaselineManifest::from_suite(
    "r2",
    "candidate",
    BenchmarkSuite::new("suite")
    .add_samples(Samples::new("case").add_nanos(120L))
    .finish(),
  )
  let report = TrendReport::from_manifests([baseline, candidate])
  assert_eq(report.len(), 1)
  assert_eq(report.regression_count(5.0), 1)
  assert_true(report.render_markdown(5.0).contains("Trend report"))
}

///|
test "trend summary handles insufficient points" {
  let series = TrendSeries::new("empty")
  let summary = series.summary(5.0)
  assert_true(summary.direction() == TrendInsufficient)
  assert_true(summary.summary().contains("insufficient"))
}
