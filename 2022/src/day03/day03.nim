## Solution for https://adventofcode.com/2022/day/3

const
  InputFile = "../../input/day03.txt"


func itemIndex(item: char): int =
  if item >= 'a' and item <= 'z':
    return ord(item) - ord('a')
  if item >= 'A' and item <= 'Z':
    return ord(item) - ord('A') + 26
  raise newException(ValueError, "invalid character \"" & item & "\"")


func duplicatePriority(items: string): int =
  var headItems: array[52, bool]
  let head = items[0..len(items) div 2 - 1]
  for item in head:
    headItems[itemIndex(item)] = true
  let tail = items[len(items) div 2..^1]
  for item in tail:
    let i = itemIndex(item)
    if headItems[i]:
      return i + 1
  raise newException(KeyError, "no duplicate item found in " & items)


func badgePriority(group: array[3, string]): int =
  var itemSet: array[52, uint8]
  for item in group[0]:
    let i = itemIndex(item)
    itemSet[i] = itemSet[i] or 1
  for item in group[1]:
    let i = itemIndex(item)
    itemSet[i] = itemSet[i] or 2
  for item in group[2]:
    let i = itemIndex(item)
    if itemSet[i] == (1 or 2):
      return i + 1
  raise newException(KeyError, "no common item in group")


proc findPriorities(filename: string): (int, int) =
  let f = open(filename)
  try:
    var 
      group: array[3, string]
      i: int
    while f.readLine(group[i]):
      result[0] += duplicatePriority(group[i])
      if i == 2:
        result[1] += badgePriority(group)
      i = (i + 1) mod 3
  finally:
    close(f)


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
    let p = findPriorities(InputFile)
    echo("Part 1: ", p[0])
    echo("Part 2: ", p[1])
  except IOError:
    die("Cannot read " & InputFile)
  except ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
