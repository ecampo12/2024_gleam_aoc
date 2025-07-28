import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import simplifile.{read}

pub fn part1(input: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  regexp.scan(re, input)
  |> list.fold([], fn(acc, x) {
    let assert [a, b] =
      x.submatches
      |> list.map(fn(s) { option.unwrap(s, "") })
      |> list.map(fn(n) { int.parse(n) |> result.unwrap(0) })
    list.append(acc, [a * b])
  })
  |> int.sum
}

pub fn part2(input: String) -> Int {
  let assert Ok(re) = regexp.from_string("don't\\(\\).*?(?=do\\(\\)|$)")
  string.replace(input, "\n", "")
  |> regexp.replace(re, _, "")
  |> part1
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  printf("Part 1: ~b~n", part1_ans)
  let part2_ans = part2(input)
  printf("Part 2: ~b~n", part2_ans)
}
