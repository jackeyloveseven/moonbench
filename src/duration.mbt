///|
pub enum DurationUnit {
  Nanoseconds
  Microseconds
  Milliseconds
  Seconds
} derive(Eq, Debug)

///|
pub struct Duration {
  nanos : Int64
}

///|
pub fn Duration::zero() -> Duration {
  { nanos: 0L }
}

///|
pub fn Duration::from_nanos(nanos : Int64) -> Duration {
  { nanos, }
}

///|
pub fn Duration::from_micros(micros : Int64) -> Duration {
  { nanos: micros * 1000L }
}

///|
pub fn Duration::from_millis(millis : Int64) -> Duration {
  { nanos: millis * 1000L * 1000L }
}

///|
pub fn Duration::from_secs(secs : Int64) -> Duration {
  { nanos: secs * 1000L * 1000L * 1000L }
}

///|
pub fn Duration::nanos(self : Duration) -> Int64 {
  self.nanos
}

///|
pub fn Duration::micros(self : Duration) -> Double {
  self.nanos.to_double() / 1000.0
}

///|
pub fn Duration::millis(self : Duration) -> Double {
  self.nanos.to_double() / 1000000.0
}

///|
pub fn Duration::secs(self : Duration) -> Double {
  self.nanos.to_double() / 1000000000.0
}

///|
pub fn Duration::plus(self : Duration, other : Duration) -> Duration {
  { nanos: self.nanos + other.nanos }
}

///|
pub fn Duration::minus(self : Duration, other : Duration) -> Duration {
  { nanos: self.nanos - other.nanos }
}

///|
pub fn Duration::abs_diff(self : Duration, other : Duration) -> Duration {
  if self.nanos >= other.nanos {
    { nanos: self.nanos - other.nanos }
  } else {
    { nanos: other.nanos - self.nanos }
  }
}

///|
pub fn Duration::scale(self : Duration, factor : Double) -> Duration {
  { nanos: (self.nanos.to_double() * factor).to_int64() }
}

///|
pub fn Duration::divide_by(self : Duration, divisor : Int) -> Duration {
  if divisor <= 1 {
    self
  } else {
    { nanos: self.nanos / divisor.to_int64() }
  }
}

///|
pub fn Duration::is_zero(self : Duration) -> Bool {
  self.nanos == 0L
}

///|
pub fn Duration::format_as(self : Duration, unit : DurationUnit) -> String {
  match unit {
    Nanoseconds => "\{self.nanos}ns"
    Microseconds => "\{self.micros()}us"
    Milliseconds => "\{self.millis()}ms"
    Seconds => "\{self.secs()}s"
  }
}

///|
pub fn Duration::format(self : Duration) -> String {
  if self.nanos < 1000L {
    self.format_as(Nanoseconds)
  } else if self.nanos < 1000L * 1000L {
    self.format_as(Microseconds)
  } else if self.nanos < 1000L * 1000L * 1000L {
    self.format_as(Milliseconds)
  } else {
    self.format_as(Seconds)
  }
}

///|
test "duration conversions" {
  let d = Duration::from_millis(2L)
  assert_eq(d.nanos(), 2000000L)
  assert_eq(Duration::from_micros(3L).nanos(), 3000L)
}

///|
test "duration explicit formatting units" {
  let d = Duration::from_micros(1500L)
  assert_eq(d.format_as(Nanoseconds), "1500000ns")
  assert_eq(d.format_as(Milliseconds), "1.5ms")
}

///|
test "duration can be divided by positive batch size" {
  assert_eq(Duration::from_nanos(40L).divide_by(4).nanos(), 10L)
  assert_eq(Duration::from_nanos(40L).divide_by(0).nanos(), 40L)
}
