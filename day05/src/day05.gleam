import gleam/dict.{type Dict}
import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import gleam/string
import simplifile.{read}

type Rule {
  Rule(a: String, b: String)
}

type Update {
  Update(pages: List(String), rules: List(Rule))
}

fn parse(input: String) -> List(Update) {
  let assert [r, p] = string.split(input, "\n\n")
  let rules =
    string.split(r, "\n")
    |> list.fold([], fn(acc, rule) {
      let assert [n1, n2] = string.split(rule, "|")
      list.append(acc, [Rule(n1, n2)])
    })
  string.split(p, "\n")
  |> list.fold([], fn(acc, line) {
    let pages = string.split(line, ",")
    let s = set.from_list(pages)
    let local_rules =
      list.fold(rules, [], fn(rcc, r) {
        case set.contains(s, r.a) && set.contains(s, r.b) {
          True -> list.append(rcc, [r])
          False -> rcc
        }
      })
    list.append(acc, [Update(pages, local_rules)])
  })
}

fn is_valid(u: Update) -> Bool {
  let index_map =
    list.index_map(u.pages, fn(x, i) { #(x, i) }) |> dict.from_list
  list.fold(u.rules, True, fn(acc, rule) {
    let assert Ok(a) = dict.get(index_map, rule.a)
    let assert Ok(b) = dict.get(index_map, rule.b)
    case a > b {
      True -> False
      False -> acc
    }
  })
}

pub fn part1(input: String) -> Int {
  let updates = parse(input)
  list.map(updates, fn(update) {
    case is_valid(update) {
      False -> 0
      True -> {
        let assert Ok(num) =
          list.drop(update.pages, list.length(update.pages) / 2)
          |> list.first
        int.parse(num) |> result.unwrap(0)
      }
    }
  })
  |> int.sum
}

fn ts_loop(
  graph: Dict(String, List(String)),
  in_degree: Dict(String, Int),
  queue: List(String),
  sorted: List(String),
) -> List(String) {
  case list.length(queue) > 0 {
    False -> sorted
    True -> {
      let assert Ok(node) = list.first(queue)
      let queue = list.drop(queue, 1)
      let sorted = list.append(sorted, [node])
      let neighbors = case dict.get(graph, node) {
        Ok(x) -> x
        Error(_) -> []
      }
      let #(in_degree, queue) =
        list.fold(neighbors, #(in_degree, queue), fn(acc, n) {
          let #(id, q) = acc
          let id =
            dict.upsert(id, n, fn(x) {
              let assert Some(i) = x
              i - 1
            })
          case dict.get(id, n) == Ok(0) {
            True -> #(id, list.append(q, [n]))
            False -> #(id, q)
          }
        })
      ts_loop(graph, in_degree, queue, sorted)
    }
  }
}

fn top_sort(u: Update) -> List(String) {
  let #(graph, in_degree, nodes) =
    list.fold(u.rules, #(dict.new(), dict.new(), set.new()), fn(acc, rule) {
      let #(g, id, nodes) = acc
      let g =
        dict.upsert(g, rule.a, fn(x) {
          case x {
            Some(i) -> list.append(i, [rule.b])
            None -> [rule.b]
          }
        })
      let id =
        dict.upsert(id, rule.b, fn(x) {
          case x {
            Some(i) -> i + 1
            None -> 1
          }
        })
      #(g, id, set.insert(nodes, rule.a) |> set.insert(rule.b))
    })
  let in_degree =
    list.fold(set.to_list(nodes), in_degree, fn(acc, node) {
      dict.upsert(acc, node, fn(x) {
        case x {
          Some(i) -> i
          None -> 0
        }
      })
    })
  let queue =
    list.fold(dict.keys(in_degree), [], fn(acc, x) {
      case dict.get(in_degree, x) == Ok(0) {
        True -> list.append(acc, [x])
        False -> acc
      }
    })
  ts_loop(graph, in_degree, queue, [])
}

pub fn part2(input: String) -> Int {
  let updates = parse(input)
  list.map(updates, fn(update) {
    case is_valid(update) {
      True -> 0
      False -> {
        let sorted = top_sort(update)
        let assert Ok(num) =
          list.drop(sorted, list.length(sorted) / 2)
          |> list.first
        int.parse(num) |> result.unwrap(0)
      }
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
