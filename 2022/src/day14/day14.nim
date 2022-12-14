## Solution for https://adventofcode.com/2022/day/14
##
## I suppose this could run a lot faster if I had used a seq[bool] grid instead
## of a HashSet. I might try this later on, but right now I'm happy enough with
## the result.

import std/[sets, strutils]
  
type
  Point = object
    x, y: int

  Cave = object
    floor: int
    blocked: HashSet[Point]

const
  InputFile = "../../input/day14.txt"

  SandSource = Point(x: 500, y: 0)


func markRocks(cave: var Cave, p1, p2: Point) =
  ## Marks all tiles on an axis-aligned line segment with the end points `p1`
  ## and `p2` as blocked.
  if p1.x == p2.x:
    for y in min(p1.y, p2.y)..max(p1.y, p2.y):
      cave.blocked.incl(Point(x: p1.x, y: y))
  else:
    for x in min(p1.x, p2.x)..max(p1.x, p2.x):
      cave.blocked.incl(Point(x: x, y: p1.y))


func parseLine(line: string): seq[Point] =
  ## Parses one line of input into a sequence of points
  var points: seq[Point]
  for pt in line.split(" -> "):
    let xy = pt.split(',')
    if len(xy) != 2:
      raise newException(ValueError, "invalid point: " & pt)
    points.add(Point(x: xy[0].parseInt(), y: xy[1].parseInt()))
  if len(points) < 2:
    raise newException(ValueError, "invalid line: " & line)
  return points


proc readCave(filename: string): Cave =
  ## Reads all lines of rock from `filename` and determines the height
  ## of the floor.
  let f = open(filename)
  try:
    var
      cave: Cave
      line: string
    while f.readLine(line):
      let points = parseLine(line)
      for i in 0..<len(points):
        cave.floor = max(cave.floor, points[i].y+2)
        if i > 0:
          cave.markRocks(points[i-1], points[i])
    return cave
  finally:
    close(f)


func dropSand(cave: var Cave): Point =
  ## Drops one unit of sand into the cave. Returns the position at which the
  ## unit of sand comes to rest.
  var sand = SandSource
  while true:
    var moved = false
    for vec in [(0, 1), (-1, 1), (1, 1)]:
      let p = Point(x: sand.x + vec[0], y: sand.y + vec[1])
      if p.y < cave.floor and not cave.blocked.contains(p):
        sand = p
        moved = true
        break
    if not moved:
      cave.blocked.incl(sand)
      return sand
    

proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
    var
      units = 0
      onfloor = false
      cave = readCave(InputFile)
    while true:
      let p = cave.dropSand()
      if not onfloor and p.y == cave.floor-1:
        onfloor = true
        echo("Part 1: ", units)
      elif p == SandSource:
        echo("Part 2: ", units+1)
        break
      inc(units)
  except IOError:
    die("cannot read " & InputFile)
  except ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
