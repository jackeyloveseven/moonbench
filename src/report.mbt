///|
pub enum ReportFormat {
  Markdown
  Csv
  Text
  Json
} derive(Eq, Debug)

///|
pub struct Report {
  title : String
  sections : Array[Stats]
}

///|
pub fn Report::new(title : String) -> Report {
  { title, sections: [] }
}

///|
pub fn Report::add(self : Report, stats : Stats) -> Report {
  let sections = self.sections.copy()
  sections.push(stats)
  { title: self.title, sections }
}

///|
pub fn Report::len(self : Report) -> Int {
  self.sections.length()
}

///|
pub fn Report::render(self : Report) -> String {
  self.render_markdown()
}

///|
pub fn Report::render_as(self : Report, format : ReportFormat) -> String {
  match format {
    Markdown => self.render_markdown()
    Csv => self.render_csv()
    Text => self.render_text()
    Json => self.render_json()
  }
}

///|
pub fn Report::render_markdown(self : Report) -> String {
  let mut out = "# " + self.title + "\n\n"
  out = out +
    "| benchmark | runs | min | mean | median | p95 | max | stddev | mad | rsd |\n"
  out = out +
    "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
  for item in self.sections {
    out = out + "| " + item.name()
    out = out + " | " + item.count().to_string()
    out = out + " | " + item.min().format()
    out = out + " | " + item.mean().format()
    out = out + " | " + item.median().format()
    out = out + " | " + item.p95().format()
    out = out + " | " + item.max().format()
    out = out + " | " + item.stddev().format()
    out = out + " | " + item.mad().format()
    out = out + " | " + item.relative_stddev().to_string()
    out = out + " |\n"
  }
  out
}

///|
pub fn Report::render_csv(self : Report) -> String {
  let mut out = "benchmark,runs,min_nanos,mean_nanos,median_nanos,p90_nanos,p95_nanos,p99_nanos,max_nanos,stddev_nanos,mad_nanos,relative_stddev\n"
  for item in self.sections {
    out = out + item.name()
    out = out + "," + item.count().to_string()
    out = out + "," + item.min().nanos().to_string()
    out = out + "," + item.mean().nanos().to_string()
    out = out + "," + item.median().nanos().to_string()
    out = out + "," + item.p90().nanos().to_string()
    out = out + "," + item.p95().nanos().to_string()
    out = out + "," + item.p99().nanos().to_string()
    out = out + "," + item.max().nanos().to_string()
    out = out + "," + item.stddev().nanos().to_string()
    out = out + "," + item.mad().nanos().to_string()
    out = out + "," + item.relative_stddev().to_string()
    out = out + "\n"
  }
  out
}

///|
pub fn Report::render_text(self : Report) -> String {
  let mut out = self.title + "\n"
  for item in self.sections {
    out = out + "- " + item.to_line() + "\n"
  }
  out
}

///|
pub fn Report::render_json(self : Report) -> String {
  let mut out = "{\n  \"title\": \"" + self.title + "\",\n  \"benchmarks\": [\n"
  for i = 0; i < self.sections.length(); i = i + 1 {
    let item = self.sections[i]
    out = out + "    {"
    out = out + "\"name\": \"" + item.name() + "\""
    out = out + ", \"runs\": " + item.count().to_string()
    out = out + ", \"min_nanos\": " + item.min().nanos().to_string()
    out = out + ", \"mean_nanos\": " + item.mean().nanos().to_string()
    out = out + ", \"median_nanos\": " + item.median().nanos().to_string()
    out = out + ", \"p95_nanos\": " + item.p95().nanos().to_string()
    out = out + ", \"max_nanos\": " + item.max().nanos().to_string()
    out = out + ", \"stddev_nanos\": " + item.stddev().nanos().to_string()
    out = out + "}"
    if i + 1 < self.sections.length() {
      out = out + ","
    }
    out = out + "\n"
  }
  out = out + "  ]\n}"
  out
}

///|
test "report renders markdown table" {
  let stats = Samples::new("case").add_nanos(10L).add_nanos(20L).stats()
  let text = Report::new("Demo").add(stats).render()
  assert_true(text.length() > 20)
}

///|
test "report renders csv text and json formats" {
  let report = Report::new("Demo").add(
    Samples::new("case").add_nanos(10L).add_nanos(20L).stats(),
  )
  assert_true(report.render_as(Markdown).length() > 20)
  assert_true(report.render_as(Csv).length() > 20)
  assert_true(report.render_as(Text).length() > 10)
  assert_true(report.render_as(Json).length() > 30)
}
