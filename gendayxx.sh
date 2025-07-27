#!/bin/bash

# day variable has no leading 0 and must be between 1 and 25
day=${1##+(0)}
if ((day < 1 || day > 25)); then
    echo "Invalid day input: $1. Must be between 1 and 25."
    return
fi
# project vartiable is "dayXX" where XX is the day variable
project=$(printf "day%02d" $1)

# year variable is the current year
year=9999

# get session cookie from file if .session exists
if [[ -f ".session" ]]; then
  AOC_SESSION=$(<".session")
fi

# validate session cookie
if [ -z "$AOC_SESSION" ]; then
    echo "AOC_SESSION isn't set. Cannot continue."
    return
fi
VALIDSESSION=$(curl -s "https://adventofcode.com/${year}/day/1/input" --cookie "session=${AOC_SESSION}")
if [[ $VALIDSESSION =~ "Puzzle inputs differ by user." ]] || [[ $VALIDSESSION =~ "500 Internal Server" ]]; then
    echo "Invalid AOC_SESSION. Cannot continue."
    return
fi

gleam new ${project}
cd ${project}
rm README.md
rm .gitignore

curl -s "https://adventofcode.com/${year}/day/${day}/input" --cookie "session=${AOC_SESSION}" -o input.txt
# Remove the trailing blank line
truncate -s -1 input.txt

echo -n "import gleam/io
import simplifile.{read}

pub fn part1(input: String) -> Int {
  todo
}

pub fn part2(input: String) -> Int {
  todo
}

pub fn main() {
  let assert Ok(input) = read(\"input.txt\")
  let part1_ans = part1(input)
  io.print(\"Part 1: \")
  io.debug(part1_ans)
  let part2_ans = part2(input)
  io.print(\"Part 2: \")
  io.debug(part2_ans)
}" > src/${project}.gleam
gleam add simplifile # used to read files
gleam add gleam_regexp@1 #regex

echo -n "import ${project}.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  todo
}

pub fn part2_test() {
  todo
}" > test/${project}_test.gleam