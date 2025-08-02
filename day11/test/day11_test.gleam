import day11.{part1}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "125 17"

pub fn part1_test() {
  part1(input) |> should.equal(55_312)
}
