///|
fn main {
  let config = @bench.BenchmarkConfig::default()
    .with_warmup_runs(2)
    .with_measure_runs(4)
    .with_noise_threshold(2.0)
    .with_trim_extremes(false)

  let baseline = @bench.Samples::new("baseline")
    .add(@bench.Duration::from_micros(120L))
    .add(@bench.Duration::from_micros(118L))
    .add(@bench.Duration::from_micros(125L))
    .add(@bench.Duration::from_micros(121L))

  let candidate = @bench.Samples::new("candidate")
    .add(@bench.Duration::from_micros(92L))
    .add(@bench.Duration::from_micros(90L))
    .add(@bench.Duration::from_micros(95L))
    .add(@bench.Duration::from_micros(91L))

  let suite = @bench.BenchmarkSuite::new("MoonBench demo")
    .with_config(config)
    .add_samples(baseline)
    .add_samples(candidate)
    .finish()

  let report = suite.to_report()
  let base_stats = suite.get(0).stats()
  let next_stats = suite.get(1).stats()
  let comparison = @bench.Comparison::new(
    base_stats,
    next_stats,
    config.noise_threshold(),
  )
  let regression = @bench.RegressionRule::new(5.0).check(comparison)
  let throughput = next_stats.throughput(1000L, 64000L)
  let outliers = suite.get(1).samples().outliers()
  let history_baseline = @bench.HistoricalRun::new("run-001", "baseline").add(
    @bench.Samples::new("sort-1k").add_nanos(121000L).stats(),
  )
  let history = @bench.HistoricalRun::new("run-002", "candidate")
    .add(@bench.Samples::new("sort-1k").add_nanos(92000L).stats())
    .compare_against(history_baseline, 2.0)
  let sweep = @bench.ParameterSweep::new("size")
    .add_value("small")
    .add_value("medium")
    .add_value("large")
  let runner_suite = @bench.BenchmarkRunner::new("registered workload demo")
    .with_config(
      @bench.BenchmarkConfig::default().with_warmup_runs(1).with_measure_runs(3),
    )
    .add_task(
      @bench.BenchmarkTask::new("registered/noop-batch", fn() { () }).with_batch_size(
        8,
      ),
    )
    .run_with_backend(
      @bench.MeasurementBackend::scripted([
        @bench.Duration::from_nanos(80L),
        @bench.Duration::from_nanos(88L),
        @bench.Duration::from_nanos(72L),
      ]),
    )
  let workflow_result = @bench.BenchmarkWorkflow::new(
      "cli-run-001",
      "cli workflow",
      @bench.BenchmarkRunner::new("cli workflow suite")
      .with_config(
        @bench.BenchmarkConfig::default()
        .with_warmup_runs(1)
        .with_measure_runs(2),
      )
      .add_task(
        @bench.BenchmarkTask::new("array/sort/int-10k", fn() { () }).with_batch_size(
          4,
        ),
      ),
    )
    .with_backend(
      @bench.MeasurementBackend::scripted([
        @bench.Duration::from_nanos(40L),
        @bench.Duration::from_nanos(48L),
      ]),
    )
    .run()

  println(report.render_markdown())
  println(comparison.summary())
  println(regression.message())
  println("outliers: " + outliers.summary())
  println("metrics: " + throughput.to_metrics().render())
  println(history.summary())
  println(
    "parameter labels: " +
    sweep.labels()[0] +
    ", " +
    sweep.labels()[1] +
    ", " +
    sweep.labels()[2],
  )
  println("runner: " + runner_suite.get(0).to_line())
  println("workflow: " + workflow_result.summary())
  println("\nCSV export:\n" + report.render_csv())
}
