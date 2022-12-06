## Solution for https://adventofcode.com/2022/day/6
##
## This one was easy: Find a substring of a given length n that consists
## of n distinct characters.


const
  InputFile = "../../input/day06.txt"


func findMarkerEnd(s: string, n: Natural): int =
  for i in n-1..<len(s):
    var cs: set[char]
    for j in 0..<n:
      cs.incl(s[i-j])
    if cs.card() == n:
      return i
  return -1


if isMainModule:
  let input = readFile(InputFile)
  echo("Part 1: ", findMarkerEnd(input, 4)+1)
  echo("Part 2: ", findMarkerEnd(input, 14)+1)

