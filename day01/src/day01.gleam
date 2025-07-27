import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn parse(input: String) -> #(List(Int), List(Int)) {
  string.split(input, "\n")
  |> list.fold(#([], []), fn(acc, x) {
    let #(l, r) = acc
    let assert [a, b] =
      string.split(x, "   ")
      |> list.map(fn(x) { int.parse(x) |> result.unwrap(-1) })
    #(list.append(l, [a]), list.append(r, [b]))
  })
}

pub fn part1(input: String) -> Int {
  let #(a, b) = parse(input)
  let left = list.sort(a, int.compare)
  let right = list.sort(b, int.compare)
  list.zip(left, right)
  |> list.fold(0, fn(acc, p) { acc + int.absolute_value(p.0 - p.1) })
}

pub fn part2(input: String) -> Int {
  let #(a, b) = parse(input)
  list.fold(a, 0, fn(acc, num) {
    acc + { num * list.count(b, fn(x) { x == num }) }
  })
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  printf("Part 1: ~b~n", part1_ans)
  let part2_ans = part2(input)
  printf("Part 2: ~b~n", part2_ans)
}
