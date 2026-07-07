///|
pub struct Parameter {
  name : String
  value : String
}

///|
pub struct ParameterSet {
  parameters : Array[Parameter]
}

///|
pub struct ParameterSweep {
  name : String
  values : Array[String]
}

///|
pub fn Parameter::new(name : String, value : String) -> Parameter {
  { name, value }
}

///|
pub fn Parameter::name(self : Parameter) -> String {
  self.name
}

///|
pub fn Parameter::value(self : Parameter) -> String {
  self.value
}

///|
pub fn Parameter::label(self : Parameter) -> String {
  self.name + "=" + self.value
}

///|
pub fn ParameterSet::new() -> ParameterSet {
  { parameters: [] }
}

///|
pub fn ParameterSet::add(
  self : ParameterSet,
  parameter : Parameter,
) -> ParameterSet {
  let parameters = self.parameters.copy()
  parameters.push(parameter)
  { parameters, }
}

///|
pub fn ParameterSet::len(self : ParameterSet) -> Int {
  self.parameters.length()
}

///|
pub fn ParameterSet::get(self : ParameterSet, index : Int) -> Parameter {
  self.parameters[index]
}

///|
pub fn ParameterSet::parameters(self : ParameterSet) -> Array[Parameter] {
  self.parameters.copy()
}

///|
pub fn ParameterSet::label(self : ParameterSet) -> String {
  if self.parameters.length() == 0 {
    "default"
  } else {
    let mut out = ""
    for i = 0; i < self.parameters.length(); i = i + 1 {
      if i > 0 {
        out = out + ","
      }
      out = out + self.parameters[i].label()
    }
    out
  }
}

///|
pub fn ParameterSweep::new(name : String) -> ParameterSweep {
  { name, values: [] }
}

///|
pub fn ParameterSweep::add_value(
  self : ParameterSweep,
  value : String,
) -> ParameterSweep {
  let values = self.values.copy()
  values.push(value)
  { name: self.name, values }
}

///|
pub fn ParameterSweep::name(self : ParameterSweep) -> String {
  self.name
}

///|
pub fn ParameterSweep::len(self : ParameterSweep) -> Int {
  self.values.length()
}

///|
pub fn ParameterSweep::get(self : ParameterSweep, index : Int) -> ParameterSet {
  ParameterSet::new().add(Parameter::new(self.name, self.values[index]))
}

///|
pub fn ParameterSweep::labels(self : ParameterSweep) -> Array[String] {
  let labels : Array[String] = []
  for i = 0; i < self.values.length(); i = i + 1 {
    labels.push(self.get(i).label())
  }
  labels
}

///|
pub fn BenchmarkCase::with_parameters(
  self : BenchmarkCase,
  parameters : ParameterSet,
) -> BenchmarkCase {
  let label = if parameters.len() == 0 {
    self.name()
  } else {
    self.name() + "[" + parameters.label() + "]"
  }
  BenchmarkCase::new(label).with_config(self.config())
}

///|
test "parameter sets render stable labels" {
  let params = ParameterSet::new()
    .add(Parameter::new("threads", "4"))
    .add(Parameter::new("mode", "fast"))
  assert_eq(params.label(), "threads=4,mode=fast")
}

///|
test "parameter sweep expands labels" {
  let sweep = ParameterSweep::new("threads")
    .add_value("1")
    .add_value("2")
    .add_value("4")
  let labels = sweep.labels()
  assert_eq(labels.length(), 3)
  assert_eq(labels[2], "threads=4")
}
