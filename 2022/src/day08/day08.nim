## Solution for https://adventofcode.com/2022/day/8

const InputFile = "../../input/day08.txt"


type
  Cell = object
    height: uint8
    visible: bool
    score: int

  Grid = object
    width, height: int
    cells: seq[Cell]


proc readGrid(filename: string): ref Grid =
  ## Parses the input file into a `Grid`
  let f = open(filename)
  try:
    var line: string
    while f.readLine(line):
      if result == nil:
        new(result)
        result.width = len(line)
        result.cells = newSeqOfCap[Cell](len(line) * len(line))
      if result.width != len(line):
        raise newException(ValueError, "non-rectangular grid")
      for c in line:
        if c < '0' or c > '9':
          raise newException(ValueError, "invalid character")
        result.cells.add(Cell(height: uint8(ord(c) - ord('0')), score: 1))
      inc(result.height)
  finally:
    f.close()


func evaluateVisibility(grid: ref Grid) =
  ## Evaluates the visibility of each cell in `grid` and asigns a `score` based
  ## on the maximum viewing distance in each direction to it.
  let steps = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  var idst: int
  for ydst in 0..<grid.height:
    for xdst in 0..<grid.width:
      for step in steps:
        var dist = 1
        while true:
          let xsrc = xdst + step[0] * dist
          let ysrc = ydst + step[1] * dist
          let isrc = ysrc * grid.width + xsrc
          if xsrc < 0 or ysrc < 0 or xsrc >= grid.width or ysrc >= grid.height:
            grid.cells[idst].visible = true 
            grid.cells[idst].score *= dist-1
            break
          if grid.cells[isrc].height >= grid.cells[idst].height:
            grid.cells[idst].score *= dist
            break
          inc(dist)
      inc(idst)


func countVisibleCells(grid: ref Grid): int =
  ## Returns the number of cells that are visible from outside the `grid`.
  for c in grid.cells:
    if c.visible:
      inc(result)


func highScore(grid: ref Grid): int =
  ## Returns the highest score of a cell in `grid`.
  for c in grid.cells:
    result = max(result, c.score)
    

proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


if isMainModule:
  try:
    var grid = readGrid(InputFile)
    grid.evaluateVisibility()
    echo("Part 1: ", grid.countVisibleCells())
    echo("Part 2: ", grid.highScore())
  except IOError:
    die("Cannot read " & InputFile)
  except ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
