## Solution for https://adventofcode.com/2022/day/24
##
## I maintain a set of positions where the expedition can possibly be. At
## each time step, I add all valid adjacent positions to this set. Next, I move
## all blizzards. Then I prune the set of positions by removing all entries which
## coincide which one of the blizzards. The prozess ends as soon as the goal can
## be reached.
## Part 2 works exactly the same, but I switch start and goal positions inbetween
## each round.


import std/[sets, strutils]

const InputFile = "../../input/day24.txt"

type
  Vec2i = object
    x, y: int

  Blizzard = object
    pos, dir: Vec2i

  Valley = object
    start, goal: Vec2i
    extent: Vec2i
    blizzards: seq[Blizzard]
    tiles: seq[int] # Number of blizzards at each position


func occupation(valley: Valley, pos: Vec2i): int =
  ## Returns the number of blizzards that occopy `pos`.
  valley.tiles[pos.y * valley.extent.x + pos.x]


func incOccupation(valley: var Valley, pos: Vec2i) =
  ## Increases the number of blizzards that occopy `pos` by 1.
  inc(valley.tiles[pos.y * valley.extent.x + pos.x])


func decOccupation(valley: var Valley, pos: Vec2i) =
  ## Decreases the number of blizzards that occopy `pos` by 1.
  dec(valley.tiles[pos.y * valley.extent.x + pos.x])


func isValid(valley: Valley, pos: Vec2i): bool =
  ## Returns true if `pos` lies within the bounds of the `valley`.
  pos.x >= 0 and pos.y >= 0 and pos.x < valley.extent.x and pos.y < valley.extent.y


func swapGoal(valley: var Valley) =
  ## Swaps start and goal positions.
  let t = valley.start
  valley.start = valley.goal
  valley.goal = t


func moveBlizzards(valley: var Valley) =
  ## Moves each blizzard for one step, wrapping around at the valley borders.
  for i, b in valley.blizzards:
    var newPos = Vec2i(x: b.pos.x + b.dir.x, y: b.pos.y + b.dir.y)
    if newPos.x < 0:
      newPos.x = valley.extent.x - 1
    elif newPos.x >= valley.extent.x:
      newPos.x = 0
    if newPos.y < 0:
      newPos.y = valley.extent.y - 1
    elif newPos.y >= valley.extent.y:
      newPos.y = 0
    valley.decOccupation(b.pos)
    valley.incOccupation(newPos)
    valley.blizzards[i].pos = newPos


func minutesToGoal(valley: var Valley): int =
  ## Returns the fewest number of minutes to reach the goal.
  var elves = toHashSet([valley.start])
  for minute in 1..high(int):
    var spawns: HashSet[Vec2i]
    for elf in elves:
      if elf.x == valley.goal.x and abs(elf.y - valley.goal.y) == 1:
        return minute
      for vec in [Vec2i(x: 1), Vec2i(y: 1), Vec2i(x: -1), Vec2i(y: -1)]:
        let newPos = Vec2i(x: elf.x + vec.x, y: elf.y + vec.y)
        if not valley.isValid(newPos):
          continue
        spawns.incl(newPos)
    elves.incl(spawns)
    valley.moveBlizzards()
    var dead: HashSet[Vec2i]
    for elf in elves:
      if elf != valley.start and valley.occupation(elf) > 0:
        dead.incl(elf)
    elves.excl(dead)


func dirVec(dirChar: char): Vec2i =
  ## Returns the direction vector for the given input character.
  case dirChar
  of  '^':
    return Vec2i(y: -1)
  of 'v':
    return Vec2i(y: 1)
  of '<':
    return Vec2i(x: -1)
  of '>':
    return Vec2i(x: 1)
  else:
    raise newException(ValueError, "invalid character: " & $dirChar)


proc readValley(filename: string): Valley =
  ## Parses the input file.
  var valley: Valley
  let lines = readFile(filename).strip().split('\n')
  valley.extent = Vec2i(x: len(lines[0])-2, y: len(lines)-2)
  valley.start = Vec2i(x: lines[0].find('.')-1, y: -1)
  valley.goal = Vec2i(x: lines[^1].find('.')-1, y: valley.extent.y)
  valley.tiles = newSeq[int](valley.extent.x * valley.extent.y)
  for y in 1..valley.extent.y:
    for x in 1..valley.extent.x:
      let c = lines[y][x]
      if c != '.':
        let pos = Vec2i(x: x-1, y: y-1)
        valley.blizzards.add(Blizzard(pos: pos, dir: dirVec(c)))
        valley.incOccupation(pos)
  return valley


when isMainModule:
  var
    valley = readValley(InputFile)
    minutes = valley.minutesToGoal()
  echo("Part 1: ", minutes)
  valley.swapGoal()
  minutes += valley.minutesToGoal() - 1
  valley.swapGoal()
  minutes += valley.minutesToGoal() - 1
  echo("Part 2: ", minutes)