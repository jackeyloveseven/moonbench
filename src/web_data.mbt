///|
fn json_escape(value : String) -> String {
  value
  .replace_all(old="\\", new="\\\\")
  .replace_all(old="\"", new="\\\"")
  .replace_all(old="\n", new="\\n")
  .replace_all(old="\r", new="\\r")
  .replace_all(old="\t", new="\\t")
}

///|
fn json_string(value : String) -> String {
  "\"" + json_escape(value) + "\""
}

///|
fn json_duration_fields(prefix : String, value : Duration) -> String {
  "\"" +
  prefix +
  "_nanos\": " +
  value.nanos().to_string() +
  ", \"" +
  prefix +
  "\": " +
  json_string(value.format())
}

///|
fn stats_web_json(stats : Stats) -> String {
  "{ " +
  "\"name\": " +
  json_string(stats.name()) +
  ", \"runs\": " +
  stats.count().to_string() +
  ", " +
  json_duration_fields("min", stats.min()) +
  ", " +
  json_duration_fields("mean", stats.mean()) +
  ", " +
  json_duration_fields("median", stats.median()) +
  ", " +
  json_duration_fields("p90", stats.p90()) +
  ", " +
  json_duration_fields("p95", stats.p95()) +
  ", " +
  json_duration_fields("p99", stats.p99()) +
  ", " +
  json_duration_fields("max", stats.max()) +
  ", " +
  json_duration_fields("stddev", stats.stddev()) +
  ", " +
  json_duration_fields("mad", stats.mad()) +
  ", \"variance_nanos\": " +
  stats.variance_nanos().to_string() +
  ", \"relative_stddev\": " +
  stats.relative_stddev().to_string() +
  " }"
}

///|
fn raw_samples_json(samples : Samples) -> String {
  let mut out = "["
  for i = 0; i < samples.len(); i = i + 1 {
    out = out + samples.get(i).nanos().to_string()
    if i + 1 < samples.len() {
      out = out + ", "
    }
  }
  out + "]"
}

///|
fn model_web_json(name : String) -> String {
  let model = benchmark_model_for_name(name)
  "{ " +
  "\"id\": " +
  json_string(model.id()) +
  ", \"title\": " +
  json_string(model.title()) +
  ", \"description\": " +
  json_string(model.description()) +
  ", \"default_case\": " +
  json_string(model.default_case()) +
  " }"
}

///|
fn result_web_json(result : BenchmarkResult) -> String {
  let outliers = result.samples().outliers()
  "{ " +
  "\"name\": " +
  json_string(result.name()) +
  ", \"model\": " +
  model_web_json(result.name()) +
  ", \"stats\": " +
  stats_web_json(result.stats()) +
  ", \"samples_nanos\": " +
  raw_samples_json(result.samples()) +
  ", \"outliers\": { " +
  "\"low_mild\": " +
  outliers.low_mild().to_string() +
  ", \"high_mild\": " +
  outliers.high_mild().to_string() +
  ", \"low_severe\": " +
  outliers.low_severe().to_string() +
  ", \"high_severe\": " +
  outliers.high_severe().to_string() +
  ", \"total\": " +
  outliers.outlier_count().to_string() +
  ", \"summary\": " +
  json_string(outliers.summary()) +
  " }" +
  " }"
}

///|
pub fn SuiteResult::render_web_json(self : SuiteResult) -> String {
  let mut out = "{\n"
  out = out + "  \"schema_version\": 1,\n"
  out = out + "  \"tool\": \"MoonBench\",\n"
  out = out + "  \"suite\": " + json_string(self.name()) + ",\n"
  out = out + "  \"config\": {\n"
  out = out +
    "    \"warmup_runs\": " +
    self.config().warmup_runs().to_string() +
    ",\n"
  out = out +
    "    \"measure_runs\": " +
    self.config().measure_runs().to_string() +
    ",\n"
  out = out +
    "    \"noise_threshold\": " +
    self.config().noise_threshold().to_string() +
    ",\n"
  out = out +
    "    \"trim_extremes\": " +
    self.config().trim_extremes().to_string() +
    "\n"
  out = out + "  },\n"
  out = out + "  \"benchmarks\": [\n"
  let results = self.results()
  for i = 0; i < results.length(); i = i + 1 {
    out = out + "    " + result_web_json(results[i])
    if i + 1 < results.length() {
      out = out + ","
    }
    out = out + "\n"
  }
  out = out + "  ]\n"
  out + "}"
}

///|
pub fn Report::render_web_json(self : Report) -> String {
  let mut out = "{\n"
  out = out + "  \"schema_version\": 1,\n"
  out = out + "  \"tool\": \"MoonBench\",\n"
  out = out + "  \"suite\": " + json_string(self.title) + ",\n"
  out = out + "  \"benchmarks\": [\n"
  for i = 0; i < self.sections.length(); i = i + 1 {
    out = out + "    { \"name\": " + json_string(self.sections[i].name())
    out = out + ", \"model\": " + model_web_json(self.sections[i].name())
    out = out + ", \"stats\": " + stats_web_json(self.sections[i])
    out = out + ", \"samples_nanos\": []"
    out = out +
      ", \"outliers\": { \"total\": 0, \"summary\": \"not available from aggregate report\" } }"
    if i + 1 < self.sections.length() {
      out = out + ","
    }
    out = out + "\n"
  }
  out = out + "  ]\n"
  out + "}"
}

///|
test "suite renders stable web json" {
  let suite = BenchmarkSuite::new("web")
    .add_samples(Samples::new("case").add_nanos(10L).add_nanos(20L))
    .finish()
  let text = suite.render_web_json()
  assert_true(text.length() > 200)
  assert_true(text.contains("\"schema_version\""))
  assert_true(text.contains("\"samples_nanos\""))
  assert_true(text.contains("\"model\""))
}

///|
test "web json escapes string fields" {
  let suite = BenchmarkSuite::new("a\"b")
    .add_samples(Samples::new("x<y").add_nanos(10L))
    .finish()
  let text = suite.render_web_json()
  assert_true(text.contains("a\\\"b"))
  assert_true(text.contains("x<y"))
}
