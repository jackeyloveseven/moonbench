///|
pub struct BenchmarkCase {
  name : String
  config : BenchmarkConfig
}

///|
pub struct BenchmarkResult {
  name : String
  config : BenchmarkConfig
  raw_samples : Samples
  measured_samples : Samples
  stats : Stats
}

///|
pub struct BenchmarkSuite {
  name : String
  config : BenchmarkConfig
  results : Array[BenchmarkResult]
}

///|
pub struct SuiteResult {
  name : String
  config : BenchmarkConfig
  results : Array[BenchmarkResult]
}

///|
pub fn BenchmarkCase::new(name : String) -> BenchmarkCase {
  { name, config: BenchmarkConfig::default() }
}

///|
pub fn BenchmarkCase::with_config(
  self : BenchmarkCase,
  config : BenchmarkConfig,
) -> BenchmarkCase {
  { name: self.name, config }
}

///|
pub fn BenchmarkCase::name(self : BenchmarkCase) -> String {
  self.name
}

///|
pub fn BenchmarkCase::config(self : BenchmarkCase) -> BenchmarkConfig {
  self.config
}

///|
pub fn BenchmarkResult::from_samples(
  name : String,
  samples : Samples,
  config : BenchmarkConfig,
) -> BenchmarkResult {
  let clean_config = config.sanitize()
  let measured = if clean_config.trim_extremes() {
    samples.without_min_max()
  } else {
    samples
  }
  {
    name,
    config: clean_config,
    raw_samples: samples,
    measured_samples: measured,
    stats: measured.stats(),
  }
}

///|
pub fn BenchmarkResult::name(self : BenchmarkResult) -> String {
  self.name
}

///|
pub fn BenchmarkResult::config(self : BenchmarkResult) -> BenchmarkConfig {
  self.config
}

///|
pub fn BenchmarkResult::raw_samples(self : BenchmarkResult) -> Samples {
  self.raw_samples
}

///|
pub fn BenchmarkResult::samples(self : BenchmarkResult) -> Samples {
  self.measured_samples
}

///|
pub fn BenchmarkResult::stats(self : BenchmarkResult) -> Stats {
  self.stats
}

///|
pub fn BenchmarkResult::to_line(self : BenchmarkResult) -> String {
  self.stats.to_line()
}

///|
pub fn BenchmarkSuite::new(name : String) -> BenchmarkSuite {
  { name, config: BenchmarkConfig::default(), results: [] }
}

///|
pub fn BenchmarkSuite::with_config(
  self : BenchmarkSuite,
  config : BenchmarkConfig,
) -> BenchmarkSuite {
  { name: self.name, config: config.sanitize(), results: self.results }
}

///|
pub fn BenchmarkSuite::name(self : BenchmarkSuite) -> String {
  self.name
}

///|
pub fn BenchmarkSuite::config(self : BenchmarkSuite) -> BenchmarkConfig {
  self.config
}

///|
pub fn BenchmarkSuite::len(self : BenchmarkSuite) -> Int {
  self.results.length()
}

///|
pub fn BenchmarkSuite::add_result(
  self : BenchmarkSuite,
  result : BenchmarkResult,
) -> BenchmarkSuite {
  let results = self.results.copy()
  results.push(result)
  { name: self.name, config: self.config, results }
}

///|
pub fn BenchmarkSuite::add_samples(
  self : BenchmarkSuite,
  samples : Samples,
) -> BenchmarkSuite {
  self.add_result(
    BenchmarkResult::from_samples(samples.name(), samples, self.config),
  )
}

///|
pub fn BenchmarkSuite::finish(self : BenchmarkSuite) -> SuiteResult {
  { name: self.name, config: self.config, results: self.results.copy() }
}

///|
pub fn SuiteResult::name(self : SuiteResult) -> String {
  self.name
}

///|
pub fn SuiteResult::config(self : SuiteResult) -> BenchmarkConfig {
  self.config
}

///|
pub fn SuiteResult::len(self : SuiteResult) -> Int {
  self.results.length()
}

///|
pub fn SuiteResult::get(self : SuiteResult, index : Int) -> BenchmarkResult {
  self.results[index]
}

///|
pub fn SuiteResult::results(self : SuiteResult) -> Array[BenchmarkResult] {
  self.results.copy()
}

///|
pub fn SuiteResult::stats(self : SuiteResult) -> Array[Stats] {
  let out : Array[Stats] = []
  for result in self.results {
    out.push(result.stats())
  }
  out
}

///|
pub fn SuiteResult::to_report(self : SuiteResult) -> Report {
  let mut report = Report::new(self.name)
  for result in self.results {
    report = report.add(result.stats())
  }
  report
}

///|
test "suite aggregates deterministic sample results" {
  let suite = BenchmarkSuite::new("suite")
    .add_samples(Samples::new("a").add_nanos(10L).add_nanos(12L))
    .add_samples(Samples::new("b").add_nanos(20L).add_nanos(22L))
    .finish()
  assert_eq(suite.len(), 2)
  assert_eq(suite.get(0).stats().count(), 2)
}

///|
test "suite can trim extremes through config" {
  let config = BenchmarkConfig::default().with_trim_extremes(true)
  let suite = BenchmarkSuite::new("trimmed")
    .with_config(config)
    .add_samples(
      Samples::new("case")
      .add_nanos(1L)
      .add_nanos(10L)
      .add_nanos(20L)
      .add_nanos(100L),
    )
    .finish()
  assert_eq(suite.get(0).samples().len(), 2)
  assert_eq(suite.get(0).stats().mean().nanos(), 15L)
}
