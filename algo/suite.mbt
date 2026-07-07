///|
fn add_samples(name : String, values : Array[Int64]) -> @bench.Samples {
  let mut s = @bench.Samples::new(name)
  for v in values {
    s = s.add_nanos(v)
  }
  s
}

///|
pub fn algo_smoke_suite() -> @bench.SuiteResult {
  let config = @bench.BenchmarkConfig::default()
    .with_warmup_runs(5)
    .with_measure_runs(20)
    .with_noise_threshold(2.0)
  @bench.BenchmarkSuite::new("MoonBench algorithm complexity benchmark")
  .with_config(config)
  // Sorting: O(n²)
  .add_samples(
    add_samples("algo/sort/bubble/1k", [
      4180000L, 4310000L, 4160000L, 4340000L, 4200000L, 4280000L, 4150000L, 4350000L,
      4190000L, 4260000L, 4220000L, 4300000L, 4170000L, 4330000L, 4210000L, 4270000L,
      4140000L, 4320000L, 4230000L, 4250000L,
    ]),
  )
  .add_samples(
    add_samples("algo/sort/insertion/1k", [
      3090000L, 3140000L, 3070000L, 3160000L, 3100000L, 3130000L, 3080000L, 3150000L,
      3110000L, 3120000L, 3085000L, 3145000L, 3075000L, 3155000L, 3095000L, 3125000L,
      3065000L, 3165000L, 3105000L, 3115000L,
    ]),
  )
  // Sorting: O(n log n)
  .add_samples(
    add_samples("algo/sort/quick/10k", [
      1042000L, 1058000L, 1038000L, 1062000L, 1045000L, 1055000L, 1036000L, 1064000L,
      1048000L, 1052000L, 1040000L, 1060000L, 1034000L, 1066000L, 1046000L, 1054000L,
      1032000L, 1068000L, 1050000L, 1056000L,
    ]),
  )
  .add_samples(
    add_samples("algo/sort/merge/10k", [
      1242000L, 1258000L, 1238000L, 1262000L, 1245000L, 1255000L, 1236000L, 1264000L,
      1248000L, 1252000L, 1240000L, 1260000L, 1234000L, 1266000L, 1246000L, 1254000L,
      1232000L, 1268000L, 1250000L, 1256000L,
    ]),
  )
  .add_samples(
    add_samples("algo/sort/heap/10k", [
      1372000L, 1388000L, 1368000L, 1392000L, 1375000L, 1385000L, 1366000L, 1394000L,
      1378000L, 1382000L, 1370000L, 1390000L, 1364000L, 1396000L, 1376000L, 1384000L,
      1362000L, 1398000L, 1380000L, 1386000L,
    ]),
  )
  // Search: O(n) and O(log n)
  .add_samples(
    add_samples("algo/search/linear/10k", [
      49800L, 50200L, 49500L, 50500L, 49900L, 50100L, 49600L, 50400L, 49700L, 50300L,
      49850L, 50150L, 49450L, 50550L, 49950L, 50050L, 49300L, 50700L, 49750L, 50250L,
    ]),
  )
  .add_samples(
    add_samples("algo/search/binary/100k", [
      820L, 860L, 810L, 870L, 830L, 850L, 805L, 875L, 825L, 855L, 835L, 845L, 800L,
      880L, 840L, 840L, 790L, 890L, 815L, 865L,
    ]),
  )
  // String matching: O(nm) and O(n+m)
  .add_samples(
    add_samples("algo/string/naive/10k", [
      182000L, 188000L, 180000L, 190000L, 183000L, 187000L, 179000L, 191000L, 181000L,
      189000L, 184000L, 186000L, 177000L, 193000L, 185000L, 185000L, 176000L, 194000L,
      182000L, 188000L,
    ]),
  )
  .add_samples(
    add_samples("algo/string/kmp/10k", [
      96000L, 100000L, 95000L, 101000L, 97000L, 99000L, 94000L, 102000L, 96500L,
      99500L, 97500L, 98500L, 93000L, 103000L, 98000L, 98000L, 92000L, 104000L, 96000L,
      100000L,
    ]),
  )
  // Graph: O(V+E) and O(V²)
  .add_samples(
    add_samples("algo/graph/bfs/v512", [
      198000L, 202000L, 197000L, 203000L, 199000L, 201000L, 196000L, 204000L, 198500L,
      201500L, 199500L, 200500L, 195000L, 205000L, 200000L, 200000L, 194000L, 206000L,
      198000L, 202000L,
    ]),
  )
  .add_samples(
    add_samples("algo/graph/dfs/v512", [
      178000L, 182000L, 177000L, 183000L, 179000L, 181000L, 176000L, 184000L, 178500L,
      181500L, 179500L, 180500L, 175000L, 185000L, 180000L, 180000L, 174000L, 186000L,
      178000L, 182000L,
    ]),
  )
  .add_samples(
    add_samples("algo/graph/dijkstra/v256", [
      492000L, 508000L, 490000L, 510000L, 494000L, 506000L, 488000L, 512000L, 496000L,
      504000L, 498000L, 502000L, 486000L, 514000L, 500000L, 500000L, 484000L, 516000L,
      492000L, 508000L,
    ]),
  )
  // Dynamic programming: O(n)
  .add_samples(
    add_samples("algo/dp/fib/iter/1k", [
      2200L, 2400L, 2150L, 2450L, 2250L, 2350L, 2100L, 2500L, 2300L, 2300L, 2180L,
      2420L, 2080L, 2520L, 2280L, 2320L, 2050L, 2550L, 2220L, 2380L,
    ]),
  )
  .add_samples(
    add_samples("algo/dp/fib/memo/1k", [
      6200L, 6400L, 6150L, 6450L, 6250L, 6350L, 6100L, 6500L, 6300L, 6300L, 6180L,
      6420L, 6080L, 6520L, 6280L, 6320L, 6050L, 6550L, 6220L, 6380L,
    ]),
  )
  // Dynamic programming: O(mn)
  .add_samples(
    add_samples("algo/dp/lcs/100x100", [
      48000L, 52000L, 47500L, 52500L, 49000L, 51000L, 47000L, 53000L, 48500L, 51500L,
      49500L, 50500L, 46500L, 53500L, 50000L, 50000L, 46000L, 54000L, 48000L, 52000L,
    ]),
  )
  // Numeric: O(n) and O(n³)
  .add_samples(
    add_samples("algo/numeric/dot/100k", [
      98000L, 102000L, 97500L, 102500L, 99000L, 101000L, 97000L, 103000L, 98500L,
      101500L, 99500L, 100500L, 96500L, 103500L, 100000L, 100000L, 96000L, 104000L,
      98000L, 102000L,
    ]),
  )
  .add_samples(
    add_samples("algo/numeric/matmul/128", [
      1980000L, 2020000L, 1975000L, 2025000L, 1990000L, 2010000L, 1970000L, 2030000L,
      1985000L, 2015000L, 1995000L, 2005000L, 1965000L, 2035000L, 2000000L, 2000000L,
      1960000L, 2040000L, 1980000L, 2020000L,
    ]),
  )
  .finish()
}

///|
test "algo smoke suite has correct number of benchmarks" {
  let suite = algo_smoke_suite()
  assert_eq(suite.len(), 17)
}

///|
test "algo smoke suite uses 20 measure runs" {
  let suite = algo_smoke_suite()
  assert_eq(suite.config().measure_runs(), 20)
  assert_eq(suite.config().warmup_runs(), 5)
}

///|
test "algo smoke suite first result has 20 samples" {
  let suite = algo_smoke_suite()
  assert_eq(suite.get(0).samples().len(), 20)
  assert_eq(suite.get(0).name(), "algo/sort/bubble/1k")
}
