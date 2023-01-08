## Solution for https://adventofcode.com/2022/day/20
## 
## Conceptually, this solution uses a doubly linked list that represents a
## circular sequence of nodes. The complexity of looking up the n-th neighbor
## of a node is O(n), but since the implementation is based on a flat array of
## nodes and avoids pointer indirections, the overall performance of the program
## is not too bad.

import std/strutils

type
  RingIndex = uint32

  RingEntry = object
    value: int
    prev:  RingIndex
    next:  RingIndex

  Ring = seq[RingEntry]


const
  InputFile = "../../input/day20.txt"
  DecryptionKey = 811589153
  InvalidIndex = high(RingIndex)


func valueAt(ring: Ring, index: RingIndex): int =
  ## Returns the value stored at the given `index` in the `ring`.
  ring[index].value


func after(ring: Ring, index: RingIndex, steps: Natural): RingIndex =
  ## Returns the index of the ring entry the given number of `steps`
  ## after `index`.
  var index = index
  for i in 0..<steps mod len(ring):
    index = ring[index].next
  return index


func find(ring: Ring, value: int): RingIndex =
  ## Returns the index of the first entry with the given `value` in `ring`. If
  ## `value` does not occur in `ring`, find returns `InvalidIndex`.
  for i in 0..<len(ring):
    if ring[i].value == value:
      return RingIndex(i)
  return InvalidIndex


func move(ring: var Ring, index: RingIndex, steps: int) =
  ## Moves the entry at `index` for the given number of `steps`.
  ## If steps is negative, the entry will be moved backwards.
  let
    oldprev = ring[index].prev
    oldnext = ring[index].next
    steps = steps mod (len(ring)-1)
  var (newprev, newnext) = (index, index)
  if steps > 0:
    for i in 0..<steps:
      newprev = ring[newprev].next
    newnext = ring[newprev].next
  elif steps < 0:
    for i in 0..<abs(steps):
      newnext = ring[newnext].prev
    newprev = ring[newnext].prev
  else:
    return
  ring[oldprev].next = oldnext
  ring[oldnext].prev = oldprev
  ring[index].prev = newprev
  ring[index].next = newnext
  ring[newprev].next = index
  ring[newnext].prev = index


func mix(ring: var Ring) =
  ## Mixes the ring entries according to the puzzle specification.
  for i in 0..<len(ring):
    let pos = RingIndex(i)
    ring.move(pos, ring.valueAt(pos))


func premultiply(ring: var Ring) =
  ## Multiplies each value in the `ring` with `DecryptionKey`.
  for i in 0..<len(ring):
    ring[i].value *= DecryptionKey


func grooveCoordinates(ring: Ring): int =
  ## Returns the groove coordinates according to the puzzle specification.
  var sum: int
  let zeropos = ring.find(0)
  if zeropos != InvalidIndex:
    for i in [1000, 2000, 3000]:
      sum += ring.valueAt(ring.after(zeropos, i))
  return sum


proc readRing(filename: string): Ring =
  ## Reads a sequence of numbers, one on each line, from `filename` and returns
  ## a ring based on this sequence.
  var ring: Ring
  let f = open(filename)
  try:
    var line: string
    while f.readLine(line):
      let value = line.parseInt()
      let entry = RingEntry(
        value: value,
        prev: if len(ring) > 0: uint32(len(ring)-1) else: 0,
        next: uint32(len(ring)+1),
      )
      ring.add(entry)
    ring[0].prev = uint32(len(ring)-1)
    ring[^1].next = 0
    return ring
  finally:
    f.close()


when isMainModule:
  var
    ring1 = readRing(InputFile)
    ring2 = ring1
  ring1.mix()
  echo("Part 1: ", ring1.grooveCoordinates())
  ring2.premultiply()
  for i in 0..<10:
    ring2.mix()
  echo("Part 2: ", ring2.grooveCoordinates())