///|
pub struct BenchmarkLifecycle {
  setup_suite : () -> Unit
  teardown_suite : () -> Unit
  setup_case : (String) -> Unit
  teardown_case : (String) -> Unit
  before_measure : (String, Int) -> Unit
  after_measure : (String, Int, Duration) -> Unit
}

///|
pub struct LifecycleEvent {
  name : String
  case_name : String
  run_index : Int
  elapsed : Duration
}

///|
pub struct LifecycleLog {
  events : Array[LifecycleEvent]
}

///|
pub struct LifecycleRunSummary {
  suite : SuiteResult
  log : LifecycleLog
}

///|
pub fn BenchmarkLifecycle::noop() -> BenchmarkLifecycle {
  {
    setup_suite: fn() { () },
    teardown_suite: fn() { () },
    setup_case: fn(_name) { () },
    teardown_case: fn(_name) { () },
    before_measure: fn(_name, _index) { () },
    after_measure: fn(_name, _index, _elapsed) { () },
  }
}

///|
pub fn BenchmarkLifecycle::with_setup_suite(
  self : BenchmarkLifecycle,
  hook : () -> Unit,
) -> BenchmarkLifecycle {
  {
    setup_suite: hook,
    teardown_suite: self.teardown_suite,
    setup_case: self.setup_case,
    teardown_case: self.teardown_case,
    before_measure: self.before_measure,
    after_measure: self.after_measure,
  }
}

///|
pub fn BenchmarkLifecycle::with_teardown_suite(
  self : BenchmarkLifecycle,
  hook : () -> Unit,
) -> BenchmarkLifecycle {
  {
    setup_suite: self.setup_suite,
    teardown_suite: hook,
    setup_case: self.setup_case,
    teardown_case: self.teardown_case,
    before_measure: self.before_measure,
    after_measure: self.after_measure,
  }
}

///|
pub fn BenchmarkLifecycle::with_setup_case(
  self : BenchmarkLifecycle,
  hook : (String) -> Unit,
) -> BenchmarkLifecycle {
  {
    setup_suite: self.setup_suite,
    teardown_suite: self.teardown_suite,
    setup_case: hook,
    teardown_case: self.teardown_case,
    before_measure: self.before_measure,
    after_measure: self.after_measure,
  }
}

///|
pub fn BenchmarkLifecycle::with_teardown_case(
  self : BenchmarkLifecycle,
  hook : (String) -> Unit,
) -> BenchmarkLifecycle {
  {
    setup_suite: self.setup_suite,
    teardown_suite: self.teardown_suite,
    setup_case: self.setup_case,
    teardown_case: hook,
    before_measure: self.before_measure,
    after_measure: self.after_measure,
  }
}

///|
pub fn BenchmarkLifecycle::with_before_measure(
  self : BenchmarkLifecycle,
  hook : (String, Int) -> Unit,
) -> BenchmarkLifecycle {
  {
    setup_suite: self.setup_suite,
    teardown_suite: self.teardown_suite,
    setup_case: self.setup_case,
    teardown_case: self.teardown_case,
    before_measure: hook,
    after_measure: self.after_measure,
  }
}

///|
pub fn BenchmarkLifecycle::with_after_measure(
  self : BenchmarkLifecycle,
  hook : (String, Int, Duration) -> Unit,
) -> BenchmarkLifecycle {
  {
    setup_suite: self.setup_suite,
    teardown_suite: self.teardown_suite,
    setup_case: self.setup_case,
    teardown_case: self.teardown_case,
    before_measure: self.before_measure,
    after_measure: hook,
  }
}

///|
pub fn BenchmarkLifecycle::run_setup_suite(self : BenchmarkLifecycle) -> Unit {
  (self.setup_suite)()
}

///|
pub fn BenchmarkLifecycle::run_teardown_suite(
  self : BenchmarkLifecycle,
) -> Unit {
  (self.teardown_suite)()
}

///|
pub fn BenchmarkLifecycle::run_setup_case(
  self : BenchmarkLifecycle,
  case_name : String,
) -> Unit {
  (self.setup_case)(case_name)
}

///|
pub fn BenchmarkLifecycle::run_teardown_case(
  self : BenchmarkLifecycle,
  case_name : String,
) -> Unit {
  (self.teardown_case)(case_name)
}

///|
pub fn BenchmarkLifecycle::run_before_measure(
  self : BenchmarkLifecycle,
  case_name : String,
  run_index : Int,
) -> Unit {
  (self.before_measure)(case_name, run_index)
}

///|
pub fn BenchmarkLifecycle::run_after_measure(
  self : BenchmarkLifecycle,
  case_name : String,
  run_index : Int,
  elapsed : Duration,
) -> Unit {
  (self.after_measure)(case_name, run_index, elapsed)
}

///|
pub fn LifecycleEvent::new(
  name : String,
  case_name : String,
  run_index : Int,
  elapsed : Duration,
) -> LifecycleEvent {
  { name, case_name, run_index, elapsed }
}

///|
pub fn LifecycleEvent::name(self : LifecycleEvent) -> String {
  self.name
}

///|
pub fn LifecycleEvent::case_name(self : LifecycleEvent) -> String {
  self.case_name
}

///|
pub fn LifecycleEvent::run_index(self : LifecycleEvent) -> Int {
  self.run_index
}

///|
pub fn LifecycleEvent::elapsed(self : LifecycleEvent) -> Duration {
  self.elapsed
}

///|
pub fn LifecycleEvent::summary(self : LifecycleEvent) -> String {
  "\{self.name} case=\{self.case_name}, run=\{self.run_index}, elapsed=\{self.elapsed.format()}"
}

///|
pub fn LifecycleLog::new() -> LifecycleLog {
  { events: [] }
}

///|
pub fn LifecycleLog::len(self : LifecycleLog) -> Int {
  self.events.length()
}

///|
pub fn LifecycleLog::get(self : LifecycleLog, index : Int) -> LifecycleEvent {
  self.events[index]
}

///|
pub fn LifecycleLog::events(self : LifecycleLog) -> Array[LifecycleEvent] {
  self.events.copy()
}

///|
pub fn LifecycleLog::add(
  self : LifecycleLog,
  event : LifecycleEvent,
) -> LifecycleLog {
  let events = self.events.copy()
  events.push(event)
  { events, }
}

///|
pub fn LifecycleLog::count_named(self : LifecycleLog, name : String) -> Int {
  let mut count = 0
  for event in self.events {
    if event.name() == name {
      count = count + 1
    }
  }
  count
}

///|
pub fn LifecycleLog::render_text(self : LifecycleLog) -> String {
  let mut out = ""
  for event in self.events {
    out = out + event.summary() + "\n"
  }
  out
}

///|
fn log_event(
  log : LifecycleLog,
  name : String,
  case_name : String,
  run_index : Int,
  elapsed : Duration,
) -> LifecycleLog {
  log.add(LifecycleEvent::new(name, case_name, run_index, elapsed))
}

///|
fn run_task_with_lifecycle(
  task : BenchmarkTask,
  config : BenchmarkConfig,
  backend : MeasurementBackend,
  lifecycle : BenchmarkLifecycle,
  log : LifecycleLog,
) -> (BenchmarkResult, LifecycleLog) {
  let mut next_log = log
  lifecycle.run_setup_case(task.name())
  next_log = log_event(
    next_log,
    "setup_case",
    task.name(),
    -1,
    Duration::zero(),
  )
  for i = 0; i < config.warmup_runs(); i = i + 1 {
    task.run_batch()
    next_log = log_event(next_log, "warmup", task.name(), i, Duration::zero())
  }
  let mut samples = Samples::new(task.name())
  for i = 0; i < config.measure_runs(); i = i + 1 {
    lifecycle.run_before_measure(task.name(), i)
    next_log = log_event(
      next_log,
      "before_measure",
      task.name(),
      i,
      Duration::zero(),
    )
    let elapsed = backend.measure(fn() { task.run_batch() })
    lifecycle.run_after_measure(task.name(), i, elapsed)
    next_log = log_event(next_log, "after_measure", task.name(), i, elapsed)
    samples = samples.add(elapsed.divide_by(task.batch_size()))
  }
  lifecycle.run_teardown_case(task.name())
  next_log = log_event(
    next_log,
    "teardown_case",
    task.name(),
    -1,
    Duration::zero(),
  )
  (BenchmarkResult::from_samples(task.name(), samples, config), next_log)
}

///|
pub fn BenchmarkRunner::run_with_lifecycle(
  self : BenchmarkRunner,
  backend : MeasurementBackend,
  lifecycle : BenchmarkLifecycle,
) -> LifecycleRunSummary {
  let config = self.config()
  let mut suite = BenchmarkSuite::new(self.name()).with_config(config)
  let mut log = LifecycleLog::new()
  lifecycle.run_setup_suite()
  log = log_event(log, "setup_suite", self.name(), -1, Duration::zero())
  for i = 0; i < self.len(); i = i + 1 {
    let pair = run_task_with_lifecycle(
      self.task(i),
      config,
      backend,
      lifecycle,
      log,
    )
    suite = suite.add_result(pair.0)
    log = pair.1
  }
  lifecycle.run_teardown_suite()
  log = log_event(log, "teardown_suite", self.name(), -1, Duration::zero())
  { suite: suite.finish(), log }
}

///|
pub fn LifecycleRunSummary::suite(self : LifecycleRunSummary) -> SuiteResult {
  self.suite
}

///|
pub fn LifecycleRunSummary::log(self : LifecycleRunSummary) -> LifecycleLog {
  self.log
}

///|
pub fn LifecycleRunSummary::summary(self : LifecycleRunSummary) -> String {
  "lifecycle suite=\{self.suite.name()}, cases=\{self.suite.len()}, events=\{self.log.len()}"
}

///|
pub fn LifecycleRunSummary::render_markdown(
  self : LifecycleRunSummary,
) -> String {
  let mut out = "## Lifecycle run\n\n"
  out = out + "- suite: `" + self.suite.name() + "`\n"
  out = out + "- cases: `" + self.suite.len().to_string() + "`\n"
  out = out + "- events: `" + self.log.len().to_string() + "`\n\n"
  out = out + "```text\n"
  out = out + self.log.render_text()
  out = out + "```\n"
  out
}

///|
test "lifecycle hooks run around benchmark measurements" {
  let mut marker = 0
  let lifecycle = BenchmarkLifecycle::noop()
    .with_setup_suite(fn() { marker = marker + 10 })
    .with_teardown_suite(fn() { marker = marker + 100 })
    .with_setup_case(fn(_name) { marker = marker + 1 })
    .with_teardown_case(fn(_name) { marker = marker + 1 })
    .with_before_measure(fn(_name, _index) { marker = marker + 2 })
    .with_after_measure(fn(_name, _index, _elapsed) { marker = marker + 3 })
  let summary = BenchmarkRunner::new("life")
    .with_config(
      BenchmarkConfig::default().with_warmup_runs(1).with_measure_runs(2),
    )
    .add("case", fn() { () })
    .run_with_lifecycle(
      MeasurementBackend::fixed(Duration::from_nanos(10L)),
      lifecycle,
    )
  assert_eq(summary.suite().len(), 1)
  assert_eq(summary.log().count_named("before_measure"), 2)
  assert_eq(summary.log().count_named("after_measure"), 2)
  assert_eq(marker, 122)
}

///|
test "lifecycle summary renders event log" {
  let summary = BenchmarkRunner::new("life")
    .with_config(
      BenchmarkConfig::default().with_warmup_runs(0).with_measure_runs(1),
    )
    .add("case", fn() { () })
    .run_with_lifecycle(
      MeasurementBackend::fixed(Duration::from_nanos(20L)),
      BenchmarkLifecycle::noop(),
    )
  assert_true(summary.summary().contains("events"))
  assert_true(summary.render_markdown().contains("after_measure"))
}
