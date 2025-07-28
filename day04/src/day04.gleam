import gleam/dict.{type Dict}
import gleam/format.{printf}
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

type Point {
  Point(row: Int, col: Int)
}

fn parse(input: String) -> Dict(Point, String) {
  string.split(input, "\n")
  |> list.index_fold(dict.new(), fn(acc, row, r) {
    string.to_graphemes(row)
    |> list.index_fold(acc, fn(bcc, col, c) {
      dict.insert(bcc, Point(r, c), col)
    })
  })
}

fn get_unwrap(grid: Dict(Point, String), p: Point) -> String {
  dict.get(grid, p) |> result.unwrap("")
}

pub fn part1(input: String) -> Int {
  let dirs = [
    Point(-1, 0),
    Point(1, 1),
    Point(1, 0),
    Point(1, -1),
    Point(0, -1),
    Point(-1, -1),
    Point(-1, 1),
    Point(0, 1),
  ]
  let grid = parse(input)
  dict.fold(grid, 0, fn(acc, k, v) {
    case v == "X" {
      False -> acc
      True -> {
        let Point(row, col) = k
        list.fold(dirs, acc, fn(bcc, d) {
          let Point(dr, dc) = d
          let word =
            list.range(0, 3)
            |> list.fold("", fn(ccc, i) {
              ccc <> get_unwrap(grid, Point(row + i * dr, col + i * dc))
            })
          case word == "XMAS" {
            True -> bcc + 1
            False -> bcc
          }
        })
      }
    }
  })
}

pub fn part2(input: String) -> Int {
  let valid_corners = ["MMSS", "MSSM", "SSMM", "SMMS"]
  let grid = parse(input)
  dict.fold(grid, 0, fn(acc, k, v) {
    case v == "A" {
      False -> acc
      True -> {
        let Point(row, col) = k
        let corners =
          get_unwrap(grid, Point(row - 1, col - 1))
          <> get_unwrap(grid, Point(row - 1, col + 1))
          <> get_unwrap(grid, Point(row + 1, col + 1))
          <> get_unwrap(grid, Point(row + 1, col - 1))
        case list.contains(valid_corners, corners) {
          True -> acc + 1
          False -> acc
        }
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
