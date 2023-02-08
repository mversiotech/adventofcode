## Solution for https://adventofcode.com/2022/day/25
## 
## Encoder and Decoder for the worst numeral system ever. Decoding is
## straightforward using a lookup table. Encoding is only slightly more
## complicated, because digits with negative values require a carry.

import std/[strutils, tables]

const
  InputFile = "../../input/day25.txt"
  SnafuDecoder = {'=': -2, '-': -1, '0': 0, '1': 1, '2': 2}.toTable()
  SnafuEncoder = [ "0", "1", "2", "=", "-"]


func snafuToInt(snafu: string): int =
  var value: int
  for c in snafu:
    if not SnafuDecoder.contains(c):
      raise newException(ValueError, "invalid SNAFU digit " & $c)
    value *= 5
    value += SnafuDecoder[c]
  return value


func intToSnafu(value: int): string =
  if value < 3:
    return SnafuEncoder[value]
  let
    quot = value div 5
    rem = value mod 5
    carry = if rem < 3: 0 else: 1
  return intToSnafu(quot + carry) & SnafuEncoder[rem]


when isMainModule:
  let snafus = readFile(InputFile).strip().split('\n')
  var sum: int
  for snafu in snafus:
    sum += snafuToInt(snafu)
  echo("Part 1: ", intToSnafu(sum))
