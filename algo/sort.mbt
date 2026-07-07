///|
fn swap_ints(arr : Array[Int], i : Int, j : Int) -> Unit {
  let tmp = arr[i]
  arr[i] = arr[j]
  arr[j] = tmp
}

///|
fn make_int_array(size : Int) -> Array[Int] {
  let arr = Array::make(size, 0)
  let mut seed = 1234567
  for i = 0; i < size; i = i + 1 {
    seed = (seed * 1664525 + 1013904223) % 2147483647
    if seed < 0 {
      seed = -seed
    }
    arr[i] = seed % (size * 10)
  }
  arr
}

///|
pub fn bubble_sort(arr : Array[Int]) -> Unit {
  let n = arr.length()
  for i = 0; i < n - 1; i = i + 1 {
    for j = 0; j < n - i - 1; j = j + 1 {
      if arr[j] > arr[j + 1] {
        swap_ints(arr, j, j + 1)
      }
    }
  }
}

///|
pub fn insertion_sort(arr : Array[Int]) -> Unit {
  let n = arr.length()
  for i = 1; i < n; i = i + 1 {
    let key = arr[i]
    let mut j = i - 1
    while j >= 0 && arr[j] > key {
      arr[j + 1] = arr[j]
      j = j - 1
    }
    arr[j + 1] = key
  }
}

///|
pub fn bench_bubble_sort_1k() -> Unit {
  let arr = make_int_array(1000)
  bubble_sort(arr)
}

///|
pub fn bench_insertion_sort_1k() -> Unit {
  let arr = make_int_array(1000)
  insertion_sort(arr)
}

///|
test "bubble sort produces sorted output" {
  let arr = [5, 3, 8, 1, 9, 2, 7, 4, 6]
  bubble_sort(arr)
  assert_eq(arr[0], 1)
  assert_eq(arr[8], 9)
  assert_true(arr[0] <= arr[1])
  assert_true(arr[3] <= arr[4])
}

///|
test "insertion sort produces sorted output" {
  let arr = [5, 3, 8, 1, 9, 2, 7, 4, 6]
  insertion_sort(arr)
  assert_eq(arr[0], 1)
  assert_eq(arr[8], 9)
  assert_true(arr[0] <= arr[1])
  assert_true(arr[3] <= arr[4])
}
