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
fn partition(arr : Array[Int], low : Int, high : Int) -> Int {
  let pivot = arr[high]
  let mut i = low - 1
  for j = low; j < high; j = j + 1 {
    if arr[j] <= pivot {
      i = i + 1
      swap_ints(arr, i, j)
    }
  }
  swap_ints(arr, i + 1, high)
  i + 1
}

///|
fn quicksort_helper(arr : Array[Int], low : Int, high : Int) -> Unit {
  if low < high {
    let pi = partition(arr, low, high)
    quicksort_helper(arr, low, pi - 1)
    quicksort_helper(arr, pi + 1, high)
  }
}

///|
pub fn quicksort(arr : Array[Int]) -> Unit {
  let n = arr.length()
  if n > 1 {
    quicksort_helper(arr, 0, n - 1)
  }
}

///|
fn merge_arrays(arr : Array[Int], left : Int, mid : Int, right : Int) -> Unit {
  let n1 = mid - left + 1
  let n2 = right - mid
  let left_arr = Array::make(n1, 0)
  let right_arr = Array::make(n2, 0)
  for i = 0; i < n1; i = i + 1 {
    left_arr[i] = arr[left + i]
  }
  for j = 0; j < n2; j = j + 1 {
    right_arr[j] = arr[mid + 1 + j]
  }
  let mut i = 0
  let mut j = 0
  let mut k = left
  while i < n1 && j < n2 {
    if left_arr[i] <= right_arr[j] {
      arr[k] = left_arr[i]
      i = i + 1
    } else {
      arr[k] = right_arr[j]
      j = j + 1
    }
    k = k + 1
  }
  while i < n1 {
    arr[k] = left_arr[i]
    i = i + 1
    k = k + 1
  }
  while j < n2 {
    arr[k] = right_arr[j]
    j = j + 1
    k = k + 1
  }
}

///|
fn merge_sort_helper(arr : Array[Int], left : Int, right : Int) -> Unit {
  if left < right {
    let mid = left + (right - left) / 2
    merge_sort_helper(arr, left, mid)
    merge_sort_helper(arr, mid + 1, right)
    merge_arrays(arr, left, mid, right)
  }
}

///|
pub fn merge_sort(arr : Array[Int]) -> Unit {
  let n = arr.length()
  if n > 1 {
    merge_sort_helper(arr, 0, n - 1)
  }
}

///|
fn heapify(arr : Array[Int], n : Int, i : Int) -> Unit {
  let mut largest = i
  let left = 2 * i + 1
  let right = 2 * i + 2
  if left < n && arr[left] > arr[largest] {
    largest = left
  }
  if right < n && arr[right] > arr[largest] {
    largest = right
  }
  if largest != i {
    swap_ints(arr, i, largest)
    heapify(arr, n, largest)
  }
}

///|
pub fn heap_sort(arr : Array[Int]) -> Unit {
  let n = arr.length()
  let mut i = n / 2 - 1
  while i >= 0 {
    heapify(arr, n, i)
    i = i - 1
  }
  let mut j = n - 1
  while j > 0 {
    swap_ints(arr, 0, j)
    heapify(arr, j, 0)
    j = j - 1
  }
}

///|
pub fn bench_heap_sort_10k() -> Unit {
  let arr = make_int_array(10000)
  heap_sort(arr)
}

///|
pub fn bench_quicksort_10k() -> Unit {
  let arr = make_int_array(10000)
  quicksort(arr)
}

///|
pub fn bench_merge_sort_10k() -> Unit {
  let arr = make_int_array(10000)
  merge_sort(arr)
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
test "heap sort produces sorted output" {
  let arr = [5, 3, 8, 1, 9, 2, 7, 4, 6]
  heap_sort(arr)
  assert_eq(arr[0], 1)
  assert_eq(arr[8], 9)
}

///|
test "quicksort produces sorted output" {
  let arr = [5, 3, 8, 1, 9, 2, 7, 4, 6]
  quicksort(arr)
  assert_eq(arr[0], 1)
  assert_eq(arr[8], 9)
}

///|
test "merge sort produces sorted output" {
  let arr = [5, 3, 8, 1, 9, 2, 7, 4, 6]
  merge_sort(arr)
  assert_eq(arr[0], 1)
  assert_eq(arr[8], 9)
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
