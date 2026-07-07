///|
fn make_double_array(size : Int, offset : Double) -> Array[Double] {
  let arr = Array::make(size, 0.0)
  for i = 0; i < size; i = i + 1 {
    arr[i] = offset + i.to_double() * 0.001
  }
  arr
}

///|
pub fn dot_product(a : Array[Double], b : Array[Double]) -> Double {
  let n = a.length()
  let mut sum = 0.0
  for i = 0; i < n; i = i + 1 {
    sum = sum + a[i] * b[i]
  }
  sum
}

///|
pub fn matmul(a : Array[Double], b : Array[Double], n : Int) -> Array[Double] {
  let c = Array::make(n * n, 0.0)
  for i = 0; i < n; i = i + 1 {
    for k = 0; k < n; k = k + 1 {
      let a_ik = a[i * n + k]
      for j = 0; j < n; j = j + 1 {
        c[i * n + j] = c[i * n + j] + a_ik * b[k * n + j]
      }
    }
  }
  c
}

///|
pub fn bench_dot_product_100k() -> Unit {
  let a = make_double_array(100000, 1.0)
  let b = make_double_array(100000, 2.0)
  let _ = dot_product(a, b)
}

///|
pub fn bench_matmul_128() -> Unit {
  let a = make_double_array(128 * 128, 1.0)
  let b = make_double_array(128 * 128, 0.5)
  let _ = matmul(a, b, 128)
}

///|
test "dot product of unit vectors" {
  let a = [1.0, 0.0, 0.0]
  let b = [0.0, 1.0, 0.0]
  assert_true(dot_product(a, b) == 0.0)
  let c = [1.0, 2.0, 3.0]
  let d = [1.0, 2.0, 3.0]
  assert_true(dot_product(c, d) == 14.0)
}

///|
test "matmul identity check" {
  // 2x2 identity matrix times itself = identity
  let ident = [1.0, 0.0, 0.0, 1.0]
  let result = matmul(ident, ident, 2)
  assert_true(result[0] == 1.0)
  assert_true(result[1] == 0.0)
  assert_true(result[2] == 0.0)
  assert_true(result[3] == 1.0)
}
