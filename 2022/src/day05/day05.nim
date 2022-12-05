## Solution for https://adventofcode.com/2022/day/5
##
## Today's puzzle is ostensibly about manipulating stacks, but I have found that
## the main difficulty lies in parsing the input file. I have tried to write a
## halfway decent parser that does not simply crash and burn when fed invalid
## input. Lessons learned for today: Nim really likes to create copies of
## sequences, whether you want it or not.

import std/[algorithm, strscans, strutils]


const
  InputFile = "../../input/day05.txt"


func isCrates(line: string, nstacks: Natural): bool =
  ## Checks if `line` matches the format expected for a horizontal
  ## cut through `nstacks` stacks of crates.
  if len(line) != (nstacks * 4) - 1:
    return false
  for i in 0..<nstacks:
    let n = i * 4
    if line[n..n+2] != "   ":
      if line[n] != '[' or line[n+1] < 'A' or line[n+1] > 'Z' or line[n+2] != ']':
        return false
    if n < len(line)-3 and line[n+3] != ' ':
      return false
  return true


func parseCrates(line: string, crates: var openArray[char]) =
  ## Parses a line containing a horizontal cut through a stack of crates.
  let nstacks = (len(line)+1) div 4
  for i in 0..<nstacks:
    let pos = i * 4 + 1
    crates[i] = line[pos]


func isLegend(line: string, nstacks: Natural): bool =
  ## Checks if `line` matches the format expected for the 1-line legend that
  ## appears beneath the stacks.
  if len(line) != (nstacks * 4) - 1:
    return false
  for i in 0..<len(line):
    case i mod 4
    of 1:
      if ord(line[i]) - ord('0') != (i div 4) + 1:
        return false
    else:
      if (line[i] != ' '):
        return false
  return true


type
  Command = object
    Count, Src, Dst: uint8


func parseCommand(line: string): Command =
  ## Parses the given `line` into a `Command`. Raises `ValueError` if the line
  ## does not match the expected format.
  var count, src, dst: int
  if not scanf(line, "move $i from $i to $i", count, src, dst):
    raise newException(ValueError, "cannot parse \"" & line & "\"")
  return Command(Count: uint8(count), Src: uint8(src-1), Dst: uint8(dst-1))


func executeP1(cmd: Command, stacks: var seq[seq[char]]) =
  ## Executes the given command according to part 1 instructions
  let (n, src, dst) = (int(cmd.Count), int(cmd.Src), int(cmd.Dst))
  if src >= len(stacks) or dst >= len(stacks) or n > len(stacks[cmd.Src]):
    raise newException(ValueError, "invalid command")
  for i in 1..n:
    stacks[dst].add(stacks[src][^i])
  stacks[src].setLen(len(stacks[src])-n)


func executeP2(cmd: Command, stacks: var seq[seq[char]]) =
  ## Executes the given command according to part 2 instructions
  let (n, src, dst) = (int(cmd.Count), int(cmd.Src), int(cmd.Dst))
  if src >= len(stacks) or dst >= len(stacks) or n > len(stacks[cmd.Src]):
    raise newException(ValueError, "invalid command")
  for i in 0..<n:
    let item = len(stacks[src]) - n + i
    stacks[dst].add(stacks[src][item])
  stacks[src].setLen(len(stacks[src])-n)


proc parseStackSection(f: File): seq[seq[char]] =
  ## Parses the first section of the input file, i.e. the one containing
  ## the stack of crates. Raises `ValueError` if `f` does not contain the
  ## expected format.
  var
    nstacks: Natural
    line: string
    crates: seq[char]
    stacks: seq[seq[char]]
  while f.readLine(line):
    if nstacks == 0:
      nstacks = (len(line)+1) div 4
      crates = newSeq[char](nstacks)
      stacks = newSeq[seq[char]](nstacks)
    if isLegend(line, nstacks):
      return stacks
    if not isCrates(line, nstacks):
      raise newException(ValueError, "cannot parse \"" & line & "\"")
    parseCrates(line, crates)
    for i in 0..<nstacks:
      if crates[i] != ' ':
        stacks[i].add(crates[i])
  raise newException(IOError, "unexpected EOF")


proc parseCommandSection(f: File): seq[Command] =
  ## Parses the second part of the input file, i.e. a list of commands
  var
    line: string
    cmds: seq[Command]
  while f.readLine(line):
    cmds.add(parseCommand(line))
  return cmds


proc parseInput(filename: string): (seq[seq[char]], seq[Command]) =
  ## Parses `filename` into a sequence of stacks of crates, and
  ## a sequence of commands.
  let f = open(filename)
  try:
    var stacks = parseStackSection(f)
    for i in 0..<len(stacks):
      reverse(stacks[i])
    if not f.readLine().isEmptyOrWhitespace():
      raise newException(ValueError, "unexpected non-empty line")
    let cmds = parseCommandSection(f)
    return (stacks, cmds)
  finally:
    close(f)


func topCrates(stacks: seq[seq[char]]): string =
  ## Returns a string containing the characters of the crates on
  ## top of each stack.
  var s = newStringOfCap(len(stacks))
  for i in 0..<len(stacks):
    s.add(stacks[i][^1])
  return s


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
    var (p1stacks, cmds) = parseInput(InputFile)
    var p2stacks = p1stacks
    for cmd in cmds:
       cmd.executeP1(p1stacks)
       cmd.executeP2(p2stacks)
    echo("Part 1: ", topCrates(p1stacks))
    echo("Part 2: ", topCrates(p2stacks))
  except IOError, ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
