import day17.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"
  |> part1
  |> should.equal("4,6,3,5,6,3,5,2,1,0")
}

pub fn part2_test() {
  "Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0"
  |> part2
  |> should.equal(117_440)
}
