## Solution for https://adventofcode.com/2022/day/18
##
## For part 2, I first used a flood-fill like process to find all voxels
## outside of the "lava droplets" and then used that to find all outside-facing
## surfaces.

import std/[deques, sets, strutils]

const
  InputFile = "../../input/day18.txt"

type
  Vec3i = object
    x, y, z: int

  Volume = object
    bounds: Vec3i
    voxels: HashSet[Vec3i]


const Neighbors = [
  Vec3i(x: -1), Vec3i(x: 1),
  Vec3i(y: -1), Vec3i(y: 1),
  Vec3i(z: -1), Vec3i(z: 1),
]


func isInBounds(volume: ref Volume, p: Vec3i): bool =
  ## Returns true if `p` lies within the bounds of `volume`.
  p.x >= 0 and p.y >= 0 and p.z >= 0 and
    p.x <= volume.bounds.x and p.y <= volume.bounds.y and p.z <= volume.bounds.z


func moldVolume(volume: ref Volume): ref Volume =
  ## Returns a new volume with the same dimensions as the given `volume`
  ## with all empty space surrounding the voxels in `volume` on the exterior
  ## turned solid and all other voxels empty.
  var
    mold: ref Volume
    next = initDeque[Vec3i]()
  new(mold)
  mold.bounds = volume.bounds
  next.addFirst(Vec3i()) # Assume the voxel at the origin is empty
  while len(next) > 0:
    let cur = next.popFirst()
    if not volume.isInBounds(cur):
      continue
    if not volume.voxels.contains(cur) and not mold.voxels.contains(cur):
      mold.voxels.incl(cur)
      for nb in Neighbors:
        let c = Vec3i(x: cur.x + nb.x, y: cur.y + nb.y, z: cur.z + nb.z)
        next.addLast(c)
  return mold


func totalSurfaceArea(volume: ref Volume): int =
  ## Solves part 1 of the puzzle.
  var area: int
  for voxel in volume.voxels:
    for nb in Neighbors:
      let c = Vec3i(x: voxel.x + nb.x, y: voxel.y + nb.y, z: voxel.z + nb.z)
      if not volume.voxels.contains(c):
        inc(area)
  return area


func exteriorSurfaceArea(volume: ref Volume): int =
  ## Solves part 2 of the puzzle.
  var area: int
  let mold = volume.moldVolume()
  for voxel in volume.voxels:
    for nb in Neighbors:
      let c = Vec3i(x: voxel.x + nb.x, y: voxel.y + nb.y, z: voxel.z + nb.z)
      if mold.voxels.contains(c) or not volume.isInBounds(c):
        inc(area)
  return area


proc readVolume(filename: string): ref Volume =
  ## Creates a volume from the voxel coordinates in `filename`.
  let f = open(filename)
  var volume: ref Volume
  new(volume)
  volume.voxels = initHashSet[Vec3i]()
  try:
    var line: string
    while f.readLine(line):
      let parts = line.split(',')
      if len(parts) != 3:
        raise newException(ValueError, "cannot parse " & line)
      let c = Vec3i(
        x: parseInt(parts[0]),
        y: parseInt(parts[1]),
        z: parseInt(parts[2]),
      )
      volume.bounds.x = max(volume.bounds.x, c.x)
      volume.bounds.y = max(volume.bounds.y, c.y)
      volume.bounds.z = max(volume.bounds.z, c.z)
      volume.voxels.incl(c)
  finally:
    f.close()
  return volume
  

when isMainModule:
  let volume = readVolume(InputFile)
  echo("Part 1: ", volume.totalSurfaceArea())
  echo("Part 2: ", volume.exteriorSurfaceArea())
