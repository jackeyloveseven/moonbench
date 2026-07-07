///|
pub struct Metric {
  name : String
  value : Double
  unit : String
}

///|
pub struct MetricSet {
  metrics : Array[Metric]
}

///|
pub struct Throughput {
  items : Int64
  bytes : Int64
  elapsed : Duration
}

///|
pub fn Metric::new(name : String, value : Double, unit : String) -> Metric {
  { name, value, unit }
}

///|
pub fn Metric::name(self : Metric) -> String {
  self.name
}

///|
pub fn Metric::value(self : Metric) -> Double {
  self.value
}

///|
pub fn Metric::unit(self : Metric) -> String {
  self.unit
}

///|
pub fn Metric::format(self : Metric) -> String {
  "\{self.name}=\{self.value} \{self.unit}"
}

///|
pub fn MetricSet::new() -> MetricSet {
  { metrics: [] }
}

///|
pub fn MetricSet::add(self : MetricSet, metric : Metric) -> MetricSet {
  let metrics = self.metrics.copy()
  metrics.push(metric)
  { metrics, }
}

///|
pub fn MetricSet::len(self : MetricSet) -> Int {
  self.metrics.length()
}

///|
pub fn MetricSet::get(self : MetricSet, index : Int) -> Metric {
  self.metrics[index]
}

///|
pub fn MetricSet::metrics(self : MetricSet) -> Array[Metric] {
  self.metrics.copy()
}

///|
pub fn MetricSet::render(self : MetricSet) -> String {
  let mut out = ""
  for i = 0; i < self.metrics.length(); i = i + 1 {
    if i > 0 {
      out = out + ", "
    }
    out = out + self.metrics[i].format()
  }
  out
}

///|
pub fn Throughput::new(
  items : Int64,
  bytes : Int64,
  elapsed : Duration,
) -> Throughput {
  { items, bytes, elapsed }
}

///|
pub fn Throughput::items(self : Throughput) -> Int64 {
  self.items
}

///|
pub fn Throughput::bytes(self : Throughput) -> Int64 {
  self.bytes
}

///|
pub fn Throughput::elapsed(self : Throughput) -> Duration {
  self.elapsed
}

///|
pub fn Throughput::items_per_second(self : Throughput) -> Double {
  if self.elapsed.nanos() == 0L {
    0.0
  } else {
    self.items.to_double() / self.elapsed.secs()
  }
}

///|
pub fn Throughput::bytes_per_second(self : Throughput) -> Double {
  if self.elapsed.nanos() == 0L {
    0.0
  } else {
    self.bytes.to_double() / self.elapsed.secs()
  }
}

///|
pub fn Throughput::to_metrics(self : Throughput) -> MetricSet {
  MetricSet::new()
  .add(Metric::new("items_per_second", self.items_per_second(), "items/s"))
  .add(Metric::new("bytes_per_second", self.bytes_per_second(), "bytes/s"))
}

///|
pub fn Stats::throughput(
  self : Stats,
  items : Int64,
  bytes : Int64,
) -> Throughput {
  Throughput::new(items, bytes, self.mean())
}

///|
test "metric set renders custom metrics" {
  let metrics = MetricSet::new()
    .add(Metric::new("compares", 42.0, "compares/op"))
    .add(Metric::new("allocs", 0.0, "allocs/op"))
  assert_eq(metrics.len(), 2)
  assert_true(metrics.render().length() > 20)
}

///|
test "throughput derives per second metrics from stats" {
  let stats = Samples::new("case").add(Duration::from_millis(2L)).stats()
  let throughput = stats.throughput(10L, 100L)
  assert_true(throughput.items_per_second() == 5000.0)
  assert_eq(throughput.to_metrics().len(), 2)
}
