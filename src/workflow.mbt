///|
pub struct BenchmarkWorkflow {
  run_id : String
  label : String
  runner : BenchmarkRunner
  backend : MeasurementBackend
  gate_policy : GatePolicy
}

///|
pub struct BenchmarkWorkflowResult {
  artifact : BenchmarkArtifact
  assessment_gate : GateReport
}

///|
pub fn BenchmarkWorkflow::new(
  run_id : String,
  label : String,
  runner : BenchmarkRunner,
) -> BenchmarkWorkflow {
  {
    run_id,
    label,
    runner,
    backend: MeasurementBackend::monotonic(),
    gate_policy: GatePolicy::default(),
  }
}

///|
pub fn BenchmarkWorkflow::with_backend(
  self : BenchmarkWorkflow,
  backend : MeasurementBackend,
) -> BenchmarkWorkflow {
  {
    run_id: self.run_id,
    label: self.label,
    runner: self.runner,
    backend,
    gate_policy: self.gate_policy,
  }
}

///|
pub fn BenchmarkWorkflow::with_gate_policy(
  self : BenchmarkWorkflow,
  gate_policy : GatePolicy,
) -> BenchmarkWorkflow {
  {
    run_id: self.run_id,
    label: self.label,
    runner: self.runner,
    backend: self.backend,
    gate_policy,
  }
}

///|
pub fn BenchmarkWorkflow::run_id(self : BenchmarkWorkflow) -> String {
  self.run_id
}

///|
pub fn BenchmarkWorkflow::label(self : BenchmarkWorkflow) -> String {
  self.label
}

///|
pub fn BenchmarkWorkflow::runner(self : BenchmarkWorkflow) -> BenchmarkRunner {
  self.runner
}

///|
pub fn BenchmarkWorkflow::backend(
  self : BenchmarkWorkflow,
) -> MeasurementBackend {
  self.backend
}

///|
pub fn BenchmarkWorkflow::gate_policy(self : BenchmarkWorkflow) -> GatePolicy {
  self.gate_policy
}

///|
pub fn BenchmarkWorkflowResult::artifact(
  self : BenchmarkWorkflowResult,
) -> BenchmarkArtifact {
  self.artifact
}

///|
pub fn BenchmarkWorkflowResult::assessment_gate(
  self : BenchmarkWorkflowResult,
) -> GateReport {
  self.assessment_gate
}

///|
pub fn BenchmarkWorkflow::run(
  self : BenchmarkWorkflow,
) -> BenchmarkWorkflowResult {
  let suite = self.runner.run_with_backend(self.backend)
  let assessment = SuiteAssessment::from_suite(suite)
  let gate = self.gate_policy.check_assessment(assessment)
  let artifact = BenchmarkArtifact::new(self.run_id, self.label, suite, gate)
  { artifact, assessment_gate: gate }
}

///|
pub fn BenchmarkWorkflowResult::summary(
  self : BenchmarkWorkflowResult,
) -> String {
  self.artifact.manifest()
}

///|
pub fn BenchmarkWorkflowResult::compare_against(
  self : BenchmarkWorkflowResult,
  baseline : BenchmarkArtifact,
  policy : GatePolicy,
) -> GateReport {
  let comparison = self.artifact
    .historical_run()
    .compare_against(
      baseline.historical_run(),
      policy.regression_rule().warning_slowdown_percent(),
    )
  policy.check_history(comparison)
}

///|
test "workflow runs registered tasks into artifact" {
  let runner = BenchmarkRunner::new("workflow")
    .with_config(
      BenchmarkConfig::default().with_warmup_runs(1).with_measure_runs(2),
    )
    .add_task(
      BenchmarkTask::new("array/sort/int-10k", fn() { () }).with_batch_size(4),
    )
  let workflow = BenchmarkWorkflow::new("run-1", "candidate", runner).with_backend(
    MeasurementBackend::scripted([
      Duration::from_nanos(40L),
      Duration::from_nanos(48L),
    ]),
  )
  let result = workflow.run()
  assert_true(result.summary().contains("run=run-1"))
  assert_eq(result.artifact().suite().get(0).stats().mean().nanos(), 11L)
}

///|
test "workflow result compares against baseline artifact" {
  let baseline = BenchmarkArtifact::from_suite(
    "old",
    "baseline",
    BenchmarkSuite::new("suite")
    .add_samples(Samples::new("case").add_nanos(100L))
    .finish(),
  )
  let candidate = BenchmarkArtifact::from_suite(
    "new",
    "candidate",
    BenchmarkSuite::new("suite")
    .add_samples(Samples::new("case").add_nanos(130L))
    .finish(),
  )
  let result = BenchmarkWorkflowResult::{
    artifact: candidate,
    assessment_gate: GateReport::{
      status: GatePass,
      message: "ok",
      noisy_count: 0,
      outlier_count: 0,
      regression_count: 0,
    },
  }
  assert_true(
    result.compare_against(baseline, GatePolicy::default()).status() == GateFail,
  )
}
