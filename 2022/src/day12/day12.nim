## Solution for https://adventofcode.com/2022/day/12
##
## Use breadth-first search to find paths between squares of a grid. By
## searching backwards from the goal square we can use the same method for both
## parts of the puzzle.
import std/[deques, strutils, sugar, tables]

const InputFile = "../../input/day12.txt"

type Point = object
  x, y: int32


func contains(hm: seq[string], p: Point): bool =
  ## Checks if `p` lies within the bounds of `hm`
  return p.y >= 0 and p.y < len(hm) and p.x >= 0 and p.x < len(hm[p.y])


func heightAt(hm: seq[string], p: Point): int =
  ## Returns the integral height at `p`
  return ord(hm[p.y][p.x])


func pathLength(hm: seq[string], start: Point, isGoal: (Point) -> bool): int =
  ## Returns the length of the shortest path from `start` to the first point
  ## that satisfies the condition `isGoal`. If no such point exists in `hm`,
  ## pathLength returns -1.
  var
    found: bool
    current: Point
    frontier: Deque[Point]
    cameFrom = initTable[Point, Point]()
  frontier.addLast(start)
  while len(frontier) > 0:
    current = frontier.popFirst()
    if isGoal(current):
      found = true
      break
    for v in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
      let nb = Point(x: current.x + int32(v[0]), y: current.y + int32(v[1]))
      if hm.contains(nb) and not cameFrom.contains(nb):
        if hm.heightAt(current) - hm.heightAt(nb) <= 1:
          frontier.addLast(nb)
          cameFrom[nb] = current
  if not found:
    return -1
  while current != start:
    current = cameFrom[current]
    inc(result)


proc readHeightmap(filename: string): (seq[string], Point, Point) =
  ## Returns a heightmap as a sequence of strings, the coordinates of the
  ## starting position and the coordinates of the goal.
  var start, goal: Point
  var hm = readFile(filename).split('\n')
  for y, l in hm:
    for x, c in l:
      if c == 'S':
        start = Point(x: int32(x), y: int32(y))
        hm[y][x] = 'a'
      elif c == 'E':
        goal = Point(x: int32(x), y: int32(y))
        hm[y][x] = 'z'
  return (hm, start, goal)


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
    let (hm, start, goal) = readHeightmap(InputFile)
    echo("Part 1: ", pathLength(hm, goal, (p) => p == start))
    echo("Part 2: ", pathLength(hm, goal, (p) => hm.heightAt(p) == ord('a')))
  except IOError:
    die("cannot read " & InputFile)
  except ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
