## Solution for https://adventofcode.com/2022/day/15
##
## Notes on part 1: The area around each sensor has the shape of a rhombus with
## 45 degree angles. Intersection of this shape with a horizontal line yields a
## line segment. The result we are looking for is simply the sum of all grid
## cells touched by any such line segment. The sensor areas can overlap, so we
## must take care to count each cell only once.
##
## Notes on part 2: There is only one valid position for the missing beacon.
## That means that every other cell in the search area must be covered by at
## least one beacon. The position we are looking for must therefore be exactly
## one step out of range of 2-4 sensors. By intersecting the line segments
## around the border of each signal area with those of each nearby other signal,
## we can build a list of candidate points. The wanted result is the only one of
## those points that does not lie within any sensor's range.

import std/[algorithm, strscans]

const
  InputFile     = "../../input/day15.txt"
  InputFormat   = "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i"
  CutRow        = 2000000
  MaxCoordinate = 4000000

type
  Point = object
    x, y: int

  HLine = object
    ## A horizontal line from `x1` to `x2` where x1 <= x2
    x1, x2: int

  Sensor = object
    ## Represents a sensor located at `center` with `radius` being the
    ## Manhattan distance to the next beacon.
    center: Point
    radius: int


func manhattanDistance(p1, p2: Point): int =
  abs(p1.x - p2.x) + abs(p1.y - p2.y)


func length(l: HLine): int =
  l.x2 - l.x1 + 1


func overlaps(a, b: HLine): bool =
  return a.x1 <= b.x2 and a.x2 >= b.x1


func merged(a, b: HLine): HLine =
  ## Returns a HLine with the maximum extent of a and b
  HLine(x1: min(a.x1, b.x1), x2: max(a.x2, b.x2))


func compareTo(a, b: HLine): int =
  ## Compares two horizontal lines. Sort order: left to right.
  if a.x1 < b.x1: -1
  elif a.x1 > b.x1: 1
  elif a.x2 < b.x2: -1
  elif a.x2 > b.x2: 1
  else: 0


func cutAtRow(s: Sensor, row: int): (HLine, bool) =
  ## Returns a horizontal cut through the area around sensor `s`. The second
  ## return value will be false if the given `row` is out of range for `s`.
  var l: HLine
  let dy = abs(s.center.y - row)
  if dy > s.radius:
    return (l, false)
  let w = s.radius - dy
  l.x1 = s.center.x - w
  l.x2 = s.center.x + w
  return (l, true)


func combinedLength(lines: seq[HLine]): int =
  ## Calculates the sum of the lengths of all given `lines` so that positions
  ## where two or more lines overlap are counted only once.
  let lines = sorted(lines, compareTo)
  var
    sum = 0
    current = lines[0]
  for i in 1..<len(lines):
    if current.overlaps(lines[i]):
      current = merged(current, lines[i])
    else:
      sum += current.length()
      current = lines[i]
  sum += current.length()
  return sum


func pointsOnRow(sensors: seq[Sensor], row: int): int =
  ## Implements part 1 of the puzzle
  var lines: seq[HLine]
  for s in sensors:
    let (l, ok) = s.cutAtRow(row)
    if ok:
      lines.add(l)
  return combinedLength(lines)-1


func outerBorder(s: Sensor): array[4, Point] =
  ## Returns the corner points of the four lines right outside the border of
  ## the sensor's range. The order of the points is left, top, bottom, right.
  let top = Point(x: s.center.x, y: s.center.y - s.radius - 1)
  let bottom = Point(x: s.center.x, y: s.center.y + s.radius + 1)
  let left = Point(x: s.center.x - s.radius - 1, y: s.center.y)
  let right = Point(x: s.center.x + s.radius + 1, y: s.center.y)
  return [left, top, right, bottom]


func lineIntersection(a, b, c, d: Point): (Point, bool) =
  ## Calculates the intersection, if any, between the line segments `|ab|` and
  ## `|cd|`. If there is no unique solution, the second return value will be
  ## false. The exact result will be truncated to integer coordinates.
  var inter: Point
  let denom = (a.x - b.x) * (c.y - d.y) - (a.y - b.y) * (c.x - d.x)
  if denom == 0:
    return (inter, false)
  let t = ((a.x - c.x) * (c.y - d.y) - (a.y - c.y) * (c.x - d.x)) / denom
  let u = ((a.x - c.x) * (a.y - b.y) - (a.y - c.y) * (a.x - b.x)) / denom
  if t < 0 or t > 1 or u < 0 or u > 1:
    return (inter, false)
  inter.x = a.x + int(t * float(b.x - a.x))
  inter.y = a.y + int(t * float(b.y - a.y))
  return (inter, true)


func inRangeOfAny(p: Point, sensors: seq[Sensor]): bool =
  ## Returns true if the area around any sensor in `sensors` contains the
  ## point `p`.
  for s in sensors:
    if manhattanDistance(s.center, p) <= s.radius:
      return true
  return false


func borderIntersections(a, b: Sensor): seq[Point] =
  ## Returns a sequence of all intersection points between the line segments
  ## around the borders of of `a` and `b`.
  var points: seq[Point]
  if manhattanDistance(a.center, b.center) > a.radius + b.radius + 1:
    return points
  let aob = a.outerBorder()
  let bob = b.outerBorder()
  for i in 0..3:
    for j in 0..3:
      let (inter, ok) = lineIntersection(aob[i], aob[(i+1) mod 4],
                                         bob[j], bob[(j+1) mod 4])
      if ok:
        points.add(inter)
  return points


func tuningFrequency(sensors: seq[Sensor]): int =
  ## Implements part 2 of the puzzle
  for i in 0..<len(sensors):
    for j in i+1..<len(sensors):
      for p in borderIntersections(sensors[i], sensors[j]):
        if p.x <= 0 or p.y <= 0 or p.x >= MaxCoordinate or p.y >= MaxCoordinate:
          continue
        if not p.inRangeOfAny(sensors):
          return p.x * MaxCoordinate + p.y
  raise newException(ValueError, "no beacon position found")


proc readSensors(filename: string): seq[Sensor] =
  ## Parses the input data into a sequence of sensors.
  var
    s, b: Point
    line: string
    sensors: seq[Sensor]
  let f = open(filename)
  try:
    while f.readLine(line):
      if not scanf(line, InputFormat, s.x, s.y, b.x, b.y):
        raise newException(ValueError, "cannot parse \"" & line & "\"")
      sensors.add(Sensor(center: s, radius: manhattanDistance(s, b)))
  finally:
    close(f)
  return sensors


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
    let sensors = readSensors(InputFile)
    echo("Part 1: ", pointsOnRow(sensors, CutRow))
    echo("Part 2: ", tuningFrequency(sensors))
  except IOError:
    die("cannot read " & InputFile)
  except ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
