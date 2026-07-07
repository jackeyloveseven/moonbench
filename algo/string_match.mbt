///|
fn make_text_array(size : Int) -> Array[Int] {
  let arr = Array::make(size, 0)
  let mut seed = 987654
  for i = 0; i < size; i = i + 1 {
    seed = (seed * 1664525 + 1013904223) % 2147483647
    if seed < 0 {
      seed = -seed
    }
    arr[i] = 97 + seed % 26
  }
  arr
}

///|
fn make_pattern_array(size : Int) -> Array[Int] {
  let arr = Array::make(size, 0)
  for i = 0; i < size; i = i + 1 {
    arr[i] = 97 + i % 8
  }
  arr
}

///|
pub fn naive_match(text : Array[Int], pattern : Array[Int]) -> Int {
  let n = text.length()
  let m = pattern.length()
  if m == 0 {
    return 0
  }
  for i = 0; i <= n - m; i = i + 1 {
    let mut j = 0
    while j < m && text[i + j] == pattern[j] {
      j = j + 1
    }
    if j == m {
      return i
    }
  }
  -1
}

///|
fn compute_kmp_failure(pattern : Array[Int]) -> Array[Int] {
  let m = pattern.length()
  let failure = Array::make(m, 0)
  let mut k = 0
  for i = 1; i < m; i = i + 1 {
    while k > 0 && pattern[i] != pattern[k] {
      k = failure[k - 1]
    }
    if pattern[i] == pattern[k] {
      k = k + 1
    }
    failure[i] = k
  }
  failure
}

///|
pub fn kmp_match(text : Array[Int], pattern : Array[Int]) -> Int {
  let n = text.length()
  let m = pattern.length()
  if m == 0 {
    return 0
  }
  let failure = compute_kmp_failure(pattern)
  let mut k = 0
  for i = 0; i < n; i = i + 1 {
    while k > 0 && text[i] != pattern[k] {
      k = failure[k - 1]
    }
    if text[i] == pattern[k] {
      k = k + 1
    }
    if k == m {
      return i - m + 1
    }
  }
  -1
}

///|
pub fn bench_naive_match_10k() -> Unit {
  let text = make_text_array(10000)
  let pattern = make_pattern_array(8)
  let _ = naive_match(text, pattern)
}

///|
pub fn bench_kmp_match_10k() -> Unit {
  let text = make_text_array(10000)
  let pattern = make_pattern_array(8)
  let _ = kmp_match(text, pattern)
}

///|
test "naive match finds pattern" {
  let text = [104, 101, 108, 108, 111]
  let pattern = [108, 108]
  assert_eq(naive_match(text, pattern), 2)
  assert_eq(naive_match(text, [120]), -1)
}

///|
test "kmp match finds pattern" {
  let text = [104, 101, 108, 108, 111]
  let pattern = [108, 108]
  assert_eq(kmp_match(text, pattern), 2)
  assert_eq(kmp_match(text, [120]), -1)
}

///|
test "kmp and naive agree on random text" {
  let text = make_text_array(500)
  let pattern = make_pattern_array(5)
  assert_eq(naive_match(text, pattern), kmp_match(text, pattern))
}
