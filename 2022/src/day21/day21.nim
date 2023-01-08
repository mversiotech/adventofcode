## Solution for https://adventofcode.com/2022/day/21
##
## The monkeys whose number isn't readily available in the input form a binary
## tree starting from the monkey "root". The branches of the tree represent the
## left-hand operand and right-hand operand of a monkeys math operation.
## For part 1, we recursively evaluate the tree. For part 2, we traverse the
## tree down to "humn" and keep track of the expected result value.
 
import std/[strscans, sets, tables]

const
  InputFile  = "../../input/day21.txt"
  GoodMonkey = "$+: $i" 
  BadMonkey  = "$+: $+ $c $+"
  HumanName  = "humn"
  RootName   = "root"

type
  Operator = enum
    Add, Sub, Mul, Div

  Monkey = object
    op:   Operator
    lhs, rhs: string

  Jungle = object
    monkeys: Table[string, Monkey]
    results: Table[string, int]


func evaluate(jungle: var Jungle, name: string): int =
  ## Returns the result for (i.e. the number yelled by) the monkey with the
  ## given `name`.
  if jungle.results.contains(name):
    return jungle.results[name]
  let
    monkey = jungle.monkeys[name]
    lhs = jungle.evaluate(monkey.lhs)
    rhs = jungle.evaluate(monkey.rhs)
    value = case monkey.op
      of Add:
        lhs + rhs
      of Sub:
        lhs - rhs
      of Mul:
        lhs * rhs
      of Div:
        lhs div rhs
  jungle.results[name] = value
  return value


func lhsFor(monkey: Monkey, rhs, res: int): int =
  ## Returns the left operand so that `evaluate` yields `res` when the right
  ## operand is `rhs`
  case monkey.op
  of Add:
    res - rhs
  of Sub:
    res + rhs
  of Mul:
    res div rhs
  of Div:
    res * rhs


func rhsFor(monkey: Monkey, lhs, res: int): int =
  ## Returns the right operand so that `evaluate` yields `res` when the left
  ## operand is `lhs`
  case monkey.op
  of Add:
    res - lhs
  of Sub:
    lhs - res
  of Mul:
    res div lhs
  of Div:
    lhs div res


func findHumanDeps(jungle: var Jungle, root: string, humanDeps: var HashSet[string]): bool =
  ## Returns a set containing the names of all monkeys whose result depends on the value
  ## yelled by the human.
  if not jungle.monkeys.contains(root):
    return false
  let monkey = jungle.monkeys[root]
  if monkey.lhs == HumanName or monkey.rhs == HumanName:
    humanDeps.incl(root)
    return true
  if findHumanDeps(jungle, monkey.lhs, humanDeps) or findHumanDeps(jungle, monkey.rhs, humanDeps):
    humanDeps.incl(root)
    return true
  return false


func fixHumanValue(jungle: var Jungle, root: string, expect: int, humanDeps: HashSet[string]) =
  ## Sets the value yelled by the human so that the monkey with name `root` evaluates to `expect`.
  if root == HumanName:
    jungle.results[HumanName] = expect
    return
  let monkey = jungle.monkeys[root]
  if humanDeps.contains(monkey.lhs) or monkey.lhs == HumanName:
    let rhs = jungle.evaluate(monkey.rhs)
    let expect = monkey.lhsFor(rhs, expect)
    jungle.fixHumanValue(monkey.lhs, expect, humanDeps)
  else:
    let lhs = jungle.evaluate(monkey.lhs)
    let expect = monkey.rhsFor(lhs, expect)
    jungle.fixHumanValue(monkey.rhs, expect, humanDeps)


func fixHumanValue(jungle: var Jungle) =
  ## Sets the value yelled by the human so that both branches beneath the "root"
  ## monkey yield the same value.
  var humanDeps = initHashSet[string]()
  discard jungle.findHumanDeps(RootName, humanDeps)
  var root = jungle.monkeys[RootName]
  if humanDeps.contains(root.lhs):
    let rhs = jungle.evaluate(root.rhs)
    jungle.fixHumanValue(root.lhs, rhs, humanDeps)
  else:
    let lhs = jungle.evaluate(root.lhs)
    jungle.fixHumanValue(root.rhs, lhs, humanDeps)


func parseMonkey(line: string): (string, Monkey) =
  ## Parses the definition of a single monkey that contains an equation
  var
    name, lhs, rhs: string
    op: char
  if not line.scanf(BadMonkey, name, lhs, op, rhs):
    raise newException(ValueError, "invalid monkey: " & line)
  var m = Monkey(lhs: lhs, rhs: rhs)
  case op
  of '+':
    m.op = Add
  of '-':
    m.op = Sub
  of '*':
    m.op = Mul
  of '/':
    m.op = Div
  else:
    raise newException(ValueError, "invalid operator " & op & " in " & line)
  return (name, m)


proc readInput(filename: string): Jungle =
  ## Reads all input data and returns ready results and monkey equations
  var
    monkeys = initTable[string, Monkey]()
    results = initTable[string, int]()
    line, name: string
    value: int
    monkey: Monkey
  let f = open(filename)
  try:
    while f.readLine(line):
      if line.scanf(GoodMonkey, name, value):
        results[name] = value
      else:
        (name, monkey) = parseMonkey(line)
        monkeys[name] = monkey
  finally:
    f.close()
  return Jungle(monkeys: monkeys, results: results)


when isMainModule:
  var jungle = readInput(InputFile)
  echo("Part 1: ", jungle.evaluate(RootName))
  jungle.fixHumanValue()
  echo("Part 2: ", jungle.evaluate(HumanName))
