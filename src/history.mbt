///|
pub struct HistoricalRun {
  id : String
  label : String
  results : Array[Stats]
}

///|
pub struct HistoryComparison {
  baseline_id : String
  candidate_id : String
  comparisons : Array[Comparison]
}

///|
pub fn HistoricalRun::new(id : String, label : String) -> HistoricalRun {
  { id, label, results: [] }
}

///|
pub fn HistoricalRun::from_suite(
  id : String,
  label : String,
  suite : SuiteResult,
) -> HistoricalRun {
  { id, label, results: suite.stats() }
}

///|
pub fn HistoricalRun::id(self : HistoricalRun) -> String {
  self.id
}

///|
pub fn HistoricalRun::label(self : HistoricalRun) -> String {
  self.label
}

///|
pub fn HistoricalRun::len(self : HistoricalRun) -> Int {
  self.results.length()
}

///|
pub fn HistoricalRun::get(self : HistoricalRun, index : Int) -> Stats {
  self.results[index]
}

///|
pub fn HistoricalRun::results(self : HistoricalRun) -> Array[Stats] {
  self.results.copy()
}

///|
pub fn HistoricalRun::add(self : HistoricalRun, stats : Stats) -> HistoricalRun {
  let results = self.results.copy()
  results.push(stats)
  { id: self.id, label: self.label, results }
}

///|
pub fn HistoricalRun::find_index(self : HistoricalRun, name : String) -> Int {
  let mut found = -1
  for i = 0; i < self.results.length(); i = i + 1 {
    if self.results[i].name() == name && found < 0 {
      found = i
    }
  }
  found
}

///|
pub fn HistoricalRun::compare_against(
  self : HistoricalRun,
  baseline : HistoricalRun,
  noise_threshold : Double,
) -> HistoryComparison {
  let comparisons : Array[Comparison] = []
  for candidate in self.results {
    let idx = baseline.find_index(candidate.name())
    if idx >= 0 {
      comparisons.push(
        Comparison::new(baseline.get(idx), candidate, noise_threshold),
      )
    }
  }
  { baseline_id: baseline.id, candidate_id: self.id, comparisons }
}

///|
pub fn HistoryComparison::baseline_id(self : HistoryComparison) -> String {
  self.baseline_id
}

///|
pub fn HistoryComparison::candidate_id(self : HistoryComparison) -> String {
  self.candidate_id
}

///|
pub fn HistoryComparison::len(self : HistoryComparison) -> Int {
  self.comparisons.length()
}

///|
pub fn HistoryComparison::get(
  self : HistoryComparison,
  index : Int,
) -> Comparison {
  self.comparisons[index]
}

///|
pub fn HistoryComparison::comparisons(
  self : HistoryComparison,
) -> Array[Comparison] {
  self.comparisons.copy()
}

///|
pub fn HistoryComparison::regression_count(self : HistoryComparison) -> Int {
  let mut count = 0
  for item in self.comparisons {
    if item.is_regression() {
      count = count + 1
    }
  }
  count
}

///|
pub fn HistoryComparison::summary(self : HistoryComparison) -> String {
  "history \{self.baseline_id} -> \{self.candidate_id}: compared=\{self.comparisons.length()}, regressions=\{self.regression_count()}"
}

///|
test "historical runs compare matching benchmarks" {
  let baseline = HistoricalRun::new("old", "baseline")
    .add(Samples::new("case").add_nanos(100L).stats())
    .add(Samples::new("other").add_nanos(50L).stats())
  let candidate = HistoricalRun::new("new", "candidate").add(
    Samples::new("case").add_nanos(80L).stats(),
  )
  let comparison = candidate.compare_against(baseline, 1.0)
  assert_eq(comparison.len(), 1)
  assert_true(comparison.get(0).kind() == Faster)
}

///|
test "history comparison counts regressions" {
  let baseline = HistoricalRun::new("old", "baseline").add(
    Samples::new("case").add_nanos(100L).stats(),
  )
  let candidate = HistoricalRun::new("new", "candidate").add(
    Samples::new("case").add_nanos(120L).stats(),
  )
  let comparison = candidate.compare_against(baseline, 1.0)
  assert_eq(comparison.regression_count(), 1)
}
