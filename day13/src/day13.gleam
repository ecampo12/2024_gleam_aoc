import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile.{read}

type Machine {
  Machine(ax: Int, ay: Int, bx: Int, by: Int, px: Int, py: Int)
}

fn parse(input: String) -> List(Machine) {
  let assert Ok(re) = regexp.from_string("(\\d+)")
  string.split(input, "\n\n")
  |> list.map(fn(m) {
    let assert [ax, ay, bx, by, px, py] =
      regexp.scan(re, m)
      |> list.map(fn(x) { int.parse(x.content) |> result.unwrap(0) })
    Machine(ax, ay, bx, by, px, py)
  })
}

fn determinant(a: Int, b: Int, c: Int, d: Int) -> Int {
  a * d - b * c
}

fn cramers_rule(m: Machine) -> #(Int, Int) {
  let det = determinant(m.ax, m.ay, m.bx, m.by)
  let det_x = determinant(m.px, m.bx, m.py, m.by)
  let det_y = determinant(m.ax, m.px, m.ay, m.py)
  #(det_x / det, det_y / det)
}

pub fn part1(input: String) -> Int {
  parse(input)
  |> list.map(fn(m) {
    let #(x, y) = cramers_rule(m)
    case m.ax * x + m.bx * y == m.px && m.ay * x + m.by * y == m.py {
      True -> 3 * x + y
      False -> 0
    }
  })
  |> int.sum
}

pub fn part2(input: String) -> Int {
  parse(input)
  |> list.map(fn(m) {
    let m =
      Machine(..m, px: m.px + 10_000_000_000_000, py: m.py + 10_000_000_000_000)
    let #(x, y) = cramers_rule(m)
    case m.ax * x + m.bx * y == m.px && m.ay * x + m.by * y == m.py {
      True -> 3 * x + y
      False -> 0
    }
  })
  |> int.sum
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  printf("Part 1: ~b~n", part1_ans)
  let part2_ans = part2(input)
  printf("Part 2: ~b~n", part2_ans)
}
