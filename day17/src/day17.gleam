import gleam/float
import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import glearray.{type Array}
import simplifile.{read}

type Registers =
  #(Int, Int, Int)

fn parse(input: String) -> #(Registers, Array(Int)) {
  let assert Ok(re) = regexp.from_string("\\d+")
  let nums =
    regexp.scan(re, input)
    |> list.map(fn(x) { int.parse(x.content) |> result.unwrap(0) })
  let assert [a, b, c] = list.take(nums, 3)
  let program = list.drop(nums, 3) |> glearray.from_list
  #(#(a, b, c), program)
}

fn combo_value(reg: Registers, operand: Int) -> Float {
  let #(a, b, c) = reg
  case operand < 4, operand {
    True, _ -> int.to_float(operand)
    False, 4 -> int.to_float(a)
    False, 5 -> int.to_float(b)
    False, 6 -> int.to_float(c)
    False, _ -> panic as "Invalid combo operand"
  }
}

fn prog_loop(
  reg: Registers,
  prog: Array(Int),
  ptr: Int,
  output: List(String),
) -> String {
  case ptr < glearray.length(prog) {
    False -> string.join(output, ",")
    True -> {
      let #(a, b, c) = reg
      let assert Ok(opcode) = glearray.get(prog, ptr)
      let assert Ok(operand) = glearray.get(prog, ptr + 1)
      case opcode {
        0 -> {
          let p =
            int.power(2, combo_value(reg, operand))
            |> result.unwrap(0.0)
            |> float.truncate
          let a = a / p
          prog_loop(#(a, b, c), prog, ptr + 2, output)
        }
        1 -> {
          let b = int.bitwise_exclusive_or(b, operand)
          prog_loop(#(a, b, c), prog, ptr + 2, output)
        }
        2 -> {
          let b = { combo_value(reg, operand) |> float.truncate } % 8
          prog_loop(#(a, b, c), prog, ptr + 2, output)
        }
        3 -> {
          case a != 0 {
            True -> prog_loop(#(a, b, c), prog, operand, output)
            False -> prog_loop(#(a, b, c), prog, ptr + 2, output)
          }
        }
        4 -> {
          let b = int.bitwise_exclusive_or(b, c)
          prog_loop(#(a, b, c), prog, ptr + 2, output)
        }
        5 -> {
          let s =
            { { combo_value(reg, operand) |> float.truncate } % 8 }
            |> int.to_string
          list.append(output, [s]) |> prog_loop(#(a, b, c), prog, ptr + 2, _)
        }
        6 -> {
          let p =
            int.power(2, combo_value(reg, operand))
            |> result.unwrap(0.0)
            |> float.truncate
          let b = a / p
          prog_loop(#(a, b, c), prog, ptr + 2, output)
        }
        7 -> {
          let p =
            int.power(2, combo_value(reg, operand))
            |> result.unwrap(0.0)
            |> float.truncate
          let c = a / p
          prog_loop(#(a, b, c), prog, ptr + 2, output)
        }
        _ -> {
          let err =
            format.sprintf("Invalid opcode:  ~b~n", opcode) |> result.unwrap("")
          panic as err
        }
      }
    }
  }
}

fn run_program(registers: Registers, program: Array(Int)) -> String {
  prog_loop(registers, program, 0, [])
}

pub fn part1(input: String) -> String {
  let #(registers, program) = parse(input)
  run_program(registers, program)
}

fn find_quine_loop(prog: Array(Int), index: Int, a: Int) -> Result(Int, Nil) {
  list.range(0, 7)
  |> list.fold_until(Error(Nil), fn(acc, candidate) {
    let res = run_program(#(a * 8 + candidate, 0, 0), prog)
    let p =
      glearray.to_list(prog)
      |> list.map(int.to_string)
      |> list.drop(index)
      |> string.join(",")
    case res == p, index {
      True, 0 -> list.Stop(Ok(a * 8 + candidate))
      True, _ -> {
        let ret = find_quine_loop(prog, index - 1, a * 8 + candidate)
        case ret {
          Error(_) -> list.Continue(acc)
          Ok(_) -> list.Stop(ret)
        }
      }
      False, _ -> list.Continue(acc)
    }
  })
}

fn find_quine(program: Array(Int)) -> Int {
  find_quine_loop(program, glearray.length(program) - 1, 0)
  |> result.unwrap(0)
}

pub fn part2(input: String) -> Int {
  let #(_, program) = parse(input)
  find_quine(program)
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  printf("Part 1: ~s~n", part1_ans)
  let part2_ans = part2(input)
  printf("Part 2: ~b~n", part2_ans)
}
