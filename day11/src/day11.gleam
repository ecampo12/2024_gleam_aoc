import gleam/dict.{type Dict}
import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile.{read}

type StoneCounter =
  Dict(Int, Int)

fn add(sc: StoneCounter, k: Int, count: Int) -> StoneCounter {
  dict.upsert(sc, k, fn(x) {
    case x {
      Some(i) -> i + count
      None -> count
    }
  })
}

fn size(sc: StoneCounter) -> Int {
  dict.values(sc) |> int.sum
}

fn parse(input: String) -> StoneCounter {
  string.split(input, " ")
  |> list.fold(dict.new(), fn(acc, num) {
    int.parse(num) |> result.unwrap(0) |> add(acc, _, 1)
  })
}

fn digits_size(x: Int) -> Int {
  int.to_string(x) |> string.length
}

fn expand_stones(stones: StoneCounter) -> StoneCounter {
  dict.to_list(stones)
  |> list.fold(dict.new(), fn(acc, p) {
    let #(k, v) = p
    case k, digits_size(k) % 2 == 0 {
      0, _ -> add(acc, 1, v)
      _, True -> {
        let s = int.to_string(k)
        let len = string.length(s)

        let assert Ok(left) = string.slice(s, 0, { len / 2 }) |> int.parse
        let assert Ok(right) = string.slice(s, len / 2, len) |> int.parse
        add(acc, left, v) |> add(right, v)
      }
      _, False -> add(acc, k * 2024, v)
    }
  })
}

fn blink(sc: StoneCounter, count: Int) -> StoneCounter {
  case count {
    0 -> sc
    _ -> {
      let sc = expand_stones(sc)
      blink(sc, count - 1)
    }
  }
}

pub fn part1(input: String) -> Int {
  parse(input) |> blink(25) |> size
}

pub fn part2(input: String) -> Int {
  parse(input) |> blink(75) |> size
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  printf("Part 1: ~b~n", part1_ans)
  let part2_ans = part2(input)
  printf("Part 2: ~b~n", part2_ans)
}
