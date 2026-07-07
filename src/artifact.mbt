///|
pub struct BenchmarkArtifact {
  run_id : String
  label : String
  suite : SuiteResult
  assessment : SuiteAssessment
  gate : GateReport
}

///|
pub fn BenchmarkArtifact::new(
  run_id : String,
  label : String,
  suite : SuiteResult,
  gate : GateReport,
) -> BenchmarkArtifact {
  { run_id, label, suite, assessment: SuiteAssessment::from_suite(suite), gate }
}

///|
pub fn BenchmarkArtifact::from_suite(
  run_id : String,
  label : String,
  suite : SuiteResult,
) -> BenchmarkArtifact {
  let assessment = SuiteAssessment::from_suite(suite)
  let gate = GatePolicy::default().check_assessment(assessment)
  { run_id, label, suite, assessment, gate }
}

///|
pub fn BenchmarkArtifact::run_id(self : BenchmarkArtifact) -> String {
  self.run_id
}

///|
pub fn BenchmarkArtifact::label(self : BenchmarkArtifact) -> String {
  self.label
}

///|
pub fn BenchmarkArtifact::suite(self : BenchmarkArtifact) -> SuiteResult {
  self.suite
}

///|
pub fn BenchmarkArtifact::assessment(
  self : BenchmarkArtifact,
) -> SuiteAssessment {
  self.assessment
}

///|
pub fn BenchmarkArtifact::gate(self : BenchmarkArtifact) -> GateReport {
  self.gate
}

///|
pub fn BenchmarkArtifact::historical_run(
  self : BenchmarkArtifact,
) -> HistoricalRun {
  HistoricalRun::from_suite(self.run_id, self.label, self.suite)
}

///|
pub fn BenchmarkArtifact::manifest(self : BenchmarkArtifact) -> String {
  "MoonBench artifact run=\{self.run_id}, label=\{self.label}, suite=\{self.suite.name()}, gate=\{self.gate.summary()}"
}

///|
pub fn BenchmarkArtifact::render_markdown(self : BenchmarkArtifact) -> String {
  let mut out = "# MoonBench artifact: " + self.label + "\n\n"
  out = out + "- run_id: `" + self.run_id + "`\n"
  out = out + "- suite: `" + self.suite.name() + "`\n"
  out = out + "- gate: `" + self.gate.summary() + "`\n\n"
  out = out + self.suite.to_report().render_markdown() + "\n"
  out = out + self.assessment.render_markdown() + "\n"
  out = out + "## Supported benchmark models\n\n"
  out + benchmark_model_catalog_markdown()
}

///|
pub fn BenchmarkArtifact::render_json(self : BenchmarkArtifact) -> String {
  "{\n" +
  "  \"run_id\": \"" +
  self.run_id +
  "\",\n" +
  "  \"label\": \"" +
  self.label +
  "\",\n" +
  "  \"gate\": \"" +
  self.gate.summary().replace_all(old="\"", new="\\\"") +
  "\",\n" +
  "  \"suite\": " +
  self.suite.render_web_json() +
  "\n" +
  "}"
}

///|
pub fn BenchmarkArtifact::render_csv(self : BenchmarkArtifact) -> String {
  self.suite.to_report().render_csv()
}

///|
test "artifact renders markdown json and csv" {
  let artifact = BenchmarkArtifact::from_suite(
    "run-1",
    "demo",
    default_smoke_suite(),
  )
  assert_true(artifact.manifest().contains("run=run-1"))
  assert_true(artifact.render_markdown().contains("Supported benchmark models"))
  assert_true(artifact.render_json().contains("\"suite\""))
  assert_true(artifact.render_csv().contains("benchmark,runs"))
}
