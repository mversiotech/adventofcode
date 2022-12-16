## Solution for https://adventofcode.com/2022/day/16
##
## This puzzle was a lot harder to solve than the previous ones. I had to get
## some hints from Reddit before I knew how to tackle this. Here is an outline
## how the program works:
##
## 1.) Create an adjacency list from the input data. As a first optimization,
##     replace all valve names with an uint8 index while doing so.
## 2.) Use Floyd-Warshall to find the shortest path between every pair of
##     valves. The result is a complete graph with weighted egdes.
## 3.) Prune the graph so that only valves with non-zero flow rate remain.
## 4.) For the first part, use DFS to evaluate all sequences of closing valves
##     that are possible within the time limit and remember the maximum amount
##     of pressure relieved until the end.
##      -> Because valves are stored as integers and there are fewer than 64 of
##         them in total, an uint64 can be used as a bit set that stores the 
##         valves that were already visited. That's far more efficient than
##         passing around HashSets which is very important for the memoization
##         in part 2.
## 5.) The second part also uses DFS, but at every step it evaluates if it is
##     better to continue as in part 1, or to stop and let the elephant handle
##     the valves that weren't already closed. The key idea here is that the
##     elephant acts completly independent of the first person and cannot open
##     the same valves. This means that the elephant will take the same path
##     for each distinct set of valves opened by the first person, no matter in
##     which order they were opened. Consequently, the result of the elephant's
##     tour through the graph can be calculated once and then stored in a cache
##     for any set of previously opened valves. While this form of memoization
##     isn't strictly neccessary, it helps to speed up the program by an order
##     of magnitude.


import std/[strscans, strutils, tables]

const
  InputFile   = "../../input/day16.txt"
  ShortFormat = "Valve $w"
  LongFormat  = "Valve $w has flow rate=$i; $+ to $w $+"
  PathMax     = high(int) div 2
  TimeLimitP1 = 30
  TimeLimitP2 = 26


type
  NodeSet       = uint64
  AdjacencyList = Table[uint8, seq[uint8]]
  FlowMap       = Table[uint8, int]
  PathMap       = Table[uint8, Table[uint8, int]]

  Graph = object
    nodes: FlowMap
    edges: PathMap


func contains(s: NodeSet, n: uint8): bool =
  (s and (1'u64 shl n)) != 0


func incl(s: var NodeSet, n: uint8) =
  s = s or (1'u64 shl n)


func excl(s: var NodeSet, n: uint8) =
  s = s xor (1'u64 shl n)


proc dfs(
    graph: ref Graph, visited: var NodeSet,
    curNode: uint8, curRelief, timeLeft: int,
    elephant: bool, cache: var Table[NodeSet, int]): int =
  var maxRelief = curRelief
  for nextNode, dist in graph.edges[curNode]:
    let nextTime = timeLeft - dist - 1
    if not visited.contains(nextNode) and nextTime >= 0:
      visited.incl(nextNode)
      let nextRelief = curRelief + nextTime * graph.nodes[nextNode]
      let nextMax = dfs(graph, visited, nextNode, nextRelief, nextTime, elephant, cache)
      maxRelief = max(maxRelief, nextMax)
      visited.excl(nextNode)
  if elephant:
    if not cache.contains(visited):
      cache[visited] = dfs(graph, visited, 0, 0, TimeLimitP2, false, cache)
    maxRelief = max(maxRelief, curRelief + cache[visited])
  return maxRelief


func findShortestPaths(adjacency: AdjacencyList): PathMap =
  var pathMap = initTable[uint8, Table[uint8, int]]()
  for nfrom in adjacency.keys():
    pathMap[nfrom] = initTable[uint8, int]()
    for nto in adjacency.keys():
      if nfrom != nto:
        pathMap[nfrom][nto] = PathMax
  for nfrom, tunnels in adjacency:
    for nto in tunnels:
      pathMap[nfrom][nto] = 1
  for k in adjacency.keys():
    for i in adjacency.keys():
      if i == k:
        continue
      for j in adjacency.keys():
        if j != i and j != k:
          pathMap[i][j] = min(pathMap[i][j], pathMap[i][k] + pathMap[k][j])
  return pathMap


func pruned(pathMap: PathMap, flowRates: FlowMap): PathMap =
  var prunedMap = initTable[uint8, Table[uint8, int]]()
  prunedMap[0] = initTable[uint8, int]()
  var nonzero = @[0'u8]
  for n in flowRates.keys():
    nonzero.add(n)
  for nfrom in nonzero:
    prunedMap[nfrom] = initTable[uint8, int]()
    for nto in nonzero:
      if nto != 0 and nfrom != nto:
        prunedMap[nfrom][nto] = pathMap[nfrom][nto]
  return prunedMap


proc readInput(filename: string): ref Graph =
  var
    nameMap = initTable[string, uint8]()
    flowMap = initTable[uint8, int]()
    adjacency = initTable[uint8, seq[uint8]]()
  let lines = readFile(filename).strip().split('\n')
  for i, l in lines:
    var name: string
    if not scanf(l, ShortFormat, name):
      raise newException(ValueError, "cannot parse \"" & l & "\"")
    nameMap[name] = uint8(i)
  for l in lines:
    var
      name, skip1, skip2, tunnels: string
      flow: int
    if not scanf(l, LongFormat, name, flow, skip1, skip2, tunnels):
      raise newException(ValueError, "cannot parse \"" & l & "\"")
    if flow > 0:
      flowMap[nameMap[name]] = flow
    let next = tunnels.split(", ")
    adjacency[nameMap[name]] = newSeq[uint8](len(next))
    for i, t in next:
      adjacency[nameMap[name]][i] = nameMap[t]
  var graph: ref Graph
  new(graph)
  graph.nodes = flowMap
  graph.edges = findShortestPaths(adjacency).pruned(flowMap)
  return graph


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
    let graph = readInput(InputFile)
    var
      visited: NodeSet
      cache = initTable[NodeSet, int]()
    var relief = dfs(graph, visited, 0, 0, TimeLimitP1, false, cache)
    echo("Part 1: ", relief)
    visited = 0
    relief = dfs(graph, visited, 0, 0, TimeLimitP2, true, cache)
    echo("Part 2: ", relief)
  except IOError:
    die("cannot read " & InputFile)
  except ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
