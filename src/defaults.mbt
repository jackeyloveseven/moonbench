///|
fn add_eight_samples(
  name : String,
  a : Int64,
  b : Int64,
  c : Int64,
  d : Int64,
  e : Int64,
  f : Int64,
  g : Int64,
  h : Int64,
) -> Samples {
  Samples::new(name)
  .add_nanos(a)
  .add_nanos(b)
  .add_nanos(c)
  .add_nanos(d)
  .add_nanos(e)
  .add_nanos(f)
  .add_nanos(g)
  .add_nanos(h)
}

///|
pub fn default_benchmark_targets() -> Array[String] {
  let targets : Array[String] = []
  for model in default_benchmark_models() {
    targets.push(model.default_case())
  }
  targets
}

///|
pub fn default_smoke_suite() -> SuiteResult {
  let config = BenchmarkConfig::default()
    .with_warmup_runs(3)
    .with_measure_runs(8)
    .with_noise_threshold(2.0)

  BenchmarkSuite::new("MoonBench default smoke suite")
  .with_config(config)
  .add_samples(
    add_eight_samples(
      "array/sort/int-10k", 3000000L, 3100000L, 3020000L, 2990000L, 3060000L, 3010000L,
      3040000L, 3005000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "string/scan/ascii-64k", 442000L, 436000L, 449000L, 441000L, 438000L, 444000L,
      452000L, 439000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "collection/map-lookup/50k", 1880000L, 1915000L, 1850000L, 1872000L, 1894000L,
      1865000L, 1930000L, 1888000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "parser/json-like/32k", 810000L, 798000L, 826000L, 818000L, 805000L, 812000L,
      1220000L, 809000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "codec/csv-encode/10k", 1280000L, 1265000L, 1302000L, 1274000L, 1289000L, 1268000L,
      1310000L, 1279000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "graph/bfs/grid-128", 5420000L, 5350000L, 5510000L, 5390000L, 5440000L, 5370000L,
      5480000L, 5410000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "numeric/arithmetic-loop/1m", 720000L, 708000L, 715000L, 726000L, 711000L,
      718000L, 722000L, 713000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "hashing/bytes-64k", 980000L, 995000L, 972000L, 988000L, 1002000L, 979000L,
      991000L, 984000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "memory/alloc-small/10k", 2350000L, 2410000L, 2380000L, 2365000L, 2440000L,
      2375000L, 2395000L, 2360000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "bytes/copy-64k", 515000L, 506000L, 522000L, 511000L, 509000L, 518000L, 524000L,
      512000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "tensor/matmul/f32-64x64", 6120000L, 6040000L, 6190000L, 6080000L, 6150000L,
      6060000L, 6210000L, 6100000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "nn/activation/relu-1m", 1360000L, 1335000L, 1378000L, 1352000L, 1344000L,
      1369000L, 1385000L, 1357000L,
    ),
  )
  .add_samples(
    add_eight_samples(
      "attention/softmax-head-128", 4280000L, 4210000L, 4360000L, 4250000L, 4310000L,
      4230000L, 4390000L, 4270000L,
    ),
  )
  .finish()
}

///|
test "default benchmark target catalog is usable" {
  let targets = default_benchmark_targets()
  assert_eq(targets.length(), 13)
  assert_eq(targets[0], "array/sort/int-10k")
  assert_eq(targets[10], "tensor/matmul/f32-64x64")
  assert_eq(targets[12], "attention/softmax-head-128")
}

///|
test "default smoke suite exposes built-in benchmark cases" {
  let suite = default_smoke_suite()
  assert_eq(suite.len(), 13)
  assert_eq(suite.get(3).name(), "parser/json-like/32k")
  assert_eq(suite.get(11).name(), "nn/activation/relu-1m")
  assert_eq(suite.get(12).name(), "attention/softmax-head-128")
}
