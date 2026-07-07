///|
pub enum RegressionStatus {
  Pass
  Warn
  Fail
} derive(Eq, Debug)

///|
pub struct RegressionRule {
  warning_slowdown_percent : Double
  max_slowdown_percent : Double
}

///|
pub struct RegressionReport {
  status : RegressionStatus
  comparison : Comparison
  rule : RegressionRule
  message : String
}

///|
pub fn RegressionRule::new(max_slowdown_percent : Double) -> RegressionRule {
  let max = if max_slowdown_percent < 0.0 { 0.0 } else { max_slowdown_percent }
  { warning_slowdown_percent: max / 2.0, max_slowdown_percent: max }
}

///|
pub fn RegressionRule::with_warning(
  self : RegressionRule,
  warning_slowdown_percent : Double,
) -> RegressionRule {
  let warning = if warning_slowdown_percent < 0.0 {
    0.0
  } else {
    warning_slowdown_percent
  }
  {
    warning_slowdown_percent: warning,
    max_slowdown_percent: self.max_slowdown_percent,
  }
}

///|
pub fn RegressionRule::warning_slowdown_percent(
  self : RegressionRule,
) -> Double {
  self.warning_slowdown_percent
}

///|
pub fn RegressionRule::max_slowdown_percent(self : RegressionRule) -> Double {
  self.max_slowdown_percent
}

///|
pub fn RegressionRule::check(
  self : RegressionRule,
  comparison : Comparison,
) -> RegressionReport {
  let slowdown = comparison.change_percent()
  let status = if comparison.kind() != Slower {
    Pass
  } else if slowdown > self.max_slowdown_percent {
    Fail
  } else if slowdown > self.warning_slowdown_percent {
    Warn
  } else {
    Pass
  }
  let label = match status {
    Pass => "pass"
    Warn => "warn"
    Fail => "fail"
  }
  let message = "\{label}: \{comparison.summary()} (warn > \{self.warning_slowdown_percent}%, fail > \{self.max_slowdown_percent}%)"
  { status, comparison, rule: self, message }
}

///|
pub fn RegressionReport::status(self : RegressionReport) -> RegressionStatus {
  self.status
}

///|
pub fn RegressionReport::comparison(self : RegressionReport) -> Comparison {
  self.comparison
}

///|
pub fn RegressionReport::rule(self : RegressionReport) -> RegressionRule {
  self.rule
}

///|
pub fn RegressionReport::message(self : RegressionReport) -> String {
  self.message
}

///|
pub fn RegressionReport::passed(self : RegressionReport) -> Bool {
  self.status != Fail
}

///|
test "regression rule passes faster result" {
  let base = Samples::new("base").add_nanos(100L).stats()
  let next = Samples::new("next").add_nanos(80L).stats()
  let report = RegressionRule::new(5.0).check(Comparison::new(base, next, 1.0))
  assert_true(report.status() == Pass)
}

///|
test "regression rule warns and fails slower result" {
  let base = Samples::new("base").add_nanos(100L).stats()
  let warn = Samples::new("warn").add_nanos(104L).stats()
  let fail = Samples::new("fail").add_nanos(110L).stats()
  let rule = RegressionRule::new(5.0)
  assert_true(rule.check(Comparison::new(base, warn, 1.0)).status() == Warn)
  assert_true(rule.check(Comparison::new(base, fail, 1.0)).status() == Fail)
}
