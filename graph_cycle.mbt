///|
// Only tasks in a directed cycle are members; Kahn's blocked descendants are
// not. Both passes are iterative, using the existing output-pin task graph.
fn graph_cyclic_members(
  next : Array[Array[Int]],
  active : Array[Bool],
) -> Array[Bool] {
  let seen = Array::make(next.length(), false)
  let postorder : Array[Int] = []
  for root in 0..<next.length() {
    if !active[root] || seen[root] {
      continue
    }
    let stack : Array[(Int, Int)] = [(root, 0)]
    seen[root] = true
    while !stack.is_empty() {
      let top = stack.length() - 1
      let (node, cursor) = stack[top]
      if cursor == next[node].length() {
        let _ = stack.pop()
        postorder.push(node)
      } else {
        stack[top] = (node, cursor + 1)
        let child = next[node][cursor]
        if active[child] && !seen[child] {
          seen[child] = true
          stack.push((child, 0))
        }
      }
    }
  }
  let reverse : Array[Array[Int]] = Array::makei(next.length(), _ => [])
  for node in 0..<next.length() {
    if active[node] {
      for child in next[node] {
        if active[child] {
          reverse[child].push(node)
        }
      }
    }
  }
  let assigned = Array::make(next.length(), false)
  let members = Array::make(next.length(), false)
  for cursor = postorder.length(); cursor > 0; {
    let root = postorder[cursor - 1]
    if assigned[root] {
      continue cursor - 1
    }
    let stack = [root]
    let component = []
    assigned[root] = true
    while !stack.is_empty() {
      let node = stack.pop().unwrap()
      component.push(node)
      for parent in reverse[node] {
        if !assigned[parent] {
          assigned[parent] = true
          stack.push(parent)
        }
      }
    }
    if component.length() > 1 || next[root].contains(root) {
      for node in component {
        members[node] = true
      }
    }
    continue cursor - 1
  }
  members
}
