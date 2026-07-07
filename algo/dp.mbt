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
fn make_seq_array(size : Int, offset : Int) -> Array[Int] {
  let arr = Array::make(size, 0)
  for i = 0; i < size; i = i + 1 {
    arr[i] = (i + offset) % 26
  }
  arr
}

///|
pub fn lcs(a : Array[Int], b : Array[Int]) -> Int {
  let m = a.length()
  let n = b.length()
  let dp = Array::make((m + 1) * (n + 1), 0)
  for i = 1; i <= m; i = i + 1 {
    for j = 1; j <= n; j = j + 1 {
      if a[i - 1] == b[j - 1] {
        dp[i * (n + 1) + j] = dp[(i - 1) * (n + 1) + (j - 1)] + 1
      } else {
        let from_top = dp[(i - 1) * (n + 1) + j]
        let from_left = dp[i * (n + 1) + (j - 1)]
        dp[i * (n + 1) + j] = if from_top > from_left {
          from_top
        } else {
          from_left
        }
      }
    }
  }
  dp[m * (n + 1) + n]
}

///|
pub fn bench_lcs_100x100() -> Unit {
  let a = make_seq_array(100, 0)
  let b = make_seq_array(100, 5)
  let _ = lcs(a, b)
}

///|
test "lcs computes correct length" {
  let a = [1, 3, 4, 5, 6, 7, 8]
  let b = [1, 3, 5, 7, 9, 10]
  assert_eq(lcs(a, b), 4)
}

///|
test "lcs of identical sequences is full length" {
  let a = [1, 2, 3, 4, 5]
  assert_eq(lcs(a, a), 5)
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
