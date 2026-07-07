///|
pub struct Stats {
  name : String
  count : Int
  min : Duration
  max : Duration
  mean : Duration
  median : Duration
  p90 : Duration
  p95 : Duration
  p99 : Duration
  stddev : Duration
  variance_nanos : Double
  mad : Duration
  relative_stddev : Double
}

///|
fn sorted_int64(values : Array[Int64]) -> Array[Int64] {
  let out = values.copy()
  for i = 1; i < out.length(); i = i + 1 {
    let current = out[i]
    let mut j = i - 1
    while j >= 0 && out[j] > current {
      out[j + 1] = out[j]
      j = j - 1
    }
    out[j + 1] = current
  }
  out
}

///|
fn nanos_from_samples(samples : Samples) -> Array[Int64] {
  let values : Array[Int64] = []
  for i = 0; i < samples.len(); i = i + 1 {
    values.push(samples.get(i).nanos())
  }
  values
}

///|
fn clamp_percent(percent : Double) -> Double {
  if percent < 0.0 {
    0.0
  } else if percent > 1.0 {
    1.0
  } else {
    percent
  }
}

///|
fn percentile_nearest(values : Array[Int64], percent : Double) -> Duration {
  if values.length() == 0 {
    Duration::zero()
  } else {
    let rank = ((values.length() - 1).to_double() * clamp_percent(percent)).to_int()
    Duration::from_nanos(values[rank])
  }
}

///|
fn percentile_linear(values : Array[Int64], percent : Double) -> Duration {
  if values.length() == 0 {
    Duration::zero()
  } else if values.length() == 1 {
    Duration::from_nanos(values[0])
  } else {
    let position = (values.length() - 1).to_double() * clamp_percent(percent)
    let lower = position.to_int()
    let upper = if lower + 1 >= values.length() { lower } else { lower + 1 }
    let weight = position - lower.to_double()
    let low = values[lower].to_double()
    let high = values[upper].to_double()
    Duration::from_nanos((low + (high - low) * weight).to_int64())
  }
}

///|
fn mean(values : Array[Int64]) -> Duration {
  if values.length() == 0 {
    Duration::zero()
  } else {
    let mut total = 0L
    for value in values {
      total = total + value
    }
    Duration::from_nanos(total / values.length().to_int64())
  }
}

///|
fn variance(values : Array[Int64], avg : Duration) -> Double {
  if values.length() <= 1 {
    0.0
  } else {
    let mut total = 0.0
    let center = avg.nanos().to_double()
    for value in values {
      let diff = value.to_double() - center
      total = total + diff * diff
    }
    total / values.length().to_double()
  }
}

///|
fn stddev_from_variance(value : Double) -> Duration {
  Duration::from_nanos(value.sqrt().to_int64())
}

///|
fn median_absolute_deviation(
  values : Array[Int64],
  center : Duration,
) -> Duration {
  if values.length() == 0 {
    Duration::zero()
  } else {
    let deviations : Array[Int64] = []
    let mid = center.nanos()
    for value in values {
      let diff = if value >= mid { value - mid } else { mid - value }
      deviations.push(diff)
    }
    percentile_linear(sorted_int64(deviations), 0.5)
  }
}

///|
pub fn Stats::from_samples(samples : Samples) -> Stats {
  let values = sorted_int64(nanos_from_samples(samples))
  let avg = mean(values)
  let variance_value = variance(values, avg)
  let std = stddev_from_variance(variance_value)
  let med = percentile_linear(values, 0.5)
  let relative = if avg.nanos() == 0L {
    0.0
  } else {
    std.nanos().to_double() / avg.nanos().to_double()
  }
  {
    name: samples.name(),
    count: values.length(),
    min: percentile_nearest(values, 0.0),
    max: percentile_nearest(values, 1.0),
    mean: avg,
    median: med,
    p90: percentile_nearest(values, 0.90),
    p95: percentile_nearest(values, 0.95),
    p99: percentile_nearest(values, 0.99),
    stddev: std,
    variance_nanos: variance_value,
    mad: median_absolute_deviation(values, med),
    relative_stddev: relative,
  }
}

///|
pub fn Samples::percentile(self : Samples, percent : Double) -> Duration {
  percentile_linear(sorted_int64(nanos_from_samples(self)), percent)
}

///|
pub fn Samples::without_min_max(self : Samples) -> Samples {
  if self.len() <= 2 {
    self
  } else {
    let values = sorted_int64(nanos_from_samples(self))
    let mut out = Samples::new(self.name())
    for i = 1; i < values.length() - 1; i = i + 1 {
      out = out.add_nanos(values[i])
    }
    out
  }
}

///|
pub fn Stats::name(self : Stats) -> String {
  self.name
}

///|
pub fn Stats::count(self : Stats) -> Int {
  self.count
}

///|
pub fn Stats::min(self : Stats) -> Duration {
  self.min
}

///|
pub fn Stats::max(self : Stats) -> Duration {
  self.max
}

///|
pub fn Stats::mean(self : Stats) -> Duration {
  self.mean
}

///|
pub fn Stats::median(self : Stats) -> Duration {
  self.median
}

///|
pub fn Stats::p90(self : Stats) -> Duration {
  self.p90
}

///|
pub fn Stats::p95(self : Stats) -> Duration {
  self.p95
}

///|
pub fn Stats::p99(self : Stats) -> Duration {
  self.p99
}

///|
pub fn Stats::stddev(self : Stats) -> Duration {
  self.stddev
}

///|
pub fn Stats::variance_nanos(self : Stats) -> Double {
  self.variance_nanos
}

///|
pub fn Stats::mad(self : Stats) -> Duration {
  self.mad
}

///|
pub fn Stats::relative_stddev(self : Stats) -> Double {
  self.relative_stddev
}

///|
pub fn Stats::to_line(self : Stats) -> String {
  "\{self.name}: n=\{self.count}, mean=\{self.mean.format()}, median=\{self.median.format()}, p95=\{self.p95.format()}, rsd=\{self.relative_stddev}"
}

///|
test "stats calculate common metrics" {
  let samples = Samples::new("case")
    .add_nanos(30L)
    .add_nanos(10L)
    .add_nanos(20L)
  let stats = samples.stats()
  assert_eq(stats.count(), 3)
  assert_eq(stats.min().nanos(), 10L)
  assert_eq(stats.max().nanos(), 30L)
  assert_eq(stats.mean().nanos(), 20L)
  assert_eq(stats.median().nanos(), 20L)
}

///|
test "stats handle empty and single sample inputs" {
  let empty = Samples::new("empty").stats()
  assert_eq(empty.count(), 0)
  assert_eq(empty.mean().nanos(), 0L)
  let single = Samples::new("single").add_nanos(42L).stats()
  assert_eq(single.count(), 1)
  assert_eq(single.stddev().nanos(), 0L)
  assert_eq(single.mad().nanos(), 0L)
}

///|
test "stats expose variance and relative stddev" {
  let stats = Samples::new("spread")
    .add_nanos(10L)
    .add_nanos(20L)
    .add_nanos(30L)
    .stats()
  assert_true(stats.variance_nanos() > 0.0)
  assert_true(stats.relative_stddev() > 0.0)
}

///|
test "samples can trim min and max" {
  let samples = Samples::new("trim")
    .add_nanos(1L)
    .add_nanos(10L)
    .add_nanos(20L)
    .add_nanos(100L)
  let trimmed = samples.without_min_max()
  assert_eq(trimmed.len(), 2)
  let stats = trimmed.stats()
  assert_eq(stats.min().nanos(), 10L)
  assert_eq(stats.max().nanos(), 20L)
}
