///|
pub enum ComparisonKind {
  Faster
  Slower
  Similar
} derive(Eq, Debug)

///|
pub struct Comparison {
  baseline : Stats
  candidate : Stats
  ratio : Double
  change_percent : Double
  kind : ComparisonKind
}

///|
fn double_abs(value : Double) -> Double {
  if value < 0.0 {
    0.0 - value
  } else {
    value
  }
}

///|
pub fn Comparison::new(
  baseline : Stats,
  candidate : Stats,
  noise_threshold : Double,
) -> Comparison {
  let base = baseline.mean().nanos().to_double()
  let next = candidate.mean().nanos().to_double()
  let ratio = if next == 0.0 {
    if base == 0.0 {
      1.0
    } else {
      0.0
    }
  } else {
    base / next
  }
  let change = if base == 0.0 {
    if next == 0.0 {
      0.0
    } else {
      100.0
    }
  } else {
    (next - base) / base * 100.0
  }
  let threshold = if noise_threshold < 0.0 { 0.0 } else { noise_threshold }
  let kind = if double_abs(change) <= threshold {
    Similar
  } else if next < base {
    Faster
  } else {
    Slower
  }
  { baseline, candidate, ratio, change_percent: change, kind }
}

///|
pub fn Comparison::baseline(self : Comparison) -> Stats {
  self.baseline
}

///|
pub fn Comparison::candidate(self : Comparison) -> Stats {
  self.candidate
}

///|
pub fn Comparison::ratio(self : Comparison) -> Double {
  self.ratio
}

///|
pub fn Comparison::change_percent(self : Comparison) -> Double {
  self.change_percent
}

///|
pub fn Comparison::kind(self : Comparison) -> ComparisonKind {
  self.kind
}

///|
pub fn Comparison::is_regression(self : Comparison) -> Bool {
  self.kind == Slower
}

///|
pub fn Comparison::summary(self : Comparison) -> String {
  match self.kind {
    Faster =>
      "\{self.candidate.name()} is faster than \{self.baseline.name()} by \{0.0 - self.change_percent}%"
    Slower =>
      "\{self.candidate.name()} is slower than \{self.baseline.name()} by \{self.change_percent}%"
    Similar => "\{self.candidate.name()} is similar to \{self.baseline.name()}"
  }
}

///|
test "comparison classifies faster candidate" {
  let base = Samples::new("base").add_nanos(100L).add_nanos(100L).stats()
  let next = Samples::new("next").add_nanos(80L).add_nanos(80L).stats()
  let cmp = Comparison::new(base, next, 1.0)
  assert_true(cmp.kind() == Faster)
}

///|
test "comparison treats threshold boundary as similar" {
  let base = Samples::new("base").add_nanos(100L).stats()
  let next = Samples::new("next").add_nanos(102L).stats()
  let cmp = Comparison::new(base, next, 2.0)
  assert_true(cmp.kind() == Similar)
}
