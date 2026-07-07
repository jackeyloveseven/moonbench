///|
pub enum ComplexityTag {
  O1
  OLogN
  ON
  ONLogN
  ON2
  ON3
  Custom(String)
} derive(Eq)

///|
pub fn ComplexityTag::label(self : ComplexityTag) -> String {
  match self {
    O1 => "O(1)"
    OLogN => "O(log n)"
    ON => "O(n)"
    ONLogN => "O(n log n)"
    ON2 => "O(n²)"
    ON3 => "O(n³)"
    Custom(s) => s
  }
}

///|
pub struct AlgoMeta {
  category : String
  time_complexity : ComplexityTag
  space_complexity : ComplexityTag
}

///|
pub fn algo_meta_for(name : String) -> AlgoMeta? {
  if name.contains("algo/sort/bubble") || name.contains("algo/sort/insertion") {
    Some({ category: "sorting", time_complexity: ON2, space_complexity: O1 })
  } else if name.contains("algo/sort/quick") {
    Some({
      category: "sorting",
      time_complexity: ONLogN,
      space_complexity: OLogN,
    })
  } else if name.contains("algo/sort/merge") {
    Some({ category: "sorting", time_complexity: ONLogN, space_complexity: ON })
  } else if name.contains("algo/sort/heap") {
    Some({ category: "sorting", time_complexity: ONLogN, space_complexity: O1 })
  } else if name.contains("algo/search/linear") {
    Some({ category: "search", time_complexity: ON, space_complexity: O1 })
  } else if name.contains("algo/search/binary") {
    Some({ category: "search", time_complexity: OLogN, space_complexity: O1 })
  } else if name.contains("algo/string/naive") {
    Some({
      category: "string",
      time_complexity: Custom("O(nm)"),
      space_complexity: O1,
    })
  } else if name.contains("algo/string/kmp") {
    Some({
      category: "string",
      time_complexity: Custom("O(n+m)"),
      space_complexity: ON,
    })
  } else if name.contains("algo/graph/bfs") || name.contains("algo/graph/dfs") {
    Some({
      category: "graph",
      time_complexity: Custom("O(V+E)"),
      space_complexity: Custom("O(V)"),
    })
  } else if name.contains("algo/graph/dijkstra") {
    Some({
      category: "graph",
      time_complexity: Custom("O(V²)"),
      space_complexity: Custom("O(V)"),
    })
  } else if name.contains("algo/dp/fib/iter") {
    Some({ category: "dp", time_complexity: ON, space_complexity: O1 })
  } else if name.contains("algo/dp/fib/memo") {
    Some({ category: "dp", time_complexity: ON, space_complexity: ON })
  } else if name.contains("algo/dp/lcs") {
    Some({
      category: "dp",
      time_complexity: Custom("O(mn)"),
      space_complexity: Custom("O(mn)"),
    })
  } else if name.contains("algo/numeric/dot") {
    Some({ category: "numeric", time_complexity: ON, space_complexity: O1 })
  } else if name.contains("algo/numeric/matmul") {
    Some({ category: "numeric", time_complexity: ON3, space_complexity: ON2 })
  } else {
    None
  }
}

///|
test "complexity tag labels" {
  assert_eq(O1.label(), "O(1)")
  assert_eq(OLogN.label(), "O(log n)")
  assert_eq(ON.label(), "O(n)")
  assert_eq(ONLogN.label(), "O(n log n)")
  assert_eq(Custom("O(nm)").label(), "O(nm)")
}

///|
test "algo_meta_for identifies sorting algorithms" {
  match algo_meta_for("algo/sort/bubble/1k") {
    Some(meta) => {
      assert_eq(meta.category, "sorting")
      assert_eq(meta.time_complexity.label(), "O(n²)")
      assert_eq(meta.space_complexity.label(), "O(1)")
    }
    None => assert_true(false)
  }
  match algo_meta_for("algo/sort/quick/10k") {
    Some(meta) => assert_eq(meta.time_complexity.label(), "O(n log n)")
    None => assert_true(false)
  }
}

///|
test "algo_meta_for returns None for non-algo names" {
  match algo_meta_for("array/sort/int-10k") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
  match algo_meta_for("graph/bfs/grid-128") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}
