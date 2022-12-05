## Solution for https://adventofcode.com/2022/day/2
## 
## For today's puzzle we need to calculate the score of a number of games
## of Rock Paper Scissors. The two parts of the puzzle offer different
## interpretations of the input data, thus leading to different scores.

const
  InputFile = "../../input/day02.txt"


type
  Shape = enum
    Rock, Paper, Scissors

  Outcome = enum
    Defeat, Draw, Victory

  Round = object
    opponent, player: char


func parseRound(line: string): Round =
  ## Parses one line of input data into a `Round`.
  ## Raises `ValueError` if the line does not match the expected format.
  if len(line) != 3 or
     line[0] < 'A' or line[0] > 'C' or
     line[1] != ' ' or
     line[2] < 'X' or line[2] > 'Z':
    raise newException(ValueError, "cannot parse \"" & line & "\"")
  return Round(opponent: line[0], player: line[2])


func opponentShape(r: Round): Shape =
  ## Interprets and returns `r.opponent` as a `Shape`.
  return Shape(ord(r.opponent) - ord('A'))


func playerShape(r: Round): Shape =
  ## Interprets and returns `r.player` as a `Shape`.
  return Shape(ord(r.player) - ord('X'))


func playerGoal(r: Round): Outcome =
  ## Interprets and returns `r.player` as an `Outcome`.
  return Outcome(ord(r.player) - ord('X'))


func outcomeForPlayerShape(r: Round): Outcome =
  ## Returns the `Outcome` if `r.player` is interpreted as the `Shape` chosen
  ## by the player.
  if r.playerShape() == r.opponentShape():
    return Draw
  if (ord(r.playerShape()) + 1) mod 3 == ord(r.opponentShape()):
    return Defeat
  return Victory


func shapeBasedScore(r: Round): int =
  ## Returns the score of `r` by interpreting `r.player` as the `Shape`
  ## chosen by the player.
  return 3 * ord(r.outcomeForPlayerShape()) + ord(r.playerShape()) + 1


func totalShapeBasedScore(rounds: seq[Round]): int =
  ## Returns the sum of scores of all `rounds` by interpreting their `.player`
  ## fields as the `Shape` chosen by the player.
  for r in rounds:
    result += r.shapeBasedScore()


func shapeForPlayerGoal(r: Round): Shape =
  ## Returns the `Shape` the player must choose if `r.player` is
  ## interpreted as the goal of the player for this round.
  case r.playerGoal()
  of Draw:
    return r.opponentShape()
  of Victory:
    return Shape((ord(r.opponentShape()) + 1) mod 3)
  of Defeat:
    return Shape((ord(r.opponentShape()) + 2) mod 3)


func goalBasedScore(r: Round): int =
  ## Returns the score of `r` by interpreting `r.player` as the goal of the
  ## player for this round.
  return 3 * ord(r.playerGoal()) + ord(r.shapeForPlayerGoal()) + 1


func totalGoalBasedScore(rounds: seq[Round]): int =
  ## Returns the sum of scores of all `rounds` by interpreting their `.player`
  ## fields as the goal of the player for the given round.
  for r in rounds:
    result += r.goalBasedScore()


proc readInput(filename: string): seq[Round] =
  ## Reads input data from `filename` and parses in into a sequence of `Round`s.
  let f = open(filename)
  try:
    var line: string
    while f.readLine(line):
      result.add(parseRound(line))
  finally:
    f.close()


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


when isMainModule:
  try:
    let rounds = readInput(InputFile)
    echo("Part 1: ", totalShapeBasedScore(rounds))
    echo("Part 2: ", totalGoalBasedScore(rounds))
  except IOError:
    die("Cannot read " & InputFile)
  except ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
