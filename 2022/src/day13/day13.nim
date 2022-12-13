## Solution for https://adventofcode.com/2022/day/13
##
## Thankfully the input consists of valid JSON arrays. I wrote several
## comparison functions that implement the puzzle specification and left the
## rest to the standard library.

import std/[algorithm, json, strutils]

const InputFile = "../../input/day13.txt"


func compareInts(left, right: JsonNode): int =
  ## Three-way comparison between two nodes of kind JInt
  let l = left.getInt()
  let r = right.getInt()
  return if l < r: -1 elif l > r: 1 else: 0


# Forward declare compareNodes
func compareNodes(left, right: JsonNode): int


func compareArrays(left, right: JsonNode): int =
  ## Three-way comparison between two nodes of kind JArray
  let lenl = len(left)
  let lenr = len(right)
  for i in 0..<min(lenl, lenr):
    let cmp = compareNodes(left[i], right[i])
    if cmp != 0:
      return cmp
  return if lenl < lenr: -1 elif lenl > lenr: 1 else: 0


func compareNodes(left, right: JsonNode): int =
  ## Three-way comparison between two nodes of either kind JInt or JArray.
  if left.kind == JInt and right.kind == JInt:
    return compareInts(left, right)
  elif left.kind == JArray and right.kind == JArray:
    return compareArrays(left, right)
  if left.kind == JInt:
    var newleft = newJArray()
    newleft.add(left)
    return compareArrays(newleft, right)
  else:
    var newright = newJArray()
    newright.add(right)
    return compareArrays(left, newright)
    

proc readArrays(filename: string): seq[JsonNode] =
  ## Parses all non-empty lines in `filename` into a sequence of JsonNodes
  var
    line: string
    nodes: seq[JsonNode]
  let f = open(filename)
  try:
    while f.readLine(line):
      if line.isEmptyOrWhitespace():
        continue
      let node = parseJson(line)
      if node.kind != JArray:
        raise newException(ValueError, "not an array: " & line)
      nodes.add(node)
  finally:
    f.close()
  return nodes


func orderedPairCount(nodes: seq[JsonNode]): int =
  ## Puzzle part 1
  var count: int
  for i in countup(0, len(nodes)-2, 2):
    if compareNodes(nodes[i], nodes[i+1]) < 0:
      count += i div 2 + 1
  return count


proc decoderKey(nodes: var seq[JsonNode]): int =
  ## Puzzle part 2 (modifies `nodes`)
  let dividers = [ parseJson("[[2]]"), parseJson("[[6]]") ]
  nodes.add(dividers)
  sort(nodes, compareNodes)
  var key = 1
  for i, n in nodes:
    if n == dividers[0] or n == dividers[1]:
      key *= i+1
  return key
    

proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
    var nodes = readArrays(InputFile)
    echo("Part 1: ", orderedPairCount(nodes))
    echo("Part 2: ", decoderKey(nodes))
  except IOError:
    die("cannot read " & InputFile)
  except ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
