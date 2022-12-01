import strutils

const
  InputFile = "../../input/day01.txt"


proc insertIfGreater(a: var openArray[int], n: int) =
  ## Takes `a`, an array of ints sorted in descending order, and an integer `n`.
  ## If `n` is greater than the smallest element in `a`, the smallest element
  ## will be removed and `n` will be inserted into the right position in `a`.
  for i in 0..<len(a):
    if n > a[i]:
      for j in countdown(len(a)-1, i+1):
        a[j] = a[j-1]
      a[i] = n
      break
  

proc readTopCalories(filename: string, count: int): seq[int] =
  ## Parses the input file and returns the total Calories
  ## carried by the top `count` Elves carrying the most Calories.
  var
    line: string
    sum:  int
  let f = open(filename)
  try:
    result = newSeq[int](count)
    while f.readLine(line):
      if line.isEmptyOrWhitespace():
        insertIfGreater(result, sum)
        sum = 0
      else:
        sum += line.parseInt()
    insertIfGreater(result, sum)
  finally:
    f.close()


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  stderr.writeLine(message)
  quit(QuitFailure)


when isMainModule:
  try:
    let calories = readTopCalories(InputFile, 3)
    echo("Part 1: ", calories[0], " calories")
    echo("Part 2: ", calories[0] + calories[1] + calories[2], " calories")
  except IOError:
    die("Could not read " & InputFile)
  except ValueError:
    die(InputFile & " contains invalid data")
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())