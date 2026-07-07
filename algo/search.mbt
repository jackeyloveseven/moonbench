///|
fn make_sorted_array(size : Int) -> Array[Int] {
  let arr = Array::make(size, 0)
  for i = 0; i < size; i = i + 1 {
    arr[i] = i * 3
  }
  arr
}

///|
pub fn linear_search(arr : Array[Int], target : Int) -> Int {
  for i = 0; i < arr.length(); i = i + 1 {
    if arr[i] == target {
      return i
    }
  }
  -1
}

///|
pub fn binary_search(arr : Array[Int], target : Int) -> Int {
  let mut low = 0
  let mut high = arr.length() - 1
  while low <= high {
    let mid = low + (high - low) / 2
    if arr[mid] == target {
      return mid
    } else if arr[mid] < target {
      low = mid + 1
    } else {
      high = mid - 1
    }
  }
  -1
}

///|
pub fn bench_linear_search_10k() -> Unit {
  let arr = make_sorted_array(10000)
  let _ = linear_search(arr, 29997)
}

///|
pub fn bench_binary_search_100k() -> Unit {
  let arr = make_sorted_array(100000)
  let _ = binary_search(arr, 299997)
}

///|
test "linear search finds existing element" {
  let arr = [10, 20, 30, 40, 50]
  assert_eq(linear_search(arr, 30), 2)
  assert_eq(linear_search(arr, 99), -1)
}

///|
test "binary search finds element in sorted array" {
  let arr = make_sorted_array(1000)
  assert_eq(binary_search(arr, 0), 0)
  assert_eq(binary_search(arr, 300), 100)
  assert_eq(binary_search(arr, 1), -1)
}
