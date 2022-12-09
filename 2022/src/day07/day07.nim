import std/strutils


const
  InputFile = "../../input/day07.txt"
  SizeThreshold = 100000
  DiskSpace     = 70000000
  RequiredSpace = 30000000


type FSEntry = object
  name:     string
  isDir:    bool
  size:     uint
  parent:   ref FSEntry
  children: seq[ref FSEntry]


func addChild(dir, child: ref FSEntry) =
  ## Adds `child` to `dir` and updates the sizes of `dir` and all its parent
  ## directories.
  var dir: ref FSEntry = dir
  if not dir.isDir:
    raise newException(ValueError, "regular files cannot have children")
  for c in dir.children:
    if c.name == child.name:
      raise newException(ValueError, c.name & " already exists in " & dir.name)
  child.parent = dir
  dir.children.add(child)
  dir.size += child.size
  while dir != dir.parent:
    dir = dir.parent
    dir.size += child.size


func navigate(cwd: ref FSEntry, whereto: string): ref FSEntry =
  ## Navigates to either the parent directory of `cwd`, a child directory
  ## of the file system root directory.
  if whereto == "..":
    return cwd.parent
  if whereto == "/":
    result = cwd
    while result != result.parent:
      result = result.parent
    return result
  for c in cwd.children:
    if c.name == whereto:
      if not c.isDir:
        raise newException(ValueError, whereto & ": not a directory")
      return c
  raise newException(ValueError, "no " & whereto & " in " & cwd.name)


func parseFSEntry(s: string): ref FSEntry =
  ## Parses one file system entry, i.e. one result line of an 'ls' command
  let parts = s.split(' ')
  if len(parts) != 2:
    raise newException(ValueError, "invalid FS entry \"" & s & "\"")
  new(result)
  result.name = parts[1]
  if parts[0] == "dir":
    result.isDir = true
  else:
    result.size = parts[0].parseUInt()


proc parseFS(filename: string): ref FSEntry =
  ## Parses the input file into a file system tree
  var root, cwd: ref FSEntry
  let f = open(filename)
  try:
    var
      inls: bool
      line: string
    new(root)
    root.isDir = true
    root.parent = root
    root.name = "/"
    cwd = root
    while f.readLine(line):
      if line == "$ ls":
        inls = true
        continue
      if line.startsWith("$ cd "):
        inls = false
        cwd = navigate(cwd, line[5..^1])
        continue
      if not inls:
        raise newException(ValueError, "cannot understand \"" & line & "\"")
      cwd.addChild(parseFSEntry(line))
  finally:
    close(f)
  return root


func recursiveSize(dir: ref FSEntry): uint =
  ## Returns the sum of all directory sizes under the root  `dir` which are
  ## smaller than `SizeThreshold`
  result = dir.size
  if result > SizeThreshold:
    result = 0
  for c in dir.children:
    if c.isDir:
      result += c.recursiveSize()


func deletionSize(dir: ref FSEntry, required, prevmin: uint = dir.size): uint =
  ## Returns the size of the smallest subdirectory of `dir` with a size of
  ## at least `required` bytes.
  if dir.size < required:
    return prevmin
  result = dir.size
  for c in dir.children:
    if c.isDir:
      result = min(result, c.deletionSize(required, result))


proc die(message: string) =
  ## Writes `message` to stderr and quits with a non-zero exit code.
  writeLine(stderr, message)
  quit(QuitFailure)


if isMainModule:
  try:
    let fs = parseFS(InputFile)
    echo("Part 1: ", fs.recursiveSize())
    let freespace = DiskSpace - fs.size
    let required = RequiredSpace - freespace
    echo("Part 2: ", fs.deletionSize(required))
  except IOError, ValueError:
    die(InputFile & ": " & getCurrentExceptionMsg())
  except:
    die("Unexpected exception: " & getCurrentExceptionMsg())
