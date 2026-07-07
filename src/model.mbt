///|
pub struct BenchmarkModel {
  id : String
  title : String
  description : String
  default_case : String
}

///|
pub fn BenchmarkModel::new(
  id : String,
  title : String,
  description : String,
  default_case : String,
) -> BenchmarkModel {
  { id, title, description, default_case }
}

///|
pub fn BenchmarkModel::id(self : BenchmarkModel) -> String {
  self.id
}

///|
pub fn BenchmarkModel::title(self : BenchmarkModel) -> String {
  self.title
}

///|
pub fn BenchmarkModel::description(self : BenchmarkModel) -> String {
  self.description
}

///|
pub fn BenchmarkModel::default_case(self : BenchmarkModel) -> String {
  self.default_case
}

///|
pub fn BenchmarkModel::label(self : BenchmarkModel) -> String {
  "\{self.title} (\{self.id})"
}

///|
pub fn array_sort_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "array-sort", "Array algorithms", "Sorting and indexed sequence operations",
    "array/sort/int-10k",
  )
}

///|
pub fn string_scan_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "string-scan", "String processing", "Scanning, splitting, and text traversal",
    "string/scan/ascii-64k",
  )
}

///|
pub fn collection_lookup_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "collection-lookup", "Collections", "Map/set lookup and update workloads", "collection/map-lookup/50k",
  )
}

///|
pub fn parser_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "parser", "Parsing", "JSON-like or structured input parsing", "parser/json-like/32k",
  )
}

///|
pub fn codec_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "codec", "Encoding", "CSV, binary, or text serialization output", "codec/csv-encode/10k",
  )
}

///|
pub fn graph_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "graph", "Graph algorithms", "Traversal and path-style workloads", "graph/bfs/grid-128",
  )
}

///|
pub fn numeric_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "numeric", "Numeric kernels", "Integer, floating-point, and tight arithmetic loops",
    "numeric/arithmetic-loop/1m",
  )
}

///|
pub fn hashing_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "hashing", "Hashing", "Hash calculation and digest-style byte traversal", "hashing/bytes-64k",
  )
}

///|
pub fn memory_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "memory", "Memory allocation", "Allocation, object construction, and short-lived buffers",
    "memory/alloc-small/10k",
  )
}

///|
pub fn bytes_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "bytes", "Bytes processing", "Byte copy, slicing, scanning, and buffer movement",
    "bytes/copy-64k",
  )
}

///|
pub fn tensor_matmul_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "tensor-matmul", "Tensor matrix multiplication", "Dense tensor multiply kernels used by neural-network layers",
    "tensor/matmul/f32-64x64",
  )
}

///|
pub fn nn_activation_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "nn-activation", "Neural-network activation", "Activation and normalization style forward-pass element kernels",
    "nn/activation/relu-1m",
  )
}

///|
pub fn attention_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "attention", "Attention kernel", "Scaled dot-product attention score, softmax, and head-level weight workloads",
    "attention/softmax-head-128",
  )
}

///|
pub fn algo_sort_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "algo-sort", "Algorithm: Sorting", "Bubble, insertion, quicksort, merge sort, and heap sort",
    "algo/sort/quick/10k",
  )
}

///|
pub fn algo_search_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "algo-search", "Algorithm: Search", "Linear search and binary search on integer arrays",
    "algo/search/binary/100k",
  )
}

///|
pub fn algo_string_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "algo-string", "Algorithm: String matching", "Naive substring search and KMP pattern matching",
    "algo/string/kmp/10k",
  )
}

///|
pub fn algo_graph_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "algo-graph", "Algorithm: Graph", "BFS, DFS, and Dijkstra shortest path on adjacency structures",
    "algo/graph/bfs/v512",
  )
}

///|
pub fn algo_dp_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "algo-dp", "Algorithm: Dynamic programming", "Fibonacci variants and longest common subsequence",
    "algo/dp/lcs/100x100",
  )
}

///|
pub fn algo_numeric_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "algo-numeric", "Algorithm: Numeric", "Dot product and dense matrix multiplication",
    "algo/numeric/matmul/128",
  )
}

///|
pub fn custom_model() -> BenchmarkModel {
  BenchmarkModel::new(
    "custom", "Custom workload", "User supplied benchmark case", "custom/workload",
  )
}

///|
pub fn default_benchmark_models() -> Array[BenchmarkModel] {
  [
    array_sort_model(),
    string_scan_model(),
    collection_lookup_model(),
    parser_model(),
    codec_model(),
    graph_model(),
    numeric_model(),
    hashing_model(),
    memory_model(),
    bytes_model(),
    tensor_matmul_model(),
    nn_activation_model(),
    attention_model(),
    algo_sort_model(),
    algo_search_model(),
    algo_string_model(),
    algo_graph_model(),
    algo_dp_model(),
    algo_numeric_model(),
  ]
}

///|
pub fn benchmark_model_for_name(name : String) -> BenchmarkModel {
  if name.contains("algo/sort/") {
    algo_sort_model()
  } else if name.contains("algo/search/") {
    algo_search_model()
  } else if name.contains("algo/string/") {
    algo_string_model()
  } else if name.contains("algo/graph/") {
    algo_graph_model()
  } else if name.contains("algo/dp/") {
    algo_dp_model()
  } else if name.contains("algo/numeric/") {
    algo_numeric_model()
  } else if name.contains("attention/") || name.contains("attention") {
    attention_model()
  } else if name.contains("tensor/") ||
    name.contains("matmul") ||
    name.contains("matrix") {
    tensor_matmul_model()
  } else if name.contains("nn/") ||
    name.contains("neural") ||
    name.contains("relu") ||
    name.contains("softmax") ||
    name.contains("gelu") {
    nn_activation_model()
  } else if name.contains("array/") || name.contains("sort") {
    array_sort_model()
  } else if name.contains("string/") || name.contains("scan") {
    string_scan_model()
  } else if name.contains("collection/") || name.contains("map") {
    collection_lookup_model()
  } else if name.contains("parser/") || name.contains("json") {
    parser_model()
  } else if name.contains("codec/") || name.contains("csv") {
    codec_model()
  } else if name.contains("graph/") || name.contains("bfs") {
    graph_model()
  } else if name.contains("numeric/") ||
    name.contains("arithmetic") ||
    name.contains("math") {
    numeric_model()
  } else if name.contains("hash") {
    hashing_model()
  } else if name.contains("memory/") || name.contains("alloc") {
    memory_model()
  } else if name.contains("bytes/") || name.contains("copy") {
    bytes_model()
  } else {
    custom_model()
  }
}

///|
pub fn benchmark_model_catalog_markdown() -> String {
  let models = default_benchmark_models()
  let mut out = "| id | model | default case |\n| --- | --- | --- |\n"
  for model in models {
    out = out + "| " + model.id()
    out = out + " | " + model.title()
    out = out + " | " + model.default_case()
    out = out + " |\n"
  }
  out
}

///|
test "default benchmark model catalog is stable" {
  let models = default_benchmark_models()
  assert_eq(models.length(), 19)
  assert_eq(models[0].id(), "array-sort")
  assert_eq(models[10].default_case(), "tensor/matmul/f32-64x64")
  assert_eq(models[11].default_case(), "nn/activation/relu-1m")
  assert_eq(models[12].default_case(), "attention/softmax-head-128")
}

///|
test "benchmark names map to supported models" {
  assert_eq(benchmark_model_for_name("array/sort/int-10k").id(), "array-sort")
  assert_eq(benchmark_model_for_name("parser/json-like/32k").id(), "parser")
  assert_eq(benchmark_model_for_name("memory/alloc-small/10k").id(), "memory")
  assert_eq(
    benchmark_model_for_name("tensor/matmul/f32-64x64").id(),
    "tensor-matmul",
  )
  assert_eq(
    benchmark_model_for_name("nn/activation/relu-1m").id(),
    "nn-activation",
  )
  assert_eq(
    benchmark_model_for_name("attention/softmax-head-128").id(),
    "attention",
  )
  assert_eq(benchmark_model_for_name("unknown").id(), "custom")
}
