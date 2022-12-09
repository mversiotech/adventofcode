## Solution for https://adventofcode.com/2022/day/9
## tl;dr: Snake, the video game, except it's no fun.

import std/sets
import std/strutils

const InputFile = "../../input/day09.txt"

type
  Direction = enum
    Left, Right, Up, Down

  Motion = object
    dir: Direction
    steps: int

  Vec2 = object
    x, y: int

  Rope = object
    knots: seq[Vec2]
    visited: HashSet[Vec2]


func newRope(numknots: int): ref Rope =
  new(result)
  result.knots = newSeq[Vec2](numknots)
  result.visited = initHashSet[Vec2]()
  result.visited.incl(result.knots[0])


func sign(n: int): int =
  if n < 0: -1 elif n > 0: 1 else: 0


func move(rope: ref Rope, m: Motion) =
  let vecs = [(-1, 0), (1, 0), (0, 1), (0, -1)]
  let vec = vecs[ord(m.dir)]
  for i in 0..<m.steps:
    rope.knots[0].x += vec[0]
    rope.knots[0].y += vec[1]
    for j in 1..<len(rope.knots):
      let dx = rope.knots[j-1].x - rope.knots[j].x
      let dy = rope.knots[j-1].y - rope.knots[j].y
      if abs(dx) > 1 or abs(dy) > 1:
        rope.knots[j].x += sign(dx)
        rope.knots[j].y += sign(dy)
    rope.visited.incl(rope.knots[^1])


func parseMotion(s: string): Motion =
  let parts = s.split(' ')
  if len(parts) != 2:
    raise newException(ValueError, "cannot parse motion " &  s)
  result.steps = parts[1].parseInt()
  case parts[0]
  of "L":
    result.dir = Left
  of "R":
    result.dir = Right
  of "U":
    result.dir = Up
  of "D":
    result.dir = Down
  else:
    raise newException(ValueError, "cannot parse motion " &  s)


proc readMotions(filename: string): seq[Motion] =
  let f = open(filename)
  try:
    var line: string
    while f.readLine(line):
      result.add(parseMotion(line))
  finally:
    f.close()


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


if isMainModule:
  try:
    let motions = readMotions(InputFile)
    var ropes = (newRope(2), newRope(10))
    for m in motions:
      ropes[0].move(m)
      ropes[1].move(m)
    echo("Part 1: ", ropes[0].visited.card())
    echo("Part 2: ", ropes[1].visited.card())
  except IOError, ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
