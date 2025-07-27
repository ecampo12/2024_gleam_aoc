import gary/array
import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn parse(input: String) -> List(List(Int)) {
  string.split(input, "\n")
  |> list.fold([], fn(acc, line) {
    let a =
      string.split(line, " ")
      |> list.map(fn(x) { int.parse(x) |> result.unwrap(-1) })
    list.append(acc, [a])
  })
}

fn is_safe(report: List(Int)) -> Bool {
  let diff = list.window_by_2(report) |> list.map(fn(p) { p.0 - p.1 })
  list.fold_until(diff, True, fn(_, d) {
    case
      { list.all(diff, fn(x) { { x > 0 } }) && list.contains([1, 2, 3], d) }
      || { list.all(diff, fn(x) { x < 0 }) && list.contains([-1, -2, -3], d) }
    {
      True -> list.Continue(True)
      False -> list.Stop(False)
    }
  })
}

pub fn part1(input: String) -> Int {
  let reports = parse(input)
  list.fold(reports, 0, fn(acc, level) {
    case is_safe(level) {
      True -> acc + 1
      False -> acc
    }
  })
}

// I used Gary instead of sticking to Lists, it made removing elements easier.
fn dampener(level: List(Int)) -> Bool {
  let arr = array.from_list(level, -1)
  list.range(0, list.length(level) - 1)
  |> list.fold(False, fn(acc, i) {
    let assert Ok(a) = array.drop(arr, i)
    case array.to_list_without_defaults(a) |> is_safe {
      True -> True
      False -> acc
    }
  })
}

pub fn part2(input: String) -> Int {
  let reports = parse(input)
  list.fold(reports, 0, fn(acc, level) {
    case is_safe(level) {
      True -> acc + 1
      False ->
        case dampener(level) {
          True -> acc + 1
          False -> acc
        }
    }
  })
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  printf("Part 1: ~b~n", part1_ans)
  let part2_ans = part2(input)
  printf("Part 2: ~b~n", part2_ans)
}
