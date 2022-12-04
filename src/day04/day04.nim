## Solution for https://adventofcode.com/2022/day/4
##
## Today's puzzle is about ranges of integers which can overlap or be fully
## contained within another.

import std/strscans

const
  InputFile = "../../input/day04.txt"


type
  Range = object
    lower, upper: int


func contains(a, b: Range): bool =
  ## Returns true if a fully contains b
  return b.lower >= a.lower and b.upper <= a.upper


func overlaps(a, b: Range): bool =
  ## Returns true if a and b overlap
  return a.lower <= b.upper and a.upper >= b.lower


func parseLine(line: string): (Range, Range) =
  ## Parses one line of input data into a pair of ranges
  var a, b, c, d: int
  if not scanf(line, "$i-$i,$i-$i", a, b, c, d):
    raise newException(ValueError, "cannot parse " & line)
  if b < a or d < c:
    raise newException(ValueError, "invalid range in " & line)
  return ( Range(lower: a, upper: b), Range(lower: c, upper: d) )


proc processPairs(filename: string): (int, int) =
  ## Reads pairs of ranges from `filename`. The first return value is the
  ## number of pairs where one range fully contains the other. The second
  ## return value is the number of pairs where the two ranges overlap.
  let f = open(filename)
  try:
    var line: string
    while f.readLine(line):
      let pair = parseLine(line)
      if pair[0].contains(pair[1]) or pair[1].contains(pair[0]):
        inc(result[0])
      if pair[0].overlaps(pair[1]):
        inc(result[1])
  finally:
    close(f)


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
    let counts = processPairs(InputFile)
    echo("Part 1: ", counts[0])
    echo("Part 2: ", counts[1])
  except IOError:
    die("Cannot read " & InputFile)
  except ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
