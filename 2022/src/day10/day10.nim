## Solution for https://adventofcode.com/2022/day/10

import std/strutils

const
  InputFile  = "../../input/day10.txt"
  CrtColumns = 40
  CrtRows    = 6


type Device = object
  regx, cycle, checksum: int
  crt: seq[bool]


func newDevice(): Device =
  Device(regx: 1, crt: newSeq[bool](CrtColumns * CrtRows))


func step(d: var Device, addx: int) =
  ## Runs a single step and finally adds `addx` to `d.regx`
  let crtx = d.cycle mod CrtColumns
  let crti = d.cycle mod (CrtColumns * CrtRows)
  d.crt[crti] = abs(d.regx - crtx) <= 1         # Part 2
  inc(d.cycle)
  if d.cycle mod 40 == 20:
    d.checksum += d.regx * d.cycle              # Part 1
  d.regx += addx


proc run(d: var Device, filename: string) =
  ## Runs all instructions from `filename`
  let f = open(filename)
  try:
    var line: string
    while f.readLine(line):
      d.step(0)
      if line == "noop":
        continue
      if line.startsWith("addx "):
        d.step(parseInt(line[5..^1]))
        continue
      raise newException(ValueError, "invalid instruction " & line)
  finally:
    f.close()


proc drawCrt(d: Device) =
  var i: int
  for y in 0..<CrtRows:
    for x in 0..<CrtColumns:
      stdout.write(if d.crt[i]: '#' else: ' ')
      inc(i)
    stdout.write('\n')


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
    var dev = newDevice()
    dev.run(InputFile)
    echo("Part 1: ", dev.checksum)
    echo("Part 2:")
    dev.drawCrt()
  except IOError, ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
