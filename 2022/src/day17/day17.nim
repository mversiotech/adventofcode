## Solution for https://adventofcode.com/2022/day/17
##
## For part 1, just simulate dropping rocks into the cave and record the height
## of the resulting rock tower.
## For part 2, look at the changes in height at each step. The simulation
## eventually runs into a loop, i.e. it will follow the same sequence of
## height changes over and over again. By finding this cycle's values we can
## quickly determine the final height after a arbitrary number of steps.


import std/[strutils, sets]

const
  InputFile        = "../../input/day17.txt"
  CaveWidth        = 7
  RockCountP1      = 2022
  RockCountP2      = 1000000000000
  SimulationLength = RockCountP1 * 3


type
  Point = object
    x, y: int

  Rock = object
    width, height: int
    data: seq[int]


const RockShapes = [
  Rock(
    width: 4, height: 1,
    data: @[1,1,1,1]
  ),
  Rock(
    width: 3, height: 3,
    data: @[0,1,0,1,1,1,0,1,0]
  ),
  Rock(
    width: 3, height: 3,
    data: @[1,1,1,0,0,1,0,0,1]
  ),
  Rock(
    width: 1, height: 4,
    data: @[1,1,1,1]
  ),
  Rock(
    width: 2, height: 2,
    data: @[1,1,1,1]
  )
]


type Cave = object
  width, toprock, curjet: int
  jets: string
  rocks: HashSet[Point]


func newCave(width: int, jets: string): ref Cave =
  var cave: ref Cave
  new(cave)
  cave.width = width
  cave.jets = jets
  return cave


func isBlocked(c: ref Cave, p: Point): bool =
  ## Returns true if the given point is blocked by a rock or the cave walls.
  if p.x < 0 or p.x >= c.width or p.y < 0:
    true
  else:
    c.rocks.contains(p)


func canMove(c: ref Cave, r: Rock, origin: Point): bool =
  ## Returns true if a rock of the given shape can move to the given `origin`.
  for ry in 0..<r.height:
    for rx in 0..<r.width:
      let p = Point(x: origin.x + rx, y: origin.y + ry)
      if c.isBlocked(p) and r.data[ry * r.width + rx] == 1:
        return false
  return true


func settle(c: var ref Cave, r: Rock, origin: Point) =
  ## Mark the positions occupied by rock `r` as blocked.
  for ry in 0..<r.height:
    let cy = origin.y + ry
    for rx in 0..<r.width:
      if r.data[ry * r.width + rx] == 1:
        let cx = origin.x + rx
        c.rocks.incl(Point(x: cx, y: cy))


func dropRock(c: var ref Cave, shape: int) =
  ## Drop a single rock into the cave `c`
  let rock = RockShapes[shape mod len(RockShapes)]
  var origin = Point(x: 2, y: c.toprock + 3)
  while true:
    var neworg = origin
    # Try to move left or right
    let jet = c.jets[c.curjet]
    c.curjet = (c.curjet + 1) mod len(c.jets)
    if jet == '<': dec(neworg.x) else: inc(neworg.x)
    if c.canMove(rock, neworg):
      origin = neworg
    # Try to move down
    neworg = Point(x: origin.x, y: origin.y - 1)
    if not c.canMove(rock, neworg):
      c.settle(rock, origin)
      c.toprock = max(c.toprock, origin.y + rock.height)
      break
    origin = neworg


func runSimulation(cave: var ref Cave, length: int): seq[int] =
  ## Drop `length` rocks into the `cave` and return the height
  ## of the tower of rocks at each step.
  var toprocks = newSeq[int](length)
  for i in 0..<length:
    toprocks[i] = cave.toprock
    cave.dropRock(i)
  return toprocks


func deltas(data: seq[int]): string =
  ## Find the difference between each subsequent pair of ints in `data`.
  ## Since each delta fits into a uint8, we return the result as a string
  ## so that we can later use the stdlib to search for substrings.
  var d = newString(len(data)-1)
  for i in 0..<len(d):
    d[i] = chr(data[i+1] - data[i])
  return d


func findCycle(s: string, minlen: Natural): (int, int) =
  ## Cycle detection: find a substring of at least `minlen` characters
  ## that has at least 2 occurences right after each other in `s`. Not exactly
  ## bullet proof, but it works for this puzzle's input.
  for start in 0..<len(s)-minlen:
    let sub = s[start..<start+minlen]
    let i = s.find(sub, start+minlen)
    if i == -1:
      continue
    let cyclen = i - start
    if s[start..<i] == s[i..<i+cyclen]:
      return (i, cyclen)
  return (-1, 0)


func cycleMagnitude(s: string, start, length: int): int =
  ## Returns the sum of height deltas of the given cycle
  var mag: int
  for i in start..<start+length:
    mag += ord(s[i])
  return mag


proc readJets(filename: string): string =
  let jets = readFile(filename).strip()
  for c in jets:
    if c != '<' and c != '>':
      raise newException(ValueError, "invalid character: " & c)
  return jets


when isMainModule:
  var cave = newCave(CaveWidth, readJets(InputFile))
  let toprocks = runSimulation(cave, SimulationLength)
  echo("Part 1: ", toprocks[RockCountP1])
  let topdeltas = deltas(toprocks)
  let (cycstart, cyclen) = findCycle(topdeltas, 128)
  let cycmag = cycleMagnitude(topdeltas, cycstart, cyclen)
  # height at the start of the first cycle, plus sum of all full cycles
  var part2 = toprocks[cycstart] + ((RockCountP2-cycstart) div cyclen) * cycmag
  # add the height changes of the last, incomplete cycle
  for i in 0..<((RockCountP2-cycstart) mod cyclen):
    part2 += ord(topdeltas[i+cycstart])
  echo("Part 2: ", part2)
