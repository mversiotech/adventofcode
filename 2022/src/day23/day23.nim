## Solution for https://adventofcode.com/2022/day/23
## 
## This is a straightforward simulation of the puzzle rules. Not particularily
## optimized, but a release build still executes both parts in 0.7s on my
## machine, which is good enough I think.

import std/[sets, tables]

const InputFile = "../../input/day23.txt"


type
  Vec2i = object
    x, y: int

  Direction = enum
    North, South, West, East


const
  EdgeVecs = {
    North: Vec2i(y: -1),
    South: Vec2i(y: 1),
    West: Vec2i(x: -1),
    East: Vec2i(x: 1),
  }.toTable()

  NeighborVecs = { 
    North: [ Vec2i(y: -1), Vec2i(x: -1, y: -1), Vec2i(x: 1, y: -1)],
    South: [ Vec2i(y: 1), Vec2i(x: -1, y: 1), Vec2i(x: 1, y: 1)],
    West: [ Vec2i(x: -1), Vec2i(x: -1, y: -1), Vec2i(x: -1, y: 1)],
    East: [ Vec2i(x: 1), Vec2i(x: 1, y: -1), Vec2i(x: 1, y: 1)]
  }.toTable()


func hasNeighbor(elf: Vec2i, allElves: HashSet[Vec2i]): bool =
  ## Returns true if the given `elf` has a neighbor in one of the eight positions
  ## adjacent to himself.
  for y in -1..1:
    for x in -1..1:
      if x != 0 or y != 0:
        if allElves.contains(Vec2i(x: elf.x + x, y: elf.y + y)):
          return true
  return false


func hasNeighborOnSide(elf: Vec2i, allElves: HashSet[Vec2i], side: Direction): bool =
  ## Returns true if the given `elf` has a neighbor in one of the three positions
  ## adjacent to himself on the given `side`.
  for vec in NeighborVecs[side]:
    let pos = Vec2i(x: elf.x + vec.x, y: elf.y + vec.y)
    if allElves.contains(pos):
      return true
  return false


func disperse(elves: var HashSet[Vec2i], firstDir: Direction): int =
  ## Disperses the `elves` according to puzzle rules. `firstDir` is the first
  ## direction considered for moving. disperse returns the number of elves
  ## who moved during this round.
  var 
    moves: int
    proposal = initTable[Vec2i, Vec2i]() # Maps elf to proposed position
    occupation = initCountTable[Vec2i]() # Records occupation count for each proposed position
  for elf in elves:
    if not elf.hasNeighbor(elves):
      continue
    for i in 0..3:
      let dir = Direction((ord(firstDir) + i) mod 4)
      if not elf.hasNeighborOnSide(elves, dir):
        let vec = EdgeVecs[dir]
        let pos = Vec2i(x: elf.x + vec.x, y: elf.y + vec.y)
        proposal[elf] = pos
        occupation.inc(pos)
        break
  for elf, pos in proposal:
    if occupation[pos] == 1:
      elves.excl(elf)
      elves.incl(pos)
      inc(moves)
  return moves


func extent(elves: HashSet[Vec2i]): Vec2i =
  ## Returns the extent of the bounding rectangle that contains all `elves`.
  var
    minx = high(int)
    miny = high(int)
    maxx = low(int)
    maxy = low(int)
  for elf in elves:
    minx = min(elf.x, minx)
    miny = min(elf.y, miny)
    maxx = max(elf.x, maxx)
    maxy = max(elf.y, maxy)
  return Vec2i(x: 1 + maxx - minx, y: 1 + maxy - miny)


proc readElves(filename: string): HashSet[Vec2i] =
    ## Parses the input file and returns a HashSet where each entry
    ## contains the position of an elf.
    var elves: HashSet[Vec2i]
    let f = open(filename)
    try:
      var
        line: string
        y: int
      while f.readLine(line):
        for x, c in line:
          if c == '#':
            elves.incl(Vec2i(x: x, y: y))
          elif c != '.':
            raise newException(ValueError, "invalid character: " & $c)
        inc(y)
      return elves
    finally:
      f.close()


when isMainModule: 
  var elves = readElves(InputFile)
  for round in 0..high(int):
    let firstDir = Direction(round mod 4)
    let moves = disperse(elves, firstDir)
    if round == 9:
      let rect = extent(elves)
      echo("Part 1: ", rect.x * rect.y - len(elves))
    if moves == 0:
      echo("Part 2: ", round+1)
      break