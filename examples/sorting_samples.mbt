///|
pub fn sorting_samples() -> @bench.SuiteResult {
  let config = @bench.BenchmarkConfig::default()
    .with_measure_runs(6)
    .with_noise_threshold(3.0)

  let insertion_sort = @bench.Samples::new("insertion-sort")
    .add(@bench.Duration::from_micros(410L))
    .add(@bench.Duration::from_micros(405L))
    .add(@bench.Duration::from_micros(430L))
    .add(@bench.Duration::from_micros(416L))
    .add(@bench.Duration::from_micros(421L))
    .add(@bench.Duration::from_micros(409L))

  let builtin_sort = @bench.Samples::new("builtin-sort")
    .add(@bench.Duration::from_micros(180L))
    .add(@bench.Duration::from_micros(176L))
    .add(@bench.Duration::from_micros(190L))
    .add(@bench.Duration::from_micros(183L))
    .add(@bench.Duration::from_micros(181L))
    .add(@bench.Duration::from_micros(178L))

  @bench.BenchmarkSuite::new("sorting comparison")
  .with_config(config)
  .add_samples(insertion_sort)
  .add_samples(builtin_sort)
  .finish()
}
