///|
pub enum OutlierClass {
  LowSevere
  LowMild
  Typical
  HighMild
  HighSevere
} derive(Eq, Debug)

///|
pub struct OutlierSummary {
  name : String
  count : Int
  low_severe : Int
  low_mild : Int
  typical : Int
  high_mild : Int
  high_severe : Int
  q1 : Duration
  q3 : Duration
  iqr : Duration
  lower_mild_fence : Duration
  upper_mild_fence : Duration
  lower_severe_fence : Duration
  upper_severe_fence : Duration
}

///|
fn classify_nanos(
  value : Int64,
  lower_mild : Int64,
  upper_mild : Int64,
  lower_severe : Int64,
  upper_severe : Int64,
) -> OutlierClass {
  if value < lower_severe {
    LowSevere
  } else if value < lower_mild {
    LowMild
  } else if value > upper_severe {
    HighSevere
  } else if value > upper_mild {
    HighMild
  } else {
    Typical
  }
}

///|
pub fn Samples::outliers(self : Samples) -> OutlierSummary {
  let q1 = self.percentile(0.25)
  let q3 = self.percentile(0.75)
  let iqr = q3.minus(q1)
  let lower_mild = q1.minus(iqr.scale(1.5))
  let upper_mild = q3.plus(iqr.scale(1.5))
  let lower_severe = q1.minus(iqr.scale(3.0))
  let upper_severe = q3.plus(iqr.scale(3.0))
  let mut low_severe = 0
  let mut low_mild = 0
  let mut typical = 0
  let mut high_mild = 0
  let mut high_severe = 0
  for i = 0; i < self.len(); i = i + 1 {
    let cls = classify_nanos(
      self.get(i).nanos(),
      lower_mild.nanos(),
      upper_mild.nanos(),
      lower_severe.nanos(),
      upper_severe.nanos(),
    )
    match cls {
      LowSevere => low_severe = low_severe + 1
      LowMild => low_mild = low_mild + 1
      Typical => typical = typical + 1
      HighMild => high_mild = high_mild + 1
      HighSevere => high_severe = high_severe + 1
    }
  }
  {
    name: self.name(),
    count: self.len(),
    low_severe,
    low_mild,
    typical,
    high_mild,
    high_severe,
    q1,
    q3,
    iqr,
    lower_mild_fence: lower_mild,
    upper_mild_fence: upper_mild,
    lower_severe_fence: lower_severe,
    upper_severe_fence: upper_severe,
  }
}

///|
pub fn OutlierSummary::name(self : OutlierSummary) -> String {
  self.name
}

///|
pub fn OutlierSummary::count(self : OutlierSummary) -> Int {
  self.count
}

///|
pub fn OutlierSummary::low_severe(self : OutlierSummary) -> Int {
  self.low_severe
}

///|
pub fn OutlierSummary::low_mild(self : OutlierSummary) -> Int {
  self.low_mild
}

///|
pub fn OutlierSummary::typical(self : OutlierSummary) -> Int {
  self.typical
}

///|
pub fn OutlierSummary::high_mild(self : OutlierSummary) -> Int {
  self.high_mild
}

///|
pub fn OutlierSummary::high_severe(self : OutlierSummary) -> Int {
  self.high_severe
}

///|
pub fn OutlierSummary::q1(self : OutlierSummary) -> Duration {
  self.q1
}

///|
pub fn OutlierSummary::q3(self : OutlierSummary) -> Duration {
  self.q3
}

///|
pub fn OutlierSummary::iqr(self : OutlierSummary) -> Duration {
  self.iqr
}

///|
pub fn OutlierSummary::lower_mild_fence(self : OutlierSummary) -> Duration {
  self.lower_mild_fence
}

///|
pub fn OutlierSummary::upper_mild_fence(self : OutlierSummary) -> Duration {
  self.upper_mild_fence
}

///|
pub fn OutlierSummary::lower_severe_fence(self : OutlierSummary) -> Duration {
  self.lower_severe_fence
}

///|
pub fn OutlierSummary::upper_severe_fence(self : OutlierSummary) -> Duration {
  self.upper_severe_fence
}

///|
pub fn OutlierSummary::outlier_count(self : OutlierSummary) -> Int {
  self.low_severe + self.low_mild + self.high_mild + self.high_severe
}

///|
pub fn OutlierSummary::has_outliers(self : OutlierSummary) -> Bool {
  self.outlier_count() > 0
}

///|
pub fn OutlierSummary::summary(self : OutlierSummary) -> String {
  "\{self.name}: typical=\{self.typical}, mild=\{self.low_mild + self.high_mild}, severe=\{self.low_severe + self.high_severe}, fences=[\{self.lower_mild_fence.format()}, \{self.upper_mild_fence.format()}]"
}

///|
test "outlier summary detects high severe values" {
  let summary = Samples::new("case")
    .add_nanos(10L)
    .add_nanos(11L)
    .add_nanos(12L)
    .add_nanos(13L)
    .add_nanos(100L)
    .outliers()
  assert_true(summary.has_outliers())
  assert_true(summary.high_severe() > 0 || summary.high_mild() > 0)
}

///|
test "outlier summary keeps compact stable samples typical" {
  let summary = Samples::new("stable")
    .add_nanos(10L)
    .add_nanos(11L)
    .add_nanos(12L)
    .add_nanos(13L)
    .outliers()
  assert_eq(summary.outlier_count(), 0)
}
