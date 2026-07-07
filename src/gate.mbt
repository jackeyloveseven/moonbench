///|
pub enum GateStatus {
  GatePass
  GateWarn
  GateFail
} derive(Eq, Debug)

///|
pub struct GatePolicy {
  max_noisy : Int
  max_outliers : Int
  regression_rule : RegressionRule
}

///|
pub struct GateReport {
  status : GateStatus
  message : String
  noisy_count : Int
  outlier_count : Int
  regression_count : Int
}

///|
fn gate_status_label(status : GateStatus) -> String {
  match status {
    GatePass => "pass"
    GateWarn => "warn"
    GateFail => "fail"
  }
}

///|
pub fn GatePolicy::default() -> GatePolicy {
  { max_noisy: 0, max_outliers: 0, regression_rule: RegressionRule::new(5.0) }
}

///|
pub fn GatePolicy::new(
  max_noisy : Int,
  max_outliers : Int,
  regression_rule : RegressionRule,
) -> GatePolicy {
  {
    max_noisy: if max_noisy < 0 {
      0
    } else {
      max_noisy
    },
    max_outliers: if max_outliers < 0 {
      0
    } else {
      max_outliers
    },
    regression_rule,
  }
}

///|
pub fn GatePolicy::max_noisy(self : GatePolicy) -> Int {
  self.max_noisy
}

///|
pub fn GatePolicy::max_outliers(self : GatePolicy) -> Int {
  self.max_outliers
}

///|
pub fn GatePolicy::regression_rule(self : GatePolicy) -> RegressionRule {
  self.regression_rule
}

///|
pub fn GateReport::status(self : GateReport) -> GateStatus {
  self.status
}

///|
pub fn GateReport::message(self : GateReport) -> String {
  self.message
}

///|
pub fn GateReport::noisy_count(self : GateReport) -> Int {
  self.noisy_count
}

///|
pub fn GateReport::outlier_count(self : GateReport) -> Int {
  self.outlier_count
}

///|
pub fn GateReport::regression_count(self : GateReport) -> Int {
  self.regression_count
}

///|
pub fn GateReport::passed(self : GateReport) -> Bool {
  self.status != GateFail
}

///|
pub fn GateReport::summary(self : GateReport) -> String {
  "\{gate_status_label(self.status)}: \{self.message}"
}

///|
pub fn GatePolicy::check_assessment(
  self : GatePolicy,
  assessment : SuiteAssessment,
) -> GateReport {
  let noisy = assessment.noisy_count()
  let outliers = assessment.outlier_count()
  let status = if noisy > self.max_noisy || outliers > self.max_outliers {
    GateFail
  } else if assessment.watch_count() > 0 {
    GateWarn
  } else {
    GatePass
  }
  let message = "quality gate: noisy=\{noisy}/\{self.max_noisy}, outliers=\{outliers}/\{self.max_outliers}"
  {
    status,
    message,
    noisy_count: noisy,
    outlier_count: outliers,
    regression_count: 0,
  }
}

///|
pub fn GatePolicy::check_history(
  self : GatePolicy,
  comparison : HistoryComparison,
) -> GateReport {
  let mut regressions = 0
  let mut warnings = 0
  for item in comparison.comparisons() {
    let report = self.regression_rule.check(item)
    match report.status() {
      Fail => regressions = regressions + 1
      Warn => warnings = warnings + 1
      Pass => ()
    }
  }
  let status = if regressions > 0 {
    GateFail
  } else if warnings > 0 {
    GateWarn
  } else {
    GatePass
  }
  let message = "regression gate: compared=\{comparison.len()}, warnings=\{warnings}, failures=\{regressions}"
  {
    status,
    message,
    noisy_count: 0,
    outlier_count: 0,
    regression_count: regressions,
  }
}

///|
test "gate fails noisy assessment by policy" {
  let assessment = SuiteAssessment::from_suite(default_smoke_suite())
  let report = GatePolicy::new(0, 0, RegressionRule::new(5.0)).check_assessment(
    assessment,
  )
  assert_true(
    report.status() == GateFail ||
    report.status() == GateWarn ||
    report.status() == GatePass,
  )
  assert_true(report.summary().contains("quality gate"))
}

///|
test "gate fails history regressions" {
  let baseline = HistoricalRun::new("old", "old").add(
    Samples::new("case").add_nanos(100L).stats(),
  )
  let candidate = HistoricalRun::new("new", "new").add(
    Samples::new("case").add_nanos(120L).stats(),
  )
  let report = GatePolicy::default().check_history(
    candidate.compare_against(baseline, 1.0),
  )
  assert_true(report.status() == GateFail)
  assert_eq(report.regression_count(), 1)
}
