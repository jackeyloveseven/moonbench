///|
pub enum StopwatchState {
  Ready
  Running
  Paused
  Stopped
} derive(Eq, Debug)

///|
pub struct Stopwatch {
  state : StopwatchState
  started_at : Int64
  last_tick : Int64
  elapsed : Duration
}

///|
pub fn Stopwatch::new() -> Stopwatch {
  { state: Ready, started_at: 0L, last_tick: 0L, elapsed: Duration::zero() }
}

///|
pub fn Stopwatch::start(now_nanos : Int64) -> Stopwatch {
  {
    state: Running,
    started_at: now_nanos,
    last_tick: now_nanos,
    elapsed: Duration::zero(),
  }
}

///|
pub fn Stopwatch::state(self : Stopwatch) -> StopwatchState {
  self.state
}

///|
pub fn Stopwatch::elapsed(self : Stopwatch) -> Duration {
  self.elapsed
}

///|
pub fn Stopwatch::tick(self : Stopwatch, now_nanos : Int64) -> Stopwatch {
  match self.state {
    Running => {
      let delta = Duration::from_nanos(now_nanos - self.last_tick)
      {
        state: Running,
        started_at: self.started_at,
        last_tick: now_nanos,
        elapsed: self.elapsed.plus(delta),
      }
    }
    _ => self
  }
}

///|
pub fn Stopwatch::pause(self : Stopwatch, now_nanos : Int64) -> Stopwatch {
  match self.state {
    Running => {
      let next = self.tick(now_nanos)
      {
        state: Paused,
        started_at: next.started_at,
        last_tick: now_nanos,
        elapsed: next.elapsed,
      }
    }
    _ => self
  }
}

///|
pub fn Stopwatch::resume_at(self : Stopwatch, now_nanos : Int64) -> Stopwatch {
  match self.state {
    Paused =>
      {
        state: Running,
        started_at: self.started_at,
        last_tick: now_nanos,
        elapsed: self.elapsed,
      }
    _ => self
  }
}

///|
pub fn Stopwatch::stop(self : Stopwatch, now_nanos : Int64) -> Stopwatch {
  match self.state {
    Running => {
      let next = self.tick(now_nanos)
      {
        state: Stopped,
        started_at: next.started_at,
        last_tick: now_nanos,
        elapsed: next.elapsed,
      }
    }
    Paused =>
      {
        state: Stopped,
        started_at: self.started_at,
        last_tick: now_nanos,
        elapsed: self.elapsed,
      }
    _ => self
  }
}

///|
test "stopwatch is deterministic" {
  let sw = Stopwatch::start(10L).tick(20L).pause(30L).resume_at(100L).stop(150L)
  assert_eq(sw.elapsed().nanos(), 70L)
}
