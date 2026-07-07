///|
pub struct CalibrationPolicy {
  min_batch_size : Int
  max_batch_size : Int
  target_elapsed : Duration
  max_probe_runs : Int
  growth_factor : Int
}

///|
pub struct CalibrationProbe {
  batch_size : Int
  elapsed : Duration
  per_iteration : Duration
}

///|
pub struct CalibrationReport {
  task_name : String
  selected_batch_size : Int
  target_elapsed : Duration
  probes : Array[CalibrationProbe]
  reached_target : Bool
}

///|
pub struct CalibratedTask {
  task : BenchmarkTask
  report : CalibrationReport
}

///|
pub struct CalibrationSuiteReport {
  runner_name : String
  reports : Array[CalibrationReport]
}

///|
fn clamp_int(value : Int, low : Int, high : Int) -> Int {
  if value < low {
    low
  } else if value > high {
    high
  } else {
    value
  }
}

///|
pub fn CalibrationPolicy::default() -> CalibrationPolicy {
  {
    min_batch_size: 1,
    max_batch_size: 4096,
    target_elapsed: Duration::from_micros(500L),
    max_probe_runs: 12,
    growth_factor: 2,
  }
}

///|
pub fn CalibrationPolicy::new(
  min_batch_size : Int,
  max_batch_size : Int,
  target_elapsed : Duration,
) -> CalibrationPolicy {
  {
    min_batch_size,
    max_batch_size,
    target_elapsed,
    max_probe_runs: 12,
    growth_factor: 2,
  }.sanitize()
}

///|
pub fn CalibrationPolicy::min_batch_size(self : CalibrationPolicy) -> Int {
  self.min_batch_size
}

///|
pub fn CalibrationPolicy::max_batch_size(self : CalibrationPolicy) -> Int {
  self.max_batch_size
}

///|
pub fn CalibrationPolicy::target_elapsed(self : CalibrationPolicy) -> Duration {
  self.target_elapsed
}

///|
pub fn CalibrationPolicy::max_probe_runs(self : CalibrationPolicy) -> Int {
  self.max_probe_runs
}

///|
pub fn CalibrationPolicy::growth_factor(self : CalibrationPolicy) -> Int {
  self.growth_factor
}

///|
pub fn CalibrationPolicy::with_min_batch_size(
  self : CalibrationPolicy,
  value : Int,
) -> CalibrationPolicy {
  {
    min_batch_size: value,
    max_batch_size: self.max_batch_size,
    target_elapsed: self.target_elapsed,
    max_probe_runs: self.max_probe_runs,
    growth_factor: self.growth_factor,
  }.sanitize()
}

///|
pub fn CalibrationPolicy::with_max_batch_size(
  self : CalibrationPolicy,
  value : Int,
) -> CalibrationPolicy {
  {
    min_batch_size: self.min_batch_size,
    max_batch_size: value,
    target_elapsed: self.target_elapsed,
    max_probe_runs: self.max_probe_runs,
    growth_factor: self.growth_factor,
  }.sanitize()
}

///|
pub fn CalibrationPolicy::with_target_elapsed(
  self : CalibrationPolicy,
  value : Duration,
) -> CalibrationPolicy {
  {
    min_batch_size: self.min_batch_size,
    max_batch_size: self.max_batch_size,
    target_elapsed: value,
    max_probe_runs: self.max_probe_runs,
    growth_factor: self.growth_factor,
  }.sanitize()
}

///|
pub fn CalibrationPolicy::with_max_probe_runs(
  self : CalibrationPolicy,
  value : Int,
) -> CalibrationPolicy {
  {
    min_batch_size: self.min_batch_size,
    max_batch_size: self.max_batch_size,
    target_elapsed: self.target_elapsed,
    max_probe_runs: value,
    growth_factor: self.growth_factor,
  }.sanitize()
}

///|
pub fn CalibrationPolicy::with_growth_factor(
  self : CalibrationPolicy,
  value : Int,
) -> CalibrationPolicy {
  {
    min_batch_size: self.min_batch_size,
    max_batch_size: self.max_batch_size,
    target_elapsed: self.target_elapsed,
    max_probe_runs: self.max_probe_runs,
    growth_factor: value,
  }.sanitize()
}

///|
pub fn CalibrationPolicy::sanitize(
  self : CalibrationPolicy,
) -> CalibrationPolicy {
  let min_size = if self.min_batch_size <= 0 { 1 } else { self.min_batch_size }
  let mut max_size = if self.max_batch_size <= 0 {
    min_size
  } else {
    self.max_batch_size
  }
  if max_size < min_size {
    max_size = min_size
  }
  let target = if self.target_elapsed.nanos() <= 0L {
    Duration::from_micros(1L)
  } else {
    self.target_elapsed
  }
  let probes = if self.max_probe_runs <= 0 { 1 } else { self.max_probe_runs }
  let growth = if self.growth_factor <= 1 { 2 } else { self.growth_factor }
  {
    min_batch_size: min_size,
    max_batch_size: max_size,
    target_elapsed: target,
    max_probe_runs: probes,
    growth_factor: growth,
  }
}

///|
pub fn CalibrationPolicy::describe(self : CalibrationPolicy) -> String {
  "calibration min_batch=\{self.min_batch_size}, max_batch=\{self.max_batch_size}, target=\{self.target_elapsed.format()}, probes=\{self.max_probe_runs}, growth=\{self.growth_factor}"
}

///|
pub fn CalibrationProbe::new(
  batch_size : Int,
  elapsed : Duration,
) -> CalibrationProbe {
  let size = if batch_size <= 0 { 1 } else { batch_size }
  { batch_size: size, elapsed, per_iteration: elapsed.divide_by(size) }
}

///|
pub fn CalibrationProbe::batch_size(self : CalibrationProbe) -> Int {
  self.batch_size
}

///|
pub fn CalibrationProbe::elapsed(self : CalibrationProbe) -> Duration {
  self.elapsed
}

///|
pub fn CalibrationProbe::per_iteration(self : CalibrationProbe) -> Duration {
  self.per_iteration
}

///|
pub fn CalibrationProbe::summary(self : CalibrationProbe) -> String {
  "batch=\{self.batch_size}, elapsed=\{self.elapsed.format()}, per_iter=\{self.per_iteration.format()}"
}

///|
pub fn CalibrationReport::new(
  task_name : String,
  selected_batch_size : Int,
  target_elapsed : Duration,
  probes : Array[CalibrationProbe],
) -> CalibrationReport {
  let mut reached = false
  for probe in probes {
    if probe.elapsed().nanos() >= target_elapsed.nanos() {
      reached = true
    }
  }
  {
    task_name,
    selected_batch_size: if selected_batch_size <= 0 {
      1
    } else {
      selected_batch_size
    },
    target_elapsed,
    probes: probes.copy(),
    reached_target: reached,
  }
}

///|
pub fn CalibrationReport::task_name(self : CalibrationReport) -> String {
  self.task_name
}

///|
pub fn CalibrationReport::selected_batch_size(self : CalibrationReport) -> Int {
  self.selected_batch_size
}

///|
pub fn CalibrationReport::target_elapsed(self : CalibrationReport) -> Duration {
  self.target_elapsed
}

///|
pub fn CalibrationReport::len(self : CalibrationReport) -> Int {
  self.probes.length()
}

///|
pub fn CalibrationReport::get(
  self : CalibrationReport,
  index : Int,
) -> CalibrationProbe {
  self.probes[index]
}

///|
pub fn CalibrationReport::probes(
  self : CalibrationReport,
) -> Array[CalibrationProbe] {
  self.probes.copy()
}

///|
pub fn CalibrationReport::reached_target(self : CalibrationReport) -> Bool {
  self.reached_target
}

///|
pub fn CalibrationReport::last_probe(
  self : CalibrationReport,
) -> CalibrationProbe {
  if self.probes.length() == 0 {
    CalibrationProbe::new(self.selected_batch_size, Duration::zero())
  } else {
    self.probes[self.probes.length() - 1]
  }
}

///|
pub fn CalibrationReport::summary(self : CalibrationReport) -> String {
  let state = if self.reached_target { "target-reached" } else { "maxed-out" }
  "calibrated \{self.task_name}: batch=\{self.selected_batch_size}, probes=\{self.probes.length()}, \{state}"
}

///|
pub fn CalibrationReport::render_markdown(self : CalibrationReport) -> String {
  let mut out = "### " + self.task_name + "\n\n"
  out = out +
    "- selected_batch_size: `" +
    self.selected_batch_size.to_string() +
    "`\n"
  out = out + "- target_elapsed: `" + self.target_elapsed.format() + "`\n"
  out = out + "- reached_target: `" + self.reached_target.to_string() + "`\n\n"
  out = out + "| batch | elapsed | per iteration |\n"
  out = out + "| ---: | ---: | ---: |\n"
  for probe in self.probes {
    out = out +
      "| " +
      probe.batch_size().to_string() +
      " | " +
      probe.elapsed().format() +
      " | " +
      probe.per_iteration().format() +
      " |\n"
  }
  out
}

///|
fn next_batch_size(current : Int, policy : CalibrationPolicy) -> Int {
  let grown = current * policy.growth_factor()
  if grown <= current {
    policy.max_batch_size()
  } else {
    clamp_int(grown, policy.min_batch_size(), policy.max_batch_size())
  }
}

///|
fn run_probe(
  task : BenchmarkTask,
  backend : MeasurementBackend,
  batch_size : Int,
) -> CalibrationProbe {
  let probe_task = task.with_batch_size(batch_size)
  let elapsed = backend.measure(fn() { probe_task.run_batch() })
  CalibrationProbe::new(batch_size, elapsed)
}

///|
pub fn BenchmarkTask::calibrate(
  self : BenchmarkTask,
  backend : MeasurementBackend,
  policy : CalibrationPolicy,
) -> CalibrationReport {
  let clean = policy.sanitize()
  let probes : Array[CalibrationProbe] = []
  let mut batch = clean.min_batch_size()
  let mut selected = batch
  let mut done = false
  let mut probe_count = 0
  while !done && probe_count < clean.max_probe_runs() {
    let probe = run_probe(self, backend, batch)
    selected = probe.batch_size()
    probes.push(probe)
    probe_count = probe_count + 1
    if probe.elapsed().nanos() >= clean.target_elapsed().nanos() {
      done = true
    } else if batch >= clean.max_batch_size() {
      done = true
    } else {
      batch = next_batch_size(batch, clean)
    }
  }
  CalibrationReport::new(self.name(), selected, clean.target_elapsed(), probes)
}

///|
pub fn BenchmarkTask::with_calibrated_batch_size(
  self : BenchmarkTask,
  backend : MeasurementBackend,
  policy : CalibrationPolicy,
) -> CalibratedTask {
  let report = self.calibrate(backend, policy)
  { task: self.with_batch_size(report.selected_batch_size()), report }
}

///|
pub fn CalibratedTask::task(self : CalibratedTask) -> BenchmarkTask {
  self.task
}

///|
pub fn CalibratedTask::report(self : CalibratedTask) -> CalibrationReport {
  self.report
}

///|
pub fn BenchmarkRunner::calibrate(
  self : BenchmarkRunner,
  backend : MeasurementBackend,
  policy : CalibrationPolicy,
) -> CalibrationSuiteReport {
  let reports : Array[CalibrationReport] = []
  for i = 0; i < self.len(); i = i + 1 {
    reports.push(self.task(i).calibrate(backend, policy))
  }
  { runner_name: self.name(), reports }
}

///|
pub fn BenchmarkRunner::with_calibrated_batches(
  self : BenchmarkRunner,
  backend : MeasurementBackend,
  policy : CalibrationPolicy,
) -> BenchmarkRunner {
  let mut next = BenchmarkRunner::new(self.name()).with_config(self.config())
  for i = 0; i < self.len(); i = i + 1 {
    let calibrated = self.task(i).with_calibrated_batch_size(backend, policy)
    next = next.add_task(calibrated.task())
  }
  next
}

///|
pub fn BenchmarkRunner::run_calibrated(
  self : BenchmarkRunner,
  backend : MeasurementBackend,
  policy : CalibrationPolicy,
) -> SuiteResult {
  self.with_calibrated_batches(backend, policy).run_with_backend(backend)
}

///|
pub fn CalibrationSuiteReport::runner_name(
  self : CalibrationSuiteReport,
) -> String {
  self.runner_name
}

///|
pub fn CalibrationSuiteReport::len(self : CalibrationSuiteReport) -> Int {
  self.reports.length()
}

///|
pub fn CalibrationSuiteReport::get(
  self : CalibrationSuiteReport,
  index : Int,
) -> CalibrationReport {
  self.reports[index]
}

///|
pub fn CalibrationSuiteReport::reports(
  self : CalibrationSuiteReport,
) -> Array[CalibrationReport] {
  self.reports.copy()
}

///|
pub fn CalibrationSuiteReport::render_markdown(
  self : CalibrationSuiteReport,
) -> String {
  let mut out = "## Calibration report: " + self.runner_name + "\n\n"
  for report in self.reports {
    out = out + report.render_markdown() + "\n"
  }
  out
}

///|
test "calibration policy sanitizes invalid values" {
  let policy = CalibrationPolicy::default()
    .with_min_batch_size(-1)
    .with_max_batch_size(0)
    .with_target_elapsed(Duration::zero())
    .with_max_probe_runs(0)
    .with_growth_factor(1)
  assert_eq(policy.min_batch_size(), 1)
  assert_eq(policy.max_batch_size(), 1)
  assert_eq(policy.target_elapsed().nanos(), 1000L)
  assert_eq(policy.max_probe_runs(), 1)
  assert_eq(policy.growth_factor(), 2)
}

///|
test "task calibration grows until target duration" {
  let mut calls = 0
  let task = BenchmarkTask::new("case", fn() { calls = calls + 1 })
  let backend = MeasurementBackend::scripted([
    Duration::from_nanos(10L),
    Duration::from_nanos(25L),
    Duration::from_nanos(55L),
  ])
  let policy = CalibrationPolicy::default()
    .with_min_batch_size(1)
    .with_max_batch_size(8)
    .with_target_elapsed(Duration::from_nanos(50L))
    .with_max_probe_runs(4)
  let report = task.calibrate(backend, policy)
  assert_eq(report.selected_batch_size(), 4)
  assert_eq(report.len(), 3)
  assert_true(report.reached_target())
  assert_eq(calls, 7)
}

///|
test "runner can produce calibration report" {
  let runner = BenchmarkRunner::new("cal")
    .add("a", fn() { () })
    .add("b", fn() { () })
  let report = runner.calibrate(
    MeasurementBackend::fixed(Duration::from_nanos(100L)),
    CalibrationPolicy::default().with_target_elapsed(Duration::from_nanos(50L)),
  )
  assert_eq(report.len(), 2)
  assert_true(report.render_markdown().contains("Calibration report"))
}
