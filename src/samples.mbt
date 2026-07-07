///|
pub struct Samples {
  name : String
  values : Array[Duration]
}

///|
pub fn Samples::new(name : String) -> Samples {
  { name, values: [] }
}

///|
pub fn Samples::name(self : Samples) -> String {
  self.name
}

///|
pub fn Samples::len(self : Samples) -> Int {
  self.values.length()
}

///|
pub fn Samples::is_empty(self : Samples) -> Bool {
  self.values.length() == 0
}

///|
pub fn Samples::add(self : Samples, value : Duration) -> Samples {
  let values = self.values.copy()
  values.push(value)
  { name: self.name, values }
}

///|
pub fn Samples::add_nanos(self : Samples, nanos : Int64) -> Samples {
  self.add(Duration::from_nanos(nanos))
}

///|
pub fn Samples::get(self : Samples, index : Int) -> Duration {
  self.values[index]
}

///|
pub fn Samples::values(self : Samples) -> Array[Duration] {
  self.values.copy()
}

///|
pub fn Samples::stats(self : Samples) -> Stats {
  Stats::from_samples(self)
}

///|
test "samples collect durations" {
  let samples = Samples::new("tiny").add_nanos(10L).add_nanos(12L)
  assert_eq(samples.len(), 2)
  assert_eq(samples.get(1).nanos(), 12L)
}
