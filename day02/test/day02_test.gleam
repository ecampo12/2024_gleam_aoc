import day02.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"

pub fn part1_test() {
  part1(input) |> should.equal(2)
}

pub fn part2_test() {
  part2(input) |> should.equal(4)
}
