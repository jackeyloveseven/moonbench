///|
pub fn fib_iterative(n : Int) -> Int {
  if n <= 1 {
    return n
  }
  let mut a = 0
  let mut b = 1
  for _ = 2; _ <= n; _ = _ + 1 {
    let c = a + b
    a = b
    b = c
  }
  b
}

///|
fn fib_memo_helper(n : Int, memo : Array[Int]) -> Int {
  if n <= 1 {
    return n
  }
  if memo[n] != -1 {
    return memo[n]
  }
  let result = fib_memo_helper(n - 1, memo) + fib_memo_helper(n - 2, memo)
  memo[n] = result
  result
}

///|
pub fn fib_memoized(n : Int) -> Int {
  if n < 0 {
    return 0
  }
  let memo = Array::make(n + 1, -1)
  fib_memo_helper(n, memo)
}

///|
pub fn bench_fib_iter_1k() -> Unit {
  let _ = fib_iterative(1000)
}

///|
pub fn bench_fib_memo_1k() -> Unit {
  let _ = fib_memoized(1000)
}

///|
test "fibonacci iterative produces correct values" {
  assert_eq(fib_iterative(0), 0)
  assert_eq(fib_iterative(1), 1)
  assert_eq(fib_iterative(10), 55)
  assert_eq(fib_iterative(20), 6765)
}

///|
test "fibonacci memoized matches iterative" {
  assert_eq(fib_memoized(0), 0)
  assert_eq(fib_memoized(1), 1)
  assert_eq(fib_memoized(10), 55)
  assert_eq(fib_memoized(20), 6765)
}
