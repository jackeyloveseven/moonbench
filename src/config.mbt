///|
pub struct BenchmarkConfig {
  warmup_runs : Int
  measure_runs : Int
  noise_threshold : Double
  output_unit : DurationUnit
  trim_extremes : Bool
}

///|
pub fn BenchmarkConfig::default() -> BenchmarkConfig {
  {
    warmup_runs: 3,
    measure_runs: 10,
    noise_threshold: 2.0,
    output_unit: Microseconds,
    trim_extremes: false,
  }
}

///|
pub fn BenchmarkConfig::warmup_runs(self : BenchmarkConfig) -> Int {
  self.warmup_runs
}

///|
pub fn BenchmarkConfig::measure_runs(self : BenchmarkConfig) -> Int {
  self.measure_runs
}

///|
pub fn BenchmarkConfig::noise_threshold(self : BenchmarkConfig) -> Double {
  self.noise_threshold
}

///|
pub fn BenchmarkConfig::output_unit(self : BenchmarkConfig) -> DurationUnit {
  self.output_unit
}

///|
pub fn BenchmarkConfig::trim_extremes(self : BenchmarkConfig) -> Bool {
  self.trim_extremes
}

///|
pub fn BenchmarkConfig::with_warmup_runs(
  self : BenchmarkConfig,
  runs : Int,
) -> BenchmarkConfig {
  {
    warmup_runs: runs,
    measure_runs: self.measure_runs,
    noise_threshold: self.noise_threshold,
    output_unit: self.output_unit,
    trim_extremes: self.trim_extremes,
  }
}

///|
pub fn BenchmarkConfig::with_measure_runs(
  self : BenchmarkConfig,
  runs : Int,
) -> BenchmarkConfig {
  {
    warmup_runs: self.warmup_runs,
    measure_runs: runs,
    noise_threshold: self.noise_threshold,
    output_unit: self.output_unit,
    trim_extremes: self.trim_extremes,
  }
}

///|
pub fn BenchmarkConfig::with_noise_threshold(
  self : BenchmarkConfig,
  threshold : Double,
) -> BenchmarkConfig {
  {
    warmup_runs: self.warmup_runs,
    measure_runs: self.measure_runs,
    noise_threshold: threshold,
    output_unit: self.output_unit,
    trim_extremes: self.trim_extremes,
  }
}

///|
pub fn BenchmarkConfig::with_output_unit(
  self : BenchmarkConfig,
  unit : DurationUnit,
) -> BenchmarkConfig {
  {
    warmup_runs: self.warmup_runs,
    measure_runs: self.measure_runs,
    noise_threshold: self.noise_threshold,
    output_unit: unit,
    trim_extremes: self.trim_extremes,
  }
}

///|
pub fn BenchmarkConfig::with_trim_extremes(
  self : BenchmarkConfig,
  enabled : Bool,
) -> BenchmarkConfig {
  {
    warmup_runs: self.warmup_runs,
    measure_runs: self.measure_runs,
    noise_threshold: self.noise_threshold,
    output_unit: self.output_unit,
    trim_extremes: enabled,
  }
}

///|
pub fn BenchmarkConfig::sanitize(self : BenchmarkConfig) -> BenchmarkConfig {
  let warmup = if self.warmup_runs < 0 { 0 } else { self.warmup_runs }
  let measure = if self.measure_runs <= 0 { 1 } else { self.measure_runs }
  let noise = if self.noise_threshold < 0.0 {
    0.0
  } else {
    self.noise_threshold
  }
  {
    warmup_runs: warmup,
    measure_runs: measure,
    noise_threshold: noise,
    output_unit: self.output_unit,
    trim_extremes: self.trim_extremes,
  }
}

///|
pub fn BenchmarkConfig::describe(self : BenchmarkConfig) -> String {
  let trimmed = if self.trim_extremes { "trimmed" } else { "raw" }
  "warmup=\{self.warmup_runs}, measure=\{self.measure_runs}, noise=\{self.noise_threshold}%, samples=\{trimmed}"
}

///|
test "benchmark config defaults and builder methods" {
  let config = BenchmarkConfig::default()
    .with_warmup_runs(5)
    .with_measure_runs(20)
    .with_noise_threshold(3.5)
    .with_output_unit(Milliseconds)
    .with_trim_extremes(true)
  assert_eq(config.warmup_runs(), 5)
  assert_eq(config.measure_runs(), 20)
  assert_true(config.noise_threshold() == 3.5)
  assert_true(config.output_unit() == Milliseconds)
  assert_true(config.trim_extremes())
}

///|
test "benchmark config sanitize fixes invalid counts" {
  let config = BenchmarkConfig::default()
    .with_warmup_runs(-1)
    .with_measure_runs(0)
    .with_noise_threshold(-2.0)
    .sanitize()
  assert_eq(config.warmup_runs(), 0)
  assert_eq(config.measure_runs(), 1)
  assert_true(config.noise_threshold() == 0.0)
}
