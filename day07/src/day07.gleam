import gleam/bool
import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string

import immutable_lru.{type LruCache} as lru
import simplifile.{read}

fn parse(input: String) -> List(List(Int)) {
  let assert Ok(re) = regexp.from_string("\\d+")
  string.split(input, "\n")
  |> list.map(fn(line) {
    regexp.scan(re, line)
    |> list.map(fn(n) { int.parse(n.content) |> result.unwrap(0) })
  })
}

// immutable_lru instead of rememo because one of the packages it uses it out of date and uses deprecated code
fn eval(
  target: Int,
  nums: List(Int),
  curr: Int,
  cache,
) -> #(Bool, LruCache(#(Int, List(Int), Int), Bool)) {
  case curr > target, nums, lru.get(cache, #(target, nums, curr)) {
    True, _, _ -> #(False, cache)
    _, [], _ -> #(
      curr == target,
      lru.set(cache, #(target, nums, curr), curr == target),
    )
    _, _, Ok(v) -> {
      let #(_, value) = v
      #(value, cache)
    }
    _, _, Error(_) -> {
      let assert Ok(n) = list.first(nums)
      let nums = list.drop(nums, 1)
      let #(add_value, cache) = eval(target, nums, curr + n, cache)

      use <- bool.guard(add_value, #(add_value, cache))
      let #(mult_value, _) = eval(target, nums, curr * n, cache)
      #(mult_value, lru.set(cache, #(target, nums, curr), mult_value))
    }
  }
}

pub fn part1(input: String) -> Int {
  let equations = parse(input)
  list.map(equations, fn(equation) {
    let assert Ok(target) = list.first(equation)
    let eq = list.drop(equation, 1)
    let assert Ok(curr) = list.first(eq)
    let eq = list.drop(eq, 1)
    let cache = lru.new(50)
    case eval(target, eq, curr, cache) {
      #(True, _) -> target
      #(False, _) -> 0
    }
  })
  |> int.sum
}

fn eval2(
  target: Int,
  nums: List(Int),
  curr: Int,
  cache,
) -> #(Bool, LruCache(#(Int, List(Int), Int), Bool)) {
  case curr > target, nums, lru.get(cache, #(target, nums, curr)) {
    True, _, _ -> #(False, cache)
    _, [], _ -> #(
      curr == target,
      lru.set(cache, #(target, nums, curr), curr == target),
    )
    _, _, Ok(v) -> {
      let #(_, value) = v
      #(value, cache)
    }
    _, _, Error(_) -> {
      let assert Ok(n) = list.first(nums)
      let nums = list.drop(nums, 1)
      let #(add_value, _) = eval2(target, nums, curr + n, cache)
      // only using one to short circuit speeds the code up by 2 seconds. 
      use <- bool.guard(add_value, #(add_value, cache))
      let #(mult_value, _) = eval2(target, nums, curr * n, cache)

      let assert Ok(concat) =
        { int.to_string(curr) <> int.to_string(n) } |> int.parse
      let #(concat_value, _) = eval2(target, nums, concat, cache)
      #(add_value || mult_value || concat_value, cache)
    }
  }
}

pub fn part2(input: String) -> Int {
  let equations = parse(input)
  list.map(equations, fn(equation) {
    let assert Ok(target) = list.first(equation)
    let eq = list.drop(equation, 1)
    let assert Ok(curr) = list.first(eq)
    let eq = list.drop(eq, 1)
    let cache = lru.new(50)
    case eval2(target, eq, curr, cache) {
      #(True, _) -> target
      #(False, _) -> 0
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
