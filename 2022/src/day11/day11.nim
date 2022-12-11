## Solution for https://adventofcode.com/2022/day/11
##
## The key to part 2 is that we care only about the divisibility of the worry
## level, not its actual value. That means we can reduce it by the least common
## multiple of all the monkey's divisors. The divisors are all coprime, so the
## lcm is simply the product of them all.

import std/deques
import std/strscans
import std/strutils

const
  InputFile = "../../input/day11.txt"
  P1Rounds = 20
  P2Rounds = 10000

  MonkeyFmt = """Monkey $i:
  Starting items: $+
  Operation: new = old $+
  Test: divisible by $i
    If true: throw to monkey $i
    If false: throw to monkey $i"""

type
  Operator = enum
    Add, Multiply, Square

  Monkey = object
    op: Operator
    id, oparg, divisor, nextTrue, nextFalse, inspections: int
    items: Deque[int]


func parseMonkey(s: string): ref Monkey =
  ## Parses a single monkey definition
  var
    m: ref Monkey
    items, op: string
  new(m)
  if not scanf(s, MonkeyFmt, m.id, items, op, m.divisor, m.nextTrue, m.nextFalse):
    raise newException(ValueError, "cannot parse " & s)
  for it in items.split(", "):
    m.items.addLast(it.parseInt())
  if op == "* old":
    m.op = Square
  elif op.startsWith("+ "):
    m.op = Add
    m.oparg = op[2..^1].parseInt()
  elif op.startsWith("* "):
    m.op = Multiply
    m.oparg = op[2..^1].parseInt()
  else:
    raise newException(ValueError, "invalid operation: " & op)
  return m


func operate(m: ref Monkey, worry: int): int =
  ## Returns a new `worry` level based on `m.op`
  if m.op == Add: worry + m.oparg
  elif m.op == Multiply: worry * m.oparg
  else: worry * worry


func playRound(monkeys: var seq[ref Monkey], reduce: int) =
  ## Plays a single round of the game. `reduce` should be 0 for part 1 and
  ## `reductionFactor(monkeys)` for round 2.
  for m in monkeys:
    while len(m.items) > 0:
      inc(m.inspections)
      var worry = m.operate(m.items.popFirst())
      if reduce == 0:
        worry = worry div 3                       # Part 1
      else:
        worry = worry mod reduce                  # Part 2
      if worry mod m.divisor == 0:
        monkeys[m.nextTrue].items.addLast(worry)
      else:
        monkeys[m.nextFalse].items.addLast(worry)


func monkeyBusiness(monkeys: seq[ref Monkey]): int =
  ## Returns the product of the 2 largest `inspection` values in `monkeys`
  var maxinsp = [0, 0]
  for m in monkeys:
    maxinsp[1] = max(maxinsp[1], min(maxinsp[0], m.inspections))
    maxinsp[0] = max(maxinsp[0], m.inspections)
  return maxinsp[0] * maxinsp[1]


func reductionFactor(monkeys: seq[ref Monkey]): int =
  ## Returns the product of all `divisor` values in `monkeys`
  result = 1
  for m in monkeys:
    result *= m.divisor


proc readInput(filename: string): seq[ref Monkey] =
  ## Returns the input data as a sequence of monkeys
  let mkdefs = readFile(filename).split("\n\n")
  for mkdef in mkdefs:
    result.add(parseMonkey(mkdef))


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
      var
        p1monkeys = readInput(InputFile)
        p2monkeys = p1monkeys.deepCopy()
      for i in 0..<P1Rounds:
        playRound(p1monkeys, 0)
      echo("Part 1 ", monkeyBusiness(p1monkeys))
      let reduce = reductionFactor(p2monkeys)
      for i in 0..<P2Rounds:
        playRound(p2monkeys, reduce)
      echo("Part 2 ", monkeyBusiness(p2monkeys))
  except IOError:
    die("cannot read " & InputFile)
  except ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
