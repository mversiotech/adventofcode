## Solution for https://adventofcode.com/2022/day/22
## 
## This - part 2 in particular - was by far the hardest puzzle this year. I did
## not want to create a hard-coded solution, so this took me quite some time.
## Here is how it works:
## 1. Since a cube has 6 square faces, and the cubes in the puzzle are covered
##    by regular tiles, the edge length of a cube defined by n tiles must be
##    sqrt(n / 6). Using this information we can jump between neighboring faces
##    in the input data.
## 2. The cube's orientation in space is undetermined and does not matter.
##    I arbitrarily define the starting point, i.e. the first tile in the input 
##    as the leftmost tile of the far back row of the top face of the cube. In
##    other words, the first face will always be defined as the one on the top
##    side of the cube.
## 3. Faces that are connected in the input data are also connected in 3D. If
##    we find another face directly below the first one, it must be the front
##    face. This means we can traverse the input and label faces that we find
##    as we go. (see findCubeFaces)
## 4. The order of the edges of each face can be determined by looking at the
##    edge through which it was "discovered".
## 5. With the full connectivity between faces discovered, wrapping to another
##    face can be done by looking at the edges of the both faces. The new
##    direction is simply the one pointing away from the target edge. The new
##    position can be found by taking the face-local coordinates and rotating
##    them by the same amount that the direction changed, i.e. a multiple of
##    90 degrees.

import std/[deques, math, parseutils, strutils, tables]
import vec2i

const InputFile = "../../input/day22.txt"

type
  Direction = enum
    East, South, West, North

  FaceName = enum
    Left, Right, Top, Bottom, Front, Back

  Rotation = enum
    CW, CCW

  ActionKind = enum
    Move, Turn

  Action = object  
    case kind: ActionKind
    of Move:  steps: int
    of Turn:  rotate: Rotation

  Tile = enum
    Floor, Wall

  StepFunc = enum
    Flat, Cubic

  CubeFace = object
    origin: Vec2i
    edges: array[4, FaceName]

  Player = object
    pos: Vec2i
    dir: Direction

  World = object
    size: Vec2i                           # Dimensions of the 2D world map
    cubeSize: int                         # Edge length of the 3D cube
    cubeFaces: Table[FaceName, CubeFace]  # Filled in by findCubeFaces
    map: Table[Vec2i, Tile]               # Raw map data with 2D positions


# Connectivity between cube faces. Edges are ordered clockwise.
# For the top face, we arbitrarily define that the edges are
# ordered east - south - west - north.
const Adjacency = {
  Left:   [Front, Bottom, Back, Top],
  Right:  [Bottom, Front, Top, Back],
  Top:    [Right, Front, Left, Back],
  Bottom: [Right, Back, Left, Front],
  Front:  [Right, Bottom, Left, Top],
  Back:   [Left, Bottom, Right, Top],
}.toTable()


func adjacencyIndex(face, edge: FaceName): int =
  ## Returns the index of the `edge` on the given `face`
  ## in the Adjacency matrix.
  for i, e in Adjacency[face]:
    if e == edge:
      return i
  raise newException(KeyError, "no such edge")


func findCubeFaces(world: var World) =
  ## Finds the origins and edges of all cube faces except the top face, which
  ## is assumed to exist.
  let
    topOrigin = world.cubeFaces[Top].origin
    faceSteps = [(world.cubeSize, 0), (0, world.cubeSize), (-world.cubeSize, 0), (0, -world.cubeSize)]
  var 
    checkFaces = initDeque[FaceName]()
    origins = { topOrigin: Top }.toTable()
  checkFaces.addLast(Top)
  while len(world.cubeFaces) < 6 and len(checkFaces) > 0:
    let
      curFace = checkFaces.popFirst()
      curOrigin = world.cubeFaces[curFace].origin
    for i, vec in faceSteps:
      let nextOrigin = curOrigin + vec
      if not world.map.contains(nextOrigin) or origins.contains(nextOrigin):
        continue
      # If we got here, we have found the origin point of a new face.
      # We can tell which face it is by looking at the edge through
      # which we came here. The edges of each face are always the same,
      # but we still need to find out in which order they appear.
      let nextFace = world.cubeFaces[curFace].edges[i]
      world.cubeFaces[nextFace] = CubeFace(origin: nextOrigin)
      origins[nextOrigin] = nextFace
      let
        # Opposite of where we came from. If we went east, we are now
        # on the western edge of nextFace.
        startEdge = (i + 2) mod 4 
        edgeOffset = adjacencyIndex(nextFace, curFace)
      for j in 0..3:
        world.cubeFaces[nextFace].edges[(startEdge + j) mod 4] = Adjacency[nextFace][(edgeOffset + j) mod 4]
      checkFaces.addLast(nextFace)


func globalToFace(world: World, global: Vec2i): (FaceName, Vec2i) =
  ## Translates global coordinates to face-local coordinates and
  ## returns the name of the face on which they lie.
  let origin = (global div world.cubeSize) * world.cubeSize
  for name, face in world.cubeFaces:
    if origin == face.origin:
      return (name, (global mod world.cubeSize))
  raise newException(KeyError, "invalid coordinates")


func flatStep(player: Player, world: World): (Vec2i, Direction) =
  ## Part 1: Step through the flat map and wrap around at the edges.
  let vecs = [ (1, 0), (0, 1), (-1, 0), (0, -1)]
  var newPos = player.pos
  while true:
    newPos = newPos + vecs[ord(player.dir)] + world.size
    newPos.x = newPos.x mod world.size.x
    newPos.y = newPos.y mod world.size.y
    if world.map.contains(newPos):
      return (newPos, player.dir)


func cubicStep(player: Player, world: World): (Vec2i, Direction) =
  ## Part 2: Step around the cube's surface and wrap around to other
  ## faces.
  let vecs = [ (1, 0), (0, 1), (-1, 0), (0, -1)]
  let nextPos = player.pos + vecs[ord(player.dir)]
  # Simple case: we stay on the same face
  if world.map.contains(nextPos):
    return (nextPos, player.dir)
  var
    (curFace, localPos) = world.globalToFace(player.pos)
    newFace = world.cubeFaces[curFace].edges[ord(player.dir)]
    # The new direction vector points away from the edge we are moving to
    newDir = Direction((world.cubeFaces[newFace].edges.find(curFace) + 2) mod 4)
    rotSteps = (ord(newDir) - ord(player.dir) + 4) mod 4
  # Wrap around to the other side of the cube face
  localPos = (localPos + vecs[ord(player.dir)] + (world.cubeSize, world.cubeSize)) mod world.cubeSize
  # Now rotate until we are on the correct edge
  for i in 0..<rotSteps:
    let lp = localPos
    localPos.x = world.cubeSize - lp.y - 1
    localPos.y = lp.x
  # Translate back into global coordinates
  let newPos = world.cubeFaces[newFace].origin + localPos
  return (newPos, newDir)


func step(player: Player, world: World, stepFunc: StepFunc): (Vec2i, Direction) =
  ## Take one step from the current player position into the player direction.
  ## The wrap behavior (part 1 = Flat, part 2 = Cubic) is determined by `stepFunc`.
  ## Neither step function checks whether the new position is blocked by a wall.
  if stepFunc == Flat:
    flatStep(player, world)
  else:
    cubicStep(player, world)


func executeAction(player: var Player, action: Action, world: World, stepFunc: StepFunc) =
  ## Execute the given `action`. This can either be a clockwise or counter-clockwise turn,
  ## or a number of steps into the current direction of the `player`.
  if action.kind == Turn:
    if action.rotate == CW:
      player.dir = Direction((ord(player.dir)+1) mod 4)
    else:
      player.dir = Direction((ord(player.dir)+3) mod 4)
    return
  for i in 0..<action.steps:
    let (nextPos, nextDir) = player.step(world, stepFunc)
    if world.map[nextPos] == Wall:
      break
    player.pos = nextPos
    player.dir = nextDir


func password(player: Player): int =
  ## Puzzle solution for either part.
  1000 * (player.pos.y + 1) + 4 * (player.pos.x + 1) + ord(player.dir)


func parseActions(line: string): seq[Action] =
  ## Parse the final line of the input into a sequence of Actions.
  var
    actions = newSeq[Action]()
    s = line
  while len(s) > 0:
    if s[0] == 'L' or s[0] == 'R':
      actions.add(Action(kind: Turn, rotate: if s[0] == 'L': CCW else: CW))
      s = s[1..^1]
      continue
    var steps: int
    let n = s.parseInt(steps)
    if steps < 1:
      raise newException(ValueError, "invalid number of steps")
    actions.add(Action(kind: Move, steps: steps))
    s = s[n..^1]
  return actions


proc readInput(filename: string): (World, seq[Action]) =
  ## Read the input file and create a new `World`. The player
  ## starting position will also be used as origin of the top
  ## face. The other cube faces have to be located using 
  ## `findCubeFaces`.
  let lines = readFile(filename).split('\n')
  assert(len(lines) >= 4 and lines[^3].isEmptyOrWhitespace())
  var 
    world: World
    haveStart = false
  for y, row in lines[0..^4]:
    world.size.x = max(world.size.x, len(row))
    for x, c in row:
      let pos: Vec2i = (x, y)
      case c
      of '.':
        world.map[pos] = Floor
        if not haveStart:
          world.cubeFaces = initTable[FaceName, CubeFace]()
          world.cubeFaces[Top] = CubeFace(origin: pos, edges: Adjacency[Top])
          haveStart = true
      of '#':
        world.map[pos] = Wall
      of ' ':
        discard
      else:
        raise newException(ValueError, "invalid character in map: " & c)
  world.size.y = len(lines)-3
  world.cubeSize = int(math.sqrt(len(world.map) / 6))
  return (world, parseActions(lines[^2]))


when isMainModule:
  var (world, actions) = readInput(InputFile)
  world.findCubeFaces()
  var
    flatPlayer = Player(pos: world.cubeFaces[Top].origin, dir: East)
    cubicPlayer = flatPlayer
  for a in actions:
    flatPlayer.executeAction(a, world, Flat)
    cubicPlayer.executeAction(a, world, Cubic)
  echo("Part 1: ", flatPlayer.password())
  echo("Part 2: ", cubicPlayer.password())