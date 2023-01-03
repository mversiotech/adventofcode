## Solution for https://adventofcode.com/2022/day/19
##
## I've modeled the harvest simulation as a state machine, where each state
## contains the remaining time, an inventory of available resources and a list
## of harvesting robots. Each state can transition in up to 5 next states: One
## for each robot that can be possibly build and one where nothing is build.
## The solutions can then be found by depth-first search in the directed graph
## representing the state machine.
## Since the whole process is rather expensive in terms of CPU time, but the
## solutions for the individual blueprints are independent of each other, I
## took this as an opportunity to play around with Nim's "parallel" feature.

import std/[strutils, tables, threadpool]
{.experimental: "parallel".}

const
  InputFile   = "../../input/day19.txt"
  TotalTimeP1 = 24
  TotalTimeP2 = 32
  SkipNone    = [false, false, false, false]

type
  Resource = enum
    Ore, Clay, Obsidian, Geode

  Blueprint = Table[Resource, array[4, int]]

  State = object
    timeLeft: int
    resources: array[4, int]
    robots: array[4, int]


func get(a: array[4, int], r: Resource): int =
  a[ord(r)]

func put(a: var array[4, int], r: Resource, n: int) =
  a[ord(r)] = n


func next(s: State): State =
  ## Returns a new state with the same inventory and robots as `s` but one
  ## minute less time left.
  var ns = State(timeLeft: s.timeLeft-1, robots: s.robots)
  for r in Ore..Geode:
    ns.resources.put(r, s.resources.get(r) + s.robots.get(r))
  return ns


func canBuildRobot(s: State, r: Resource, bp: Blueprint): bool =
  ## Returns true if a robot for harvesting `r` can be build with the resources
  ## in `s`.
  for res, cost in bp[r]:
    if s.resources[res] < cost:
      return false
  return true


func withRobot(s: State, r: Resource, bp: Blueprint): State =
  ## Returns a new state based on `s` that contains a new robot for harvesting
  ## `r`. The neccessary resources for building the robot will be taken out of
  ## the inventory of the new state.
  var ns = s
  ns.robots[ord(r)] += 1
  for res, cost in bp[r]:
    ns.resources[res] -= cost
  return ns


func maxPossible(s: State, r: Resource): int =
  ## Returns the maximum number of pieces of `r` that can possibly be harvested
  ## within the time remaining in `s` under optimal circumstances.
  let t = s.timeLeft
  return s.resources.get(r) + t * s.robots.get(r) + (t * (t-1)) div 2


func maxCost(bp: Blueprint, r: Resource): int =
  ## Returns the maximum number of pieces of `r` that is needed to build any
  ## robot according to Blueprint `bp`.
  var maxcost: int
  for robot, costs in bp:
    maxcost = max(maxcost, costs[ord(r)])
  return maxcost


proc geodeCount(s: State, bp: Blueprint, skip: array[4, bool], maxCount: int): int =
  ## Returns the maximum number of geodes that can be harvested given the
  ## current state `s` and building Blueprint `bp`. `skip` indicates which
  ## robots were available in the last time frame and should not be built again
  ## at this step. maxCount contains the current maximum number of harvested
  ## geodes and is used to quit suboptimal branches early.
  var
    maxCount = maxCount
    skipNext: array[4, bool]
  if s.timeLeft == 1:
    return s.resources.get(Geode) + s.robots.get(Geode)
  if s.maxPossible(Geode) <= maxCount:
    # Stop if we cannot top the maximum under any circumstances
    return 0 
  if s.maxPossible(Obsidian) < bp.maxCost(Obsidian):
    # As soon as we cannot build more Obsidian harvesting robots, the final
    # result is clear.
    return s.resources.get(Geode) + s.robots.get(Geode) * s.timeLeft
  let nextState = s.next()
  if s.canBuildRobot(Geode, bp):
    # Always prefer building a geode harvesting robot to all other options.
    return nextState.withRobot(Geode, bp).geodeCount(bp, SkipNone, maxCount)
  for res in Ore..Obsidian:
    if skip[ord(res)]:
      continue
    # Try building new robots, but only until we harvest as much of each
    # resource as we can possibly consume in a single step.
    if s.canBuildRobot(res, bp) and s.robots.get(res) < bp.maxCost(res):
      skipNext[ord(res)] = true
      let count = nextState.withRobot(res, bp).geodeCount(bp, SkipNone, maxCount)
      maxCount = max(count, maxCount)
  let count = nextState.geodeCount(bp, skipNext, maxCount)
  return max(count, maxCount)


func solvePart1(blueprints: seq[Blueprint]): int =
  let initState = State(timeLeft: TotalTimeP1, robots: [1, 0, 0, 0])
  var
    qlsum: int
    geodes = newSeq[int](len(blueprints))
  parallel:
    for i, bp in blueprints:
      geodes[i] = spawn initState.geodeCount(bp, SkipNone, 0)
  for i, bp in blueprints:
    qlsum += (i+1) * geodes[i]
  return qlsum


func solvePart2(blueprints: seq[Blueprint]): int =
  let initState = State(timeLeft: TotalTimeP2, robots: [1, 0, 0, 0])
  var
    prod = 1
    geodes: array[3, int]
  parallel:
    for i in 0..2:
      geodes[i] = spawn initState.geodeCount(blueprints[i], SkipNone, 0)
  for i in 0..2:
    prod *= geodes[i]
  return prod


func parseBlueprint(line: string): Blueprint =
  let parts = line.split(' ')
  if len(parts) != 32:
    raise newException(ValueError, "invalid line: " & line)
  var robots = initTable[Resource, array[4, int]]()
  robots[Ore] = [parts[6].parseInt(), 0, 0, 0]
  robots[Clay] = [parts[12].parseInt(), 0, 0, 0]
  robots[Obsidian] = [parts[18].parseInt(), parts[21].parseInt(), 0, 0]
  robots[Geode] = [parts[27].parseInt(), 0, parts[30].parseInt(), 0]
  return robots


proc readInput(filename: string): seq[Blueprint] =
  var blueprints: seq[Blueprint]
  let f = open(filename)
  try:
    var line: string
    while f.readLine(line):
      blueprints.add(parseBlueprint(line))
  finally:
    f.close()
  return blueprints
  

when isMainModule:
  let blueprints = readInput(InputFile)
  echo("Part 1: ", solvePart1(blueprints))
  echo("Part 2: ", solvePart2(blueprints))
