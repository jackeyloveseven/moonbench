///|
fn make_adjacency_list(v : Int) -> Array[Array[Int]] {
  let graph : Array[Array[Int]] = Array::make(v, [])
  for i = 0; i < v; i = i + 1 {
    graph[i] = []
  }
  // Build a sparse graph: each vertex connects to next two vertices (ring-like)
  for i = 0; i < v; i = i + 1 {
    let next1 = (i + 1) % v
    let next2 = (i + 2) % v
    graph[i].push(next1)
    graph[i].push(next2)
    graph[next1].push(i)
    graph[next2].push(i)
  }
  graph
}

///|
fn make_adjacency_matrix(v : Int) -> Array[Array[Int]] {
  let matrix : Array[Array[Int]] = Array::make(v, [])
  for i = 0; i < v; i = i + 1 {
    matrix[i] = Array::make(v, 0)
  }
  // Build a sparse weighted graph using a deterministic pattern
  let mut seed = 42
  for i = 0; i < v; i = i + 1 {
    for j = i + 1; j < v && j < i + 4; j = j + 1 {
      seed = (seed * 1103515245 + 12345) % 2147483647
      if seed < 0 {
        seed = -seed
      }
      let w = 1 + seed % 100
      matrix[i][j] = w
      matrix[j][i] = w
    }
  }
  matrix
}

///|
pub fn bfs(graph : Array[Array[Int]], start : Int) -> Array[Int] {
  let n = graph.length()
  let visited = Array::make(n, false)
  let order : Array[Int] = []
  let queue : Array[Int] = []
  queue.push(start)
  visited[start] = true
  let mut head = 0
  while head < queue.length() {
    let node = queue[head]
    head = head + 1
    order.push(node)
    for neighbor in graph[node] {
      if visited[neighbor] == false {
        visited[neighbor] = true
        queue.push(neighbor)
      }
    }
  }
  order
}

///|
fn dfs_visit(
  graph : Array[Array[Int]],
  node : Int,
  visited : Array[Bool],
  order : Array[Int],
) -> Unit {
  visited[node] = true
  order.push(node)
  for neighbor in graph[node] {
    if visited[neighbor] == false {
      dfs_visit(graph, neighbor, visited, order)
    }
  }
}

///|
pub fn dfs(graph : Array[Array[Int]], start : Int) -> Array[Int] {
  let n = graph.length()
  let visited = Array::make(n, false)
  let order : Array[Int] = []
  dfs_visit(graph, start, visited, order)
  order
}

///|
pub fn bench_bfs_v512() -> Unit {
  let graph = make_adjacency_list(512)
  let _ = bfs(graph, 0)
}

///|
pub fn bench_dfs_v512() -> Unit {
  let graph = make_adjacency_list(512)
  let _ = dfs(graph, 0)
}

///|
pub fn dijkstra(adj : Array[Array[Int]], source : Int) -> Array[Int] {
  let n = adj.length()
  let dist = Array::make(n, 2147483647)
  let visited = Array::make(n, false)
  dist[source] = 0
  let mut count = 0
  while count < n {
    let mut u = -1
    let mut min_dist = 2147483647
    for v = 0; v < n; v = v + 1 {
      if visited[v] == false && dist[v] < min_dist {
        u = v
        min_dist = dist[v]
      }
    }
    if u == -1 {
      count = n
    } else {
      visited[u] = true
      for v = 0; v < n; v = v + 1 {
        if adj[u][v] > 0 && visited[v] == false {
          let new_dist = dist[u] + adj[u][v]
          if new_dist < dist[v] {
            dist[v] = new_dist
          }
        }
      }
      count = count + 1
    }
  }
  dist
}

///|
pub fn bench_dijkstra_v256() -> Unit {
  let adj = make_adjacency_matrix(256)
  let _ = dijkstra(adj, 0)
}

///|
test "dijkstra finds shortest paths" {
  let adj = make_adjacency_matrix(8)
  let dist = dijkstra(adj, 0)
  assert_eq(dist[0], 0)
  assert_true(dist[1] > 0)
}

///|
test "bfs visits all reachable nodes" {
  let graph = make_adjacency_list(16)
  let order = bfs(graph, 0)
  assert_eq(order.length(), 16)
  assert_eq(order[0], 0)
}

///|
test "dfs visits all reachable nodes" {
  let graph = make_adjacency_list(16)
  let order = dfs(graph, 0)
  assert_eq(order.length(), 16)
  assert_eq(order[0], 0)
}
