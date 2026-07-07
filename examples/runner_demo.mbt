///|
fn tiny_workload() -> Unit {
  let mut total = 0
  for i = 0; i < 32; i = i + 1 {
    total = total + i
  }
  ignore(total)
}

///|
pub fn runner_demo_suite() -> @bench.SuiteResult {
  let config = @bench.BenchmarkConfig::default()
    .with_warmup_runs(1)
    .with_measure_runs(3)

  @bench.BenchmarkRunner::new("runner demo")
  .with_config(config)
  .add_task(
    @bench.BenchmarkTask::new("tiny-workload", tiny_workload).with_batch_size(
      16,
    ),
  )
  .run_with_backend(
    @bench.MeasurementBackend::scripted([
      @bench.Duration::from_nanos(160L),
      @bench.Duration::from_nanos(176L),
      @bench.Duration::from_nanos(144L),
    ]),
  )
}

///|
test "runner demo produces normalized samples" {
  let suite = runner_demo_suite()
  assert_eq(suite.len(), 1)
  assert_eq(suite.get(0).stats().mean().nanos(), 10L)
}
