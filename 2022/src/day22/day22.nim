## Solution for https://adventofcode.com/2022/day/22

import std/strutils

const InputFile = "/tmp/input.txt"

type
  Direction = enum
    East, South, West, North

  Rotation = enum
    CW, CCW

  ActionKind = enum
    Move, Turn

  Action = object  
    case kind: ActionKind
    of Move:  steps: uint
    of Turn:  rotate: Rotation

  Tile = enum
    Empty, Floor, Wall

  Point = object
    x, y: int

  Player = object
    pos: Point
    dir: Direction

  World = object
    player: Player
    map: seq[string]


func rotate(dir: Direction, rot: Rotation): Direction =
  if rot == CW:
    Direction((ord(dir) + 1) mod 4)
  else:
    Direction((ord(dir) + 3) mod 4)


func toTile(c: char): Tile =
  case c
  of ' ':
    Empty
  of '.':
    Floor
  of '#':
    Wall
  else:
    raise newException(ValueError, "invalid tile " & c)


func nextTile(world: World, p: Point, dir: Direction): (Tile, Point) =
  var
    x = p.x
    y = p.y
  let row = world.map[p.y]
  case dir
  of North:
    while true:
      y = if y > 0: y - 1 else: len(world.map)-1
      if p.x < len(world.map[y]):
        break
  of East:
    x = (p.x + 1) mod len(row)
  of South:
    while true:
      y = (y + 1) mod len(world.map)
      if p.x < len(world.map[y]):
        break
  of West:
    x = if p.x == 0: len(row)-1 else: p.x - 1
  return (world.map[y][x].toTile(), Point(x: x, y: y))


func execute(world: var World, action: Action) =
  if action.kind == Turn:
    world.player.dir = world.player.dir.rotate(action.rotate)
    return
  for i in 0..<action.steps:
    var pos = world.player.pos
    while true:
      let (tile, next) = world.nextTile(pos, world.player.dir)
      pos = next
      if tile == Empty:
        continue
      elif tile == Wall:
        return
      else:
        break
    world.player.pos = pos


func password(world: World): int =
  1000 * (world.player.pos.y + 1) + 4 * (world.player.pos.x + 1) + ord(world.player.dir)

func parseActions(line: string): seq[Action] =
  var
    actions = newSeq[Action]()
    base = 0
  for cur in 0..<len(line):
    let c = line[cur]
    if c >= '0' and c <= '9':
      continue
    elif c == 'L' or c == 'R':
      if base != cur:
        let steps = line[base..cur-1].parseUInt()
        actions.add(Action(kind: Move, steps: steps))
      actions.add(Action(kind: Turn, rotate: if c == 'R': CW else: CCW))
      base = cur + 1
    else:
      raise newException(ValueError, "invalid character: " & c)
  if base < len(line):
    let steps = line[base..^1].parseUInt()
    actions.add(Action(kind: Move, steps: steps))
  return actions


proc readInput(filename: string): (World, seq[Action]) =
  var world: World
  let lines = readFile(filename).split('\n')
  assert(len(lines) >= 4 and lines[^3].isEmptyOrWhitespace())
  world.map = lines[0..^4]
  for x, c in lines[0]:
    if c.toTile() == Floor:
      world.player = Player(pos: Point(x: x, y: 0), dir: East)
      break
  return (world, parseActions(lines[^2]))


when isMainModule:
  var (world, actions) = readInput(InputFile)
  for a in actions:
    world.execute(a)
  echo("Password: ", world.password())
   
