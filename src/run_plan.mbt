///|
pub enum BenchmarkRunProfile {
  SmokeProfile
  CiProfile
  ReleaseProfile
} derive(Eq, Debug)

///|
pub struct BenchmarkPlanCase {
  name : String
  model : BenchmarkModel
  batch_size : Int
}

///|
pub struct BenchmarkRunPlan {
  name : String
  profile : BenchmarkRunProfile
  config : BenchmarkConfig
  calibration_policy : CalibrationPolicy
  cases : Array[BenchmarkPlanCase]
}

///|
fn profile_label(profile : BenchmarkRunProfile) -> String {
  match profile {
    SmokeProfile => "smoke"
    CiProfile => "ci"
    ReleaseProfile => "release"
  }
}

///|
fn profile_config(profile : BenchmarkRunProfile) -> BenchmarkConfig {
  match profile {
    SmokeProfile =>
      BenchmarkConfig::default().with_warmup_runs(1).with_measure_runs(3)
    CiProfile =>
      BenchmarkConfig::default().with_warmup_runs(3).with_measure_runs(10)
    ReleaseProfile =>
      BenchmarkConfig::default()
      .with_warmup_runs(8)
      .with_measure_runs(40)
      .with_trim_extremes(true)
  }
}

///|
fn profile_calibration(profile : BenchmarkRunProfile) -> CalibrationPolicy {
  match profile {
    SmokeProfile =>
      CalibrationPolicy::default()
      .with_max_batch_size(64)
      .with_target_elapsed(Duration::from_micros(50L))
      .with_max_probe_runs(6)
    CiProfile =>
      CalibrationPolicy::default()
      .with_max_batch_size(2048)
      .with_target_elapsed(Duration::from_micros(500L))
      .with_max_probe_runs(10)
    ReleaseProfile =>
      CalibrationPolicy::default()
      .with_max_batch_size(16384)
      .with_target_elapsed(Duration::from_millis(2L))
      .with_max_probe_runs(16)
  }
}

///|
pub fn BenchmarkPlanCase::new(
  name : String,
  model : BenchmarkModel,
) -> BenchmarkPlanCase {
  { name, model, batch_size: 1 }
}

///|
pub fn BenchmarkPlanCase::from_model(
  model : BenchmarkModel,
) -> BenchmarkPlanCase {
  BenchmarkPlanCase::new(model.default_case(), model)
}

///|
pub fn BenchmarkPlanCase::with_batch_size(
  self : BenchmarkPlanCase,
  batch_size : Int,
) -> BenchmarkPlanCase {
  {
    name: self.name,
    model: self.model,
    batch_size: if batch_size <= 0 {
      1
    } else {
      batch_size
    },
  }
}

///|
pub fn BenchmarkPlanCase::name(self : BenchmarkPlanCase) -> String {
  self.name
}

///|
pub fn BenchmarkPlanCase::model(self : BenchmarkPlanCase) -> BenchmarkModel {
  self.model
}

///|
pub fn BenchmarkPlanCase::batch_size(self : BenchmarkPlanCase) -> Int {
  self.batch_size
}

///|
pub fn BenchmarkPlanCase::estimated_invocations(
  self : BenchmarkPlanCase,
  config : BenchmarkConfig,
) -> Int {
  (config.warmup_runs() + config.measure_runs()) * self.batch_size
}

///|
pub fn BenchmarkPlanCase::summary(
  self : BenchmarkPlanCase,
  config : BenchmarkConfig,
) -> String {
  "\{self.name}: model=\{self.model.id()}, batch=\{self.batch_size}, invocations=\{self.estimated_invocations(config)}"
}

///|
pub fn BenchmarkRunPlan::new(
  name : String,
  profile : BenchmarkRunProfile,
) -> BenchmarkRunPlan {
  {
    name,
    profile,
    config: profile_config(profile).sanitize(),
    calibration_policy: profile_calibration(profile),
    cases: [],
  }
}

///|
pub fn BenchmarkRunPlan::default_smoke() -> BenchmarkRunPlan {
  let mut plan = BenchmarkRunPlan::new(
    "MoonBench default smoke plan",
    SmokeProfile,
  )
  for model in default_benchmark_models() {
    plan = plan.add_case(BenchmarkPlanCase::from_model(model))
  }
  plan
}

///|
pub fn BenchmarkRunPlan::name(self : BenchmarkRunPlan) -> String {
  self.name
}

///|
pub fn BenchmarkRunPlan::profile(
  self : BenchmarkRunPlan,
) -> BenchmarkRunProfile {
  self.profile
}

///|
pub fn BenchmarkRunPlan::profile_label(self : BenchmarkRunPlan) -> String {
  profile_label(self.profile)
}

///|
pub fn BenchmarkRunPlan::config(self : BenchmarkRunPlan) -> BenchmarkConfig {
  self.config
}

///|
pub fn BenchmarkRunPlan::calibration_policy(
  self : BenchmarkRunPlan,
) -> CalibrationPolicy {
  self.calibration_policy
}

///|
pub fn BenchmarkRunPlan::len(self : BenchmarkRunPlan) -> Int {
  self.cases.length()
}

///|
pub fn BenchmarkRunPlan::get(
  self : BenchmarkRunPlan,
  index : Int,
) -> BenchmarkPlanCase {
  self.cases[index]
}

///|
pub fn BenchmarkRunPlan::cases(
  self : BenchmarkRunPlan,
) -> Array[BenchmarkPlanCase] {
  self.cases.copy()
}

///|
pub fn BenchmarkRunPlan::with_config(
  self : BenchmarkRunPlan,
  config : BenchmarkConfig,
) -> BenchmarkRunPlan {
  {
    name: self.name,
    profile: self.profile,
    config: config.sanitize(),
    calibration_policy: self.calibration_policy,
    cases: self.cases,
  }
}

///|
pub fn BenchmarkRunPlan::with_calibration_policy(
  self : BenchmarkRunPlan,
  policy : CalibrationPolicy,
) -> BenchmarkRunPlan {
  {
    name: self.name,
    profile: self.profile,
    config: self.config,
    calibration_policy: policy.sanitize(),
    cases: self.cases,
  }
}

///|
pub fn BenchmarkRunPlan::add_case(
  self : BenchmarkRunPlan,
  case : BenchmarkPlanCase,
) -> BenchmarkRunPlan {
  let cases = self.cases.copy()
  cases.push(case)
  {
    name: self.name,
    profile: self.profile,
    config: self.config,
    calibration_policy: self.calibration_policy,
    cases,
  }
}

///|
pub fn BenchmarkRunPlan::find_index(
  self : BenchmarkRunPlan,
  name : String,
) -> Int {
  let mut found = -1
  for i = 0; i < self.cases.length(); i = i + 1 {
    if found < 0 && self.cases[i].name() == name {
      found = i
    }
  }
  found
}

///|
pub fn BenchmarkRunPlan::has_duplicate_names(self : BenchmarkRunPlan) -> Bool {
  let mut duplicate = false
  for i = 0; i < self.cases.length(); i = i + 1 {
    for j = i + 1; j < self.cases.length(); j = j + 1 {
      if self.cases[i].name() == self.cases[j].name() {
        duplicate = true
      }
    }
  }
  duplicate
}

///|
pub fn BenchmarkRunPlan::estimated_invocations(self : BenchmarkRunPlan) -> Int {
  let mut total = 0
  for case in self.cases {
    total = total + case.estimated_invocations(self.config)
  }
  total
}

///|
pub fn BenchmarkRunPlan::validate(self : BenchmarkRunPlan) -> String {
  if self.cases.length() == 0 {
    "invalid: no benchmark cases"
  } else if self.has_duplicate_names() {
    "invalid: duplicate benchmark names"
  } else {
    "ok"
  }
}

///|
pub fn BenchmarkRunPlan::render_markdown(self : BenchmarkRunPlan) -> String {
  let mut out = "# Benchmark run plan: " + self.name + "\n\n"
  out = out + "- profile: `" + self.profile_label() + "`\n"
  out = out + "- config: `" + self.config.describe() + "`\n"
  out = out + "- calibration: `" + self.calibration_policy.describe() + "`\n"
  out = out + "- cases: `" + self.cases.length().to_string() + "`\n"
  out = out +
    "- estimated_invocations: `" +
    self.estimated_invocations().to_string() +
    "`\n"
  out = out + "- validation: `" + self.validate() + "`\n\n"
  out = out + "| case | model | batch | estimated invocations |\n"
  out = out + "| --- | --- | ---: | ---: |\n"
  for case in self.cases {
    out = out +
      "| " +
      case.name() +
      " | " +
      case.model().id() +
      " | " +
      case.batch_size().to_string() +
      " | " +
      case.estimated_invocations(self.config).to_string() +
      " |\n"
  }
  out
}

///|
pub fn BenchmarkRunPlan::summary(self : BenchmarkRunPlan) -> String {
  "plan profile=\{self.profile_label()}, cases=\{self.cases.length()}, estimated_invocations=\{self.estimated_invocations()}, validation=\{self.validate()}"
}

///|
test "default smoke run plan includes model catalog" {
  let plan = BenchmarkRunPlan::default_smoke()
  assert_eq(plan.len(), 13)
  assert_true(plan.validate() == "ok")
  assert_true(plan.estimated_invocations() > 0)
  assert_true(plan.render_markdown().contains("Benchmark run plan"))
}

///|
test "run plan detects duplicate benchmark names" {
  let model = benchmark_model_for_name("array/sort/int-10k")
  let plan = BenchmarkRunPlan::new("dup", CiProfile)
    .add_case(BenchmarkPlanCase::new("case", model))
    .add_case(BenchmarkPlanCase::new("case", model))
  assert_true(plan.has_duplicate_names())
  assert_true(plan.validate().contains("duplicate"))
}

///|
test "release profile uses heavier config than smoke" {
  let smoke = BenchmarkRunPlan::new("smoke", SmokeProfile)
  let release = BenchmarkRunPlan::new("release", ReleaseProfile)
  assert_true(release.config().measure_runs() > smoke.config().measure_runs())
  assert_true(
    release.calibration_policy().max_batch_size() >
    smoke.calibration_policy().max_batch_size(),
  )
}
