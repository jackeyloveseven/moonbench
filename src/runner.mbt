///|
pub struct BenchmarkTask {
  name : String
  batch_size : Int
  workload : () -> Unit
}

///|
pub struct MeasurementBackend {
  name : String
  measure_once : (() -> Unit) -> Duration
}

///|
pub struct BenchmarkRunner {
  name : String
  config : BenchmarkConfig
  tasks : Array[BenchmarkTask]
}

///|
pub fn BenchmarkTask::new(
  name : String,
  workload : () -> Unit,
) -> BenchmarkTask {
  { name, batch_size: 1, workload }
}

///|
pub fn BenchmarkTask::with_batch_size(
  self : BenchmarkTask,
  batch_size : Int,
) -> BenchmarkTask {
  let size = if batch_size <= 0 { 1 } else { batch_size }
  { name: self.name, batch_size: size, workload: self.workload }
}

///|
pub fn BenchmarkTask::name(self : BenchmarkTask) -> String {
  self.name
}

///|
pub fn BenchmarkTask::batch_size(self : BenchmarkTask) -> Int {
  self.batch_size
}

///|
pub fn BenchmarkTask::run_once(self : BenchmarkTask) -> Unit {
  (self.workload)()
}

///|
pub fn BenchmarkTask::run_batch(self : BenchmarkTask) -> Unit {
  for _i = 0; _i < self.batch_size; _i = _i + 1 {
    (self.workload)()
  }
}

///|
pub fn MeasurementBackend::new(
  name : String,
  measure_once : (() -> Unit) -> Duration,
) -> MeasurementBackend {
  { name, measure_once }
}

///|
pub fn MeasurementBackend::name(self : MeasurementBackend) -> String {
  self.name
}

///|
pub fn MeasurementBackend::measure(
  self : MeasurementBackend,
  workload : () -> Unit,
) -> Duration {
  (self.measure_once)(workload)
}

///|
pub fn MeasurementBackend::fixed(elapsed : Duration) -> MeasurementBackend {
  MeasurementBackend::new("fixed", fn(workload) {
    workload()
    elapsed
  })
}

///|
pub fn MeasurementBackend::scripted(
  durations : Array[Duration],
) -> MeasurementBackend {
  let mut index = 0
  MeasurementBackend::new("scripted", fn(workload) {
    workload()
    if durations.length() == 0 {
      Duration::zero()
    } else {
      let current = durations[index]
      if index + 1 < durations.length() {
        index = index + 1
      }
      current
    }
  })
}

///|
pub fn MeasurementBackend::monotonic() -> MeasurementBackend {
  MeasurementBackend::new("monotonic", fn(workload) {
    let started = @corebench.monotonic_clock_start()
    workload()
    let elapsed_micros = @corebench.monotonic_clock_end(started)
    Duration::from_nanos((elapsed_micros * 1000.0).to_int64())
  })
}

///|
pub fn BenchmarkRunner::new(name : String) -> BenchmarkRunner {
  { name, config: BenchmarkConfig::default(), tasks: [] }
}

///|
pub fn BenchmarkRunner::with_config(
  self : BenchmarkRunner,
  config : BenchmarkConfig,
) -> BenchmarkRunner {
  { name: self.name, config: config.sanitize(), tasks: self.tasks }
}

///|
pub fn BenchmarkRunner::name(self : BenchmarkRunner) -> String {
  self.name
}

///|
pub fn BenchmarkRunner::config(self : BenchmarkRunner) -> BenchmarkConfig {
  self.config
}

///|
pub fn BenchmarkRunner::len(self : BenchmarkRunner) -> Int {
  self.tasks.length()
}

///|
pub fn BenchmarkRunner::task(
  self : BenchmarkRunner,
  index : Int,
) -> BenchmarkTask {
  self.tasks[index]
}

///|
pub fn BenchmarkRunner::add_task(
  self : BenchmarkRunner,
  task : BenchmarkTask,
) -> BenchmarkRunner {
  let tasks = self.tasks.copy()
  tasks.push(task)
  { name: self.name, config: self.config, tasks }
}

///|
pub fn BenchmarkRunner::add(
  self : BenchmarkRunner,
  name : String,
  workload : () -> Unit,
) -> BenchmarkRunner {
  self.add_task(BenchmarkTask::new(name, workload))
}

///|
fn run_task_with_backend(
  task : BenchmarkTask,
  config : BenchmarkConfig,
  backend : MeasurementBackend,
) -> BenchmarkResult {
  for _i = 0; _i < config.warmup_runs(); _i = _i + 1 {
    task.run_batch()
  }
  let mut samples = Samples::new(task.name())
  for _i = 0; _i < config.measure_runs(); _i = _i + 1 {
    let elapsed = backend.measure(fn() { task.run_batch() })
    samples = samples.add(elapsed.divide_by(task.batch_size()))
  }
  BenchmarkResult::from_samples(task.name(), samples, config)
}

///|
pub fn BenchmarkRunner::run_with_backend(
  self : BenchmarkRunner,
  backend : MeasurementBackend,
) -> SuiteResult {
  let mut suite = BenchmarkSuite::new(self.name).with_config(self.config)
  for task in self.tasks {
    suite = suite.add_result(run_task_with_backend(task, self.config, backend))
  }
  suite.finish()
}

///|
pub fn BenchmarkRunner::run_fixed(
  self : BenchmarkRunner,
  elapsed : Duration,
) -> SuiteResult {
  self.run_with_backend(MeasurementBackend::fixed(elapsed))
}

///|
pub fn BenchmarkRunner::run(self : BenchmarkRunner) -> SuiteResult {
  self.run_with_backend(MeasurementBackend::monotonic())
}

///|
test "runner executes warmup and measured batches" {
  let mut calls = 0
  let config = BenchmarkConfig::default()
    .with_warmup_runs(2)
    .with_measure_runs(3)
  let task = BenchmarkTask::new("unit", fn() { calls = calls + 1 }).with_batch_size(
    4,
  )
  let suite = BenchmarkRunner::new("runner")
    .with_config(config)
    .add_task(task)
    .run_fixed(Duration::from_nanos(40L))
  assert_eq(suite.len(), 1)
  assert_eq(suite.get(0).samples().len(), 3)
  assert_eq(suite.get(0).stats().mean().nanos(), 10L)
  assert_eq(calls, 20)
}

///|
test "runner supports scripted measurement backend" {
  let backend = MeasurementBackend::scripted([
    Duration::from_nanos(30L),
    Duration::from_nanos(20L),
    Duration::from_nanos(10L),
  ])
  let suite = BenchmarkRunner::new("scripted")
    .with_config(
      BenchmarkConfig::default().with_warmup_runs(0).with_measure_runs(3),
    )
    .add("case", fn() { () })
    .run_with_backend(backend)
  assert_eq(suite.get(0).stats().min().nanos(), 10L)
  assert_eq(suite.get(0).stats().max().nanos(), 30L)
}
