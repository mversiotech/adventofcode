
type Vec2i* = (int, int)

func x*(v: Vec2i): int =
  v[0]

proc `x=`*(v: var Vec2i, value: int) =
  v[0] = value

func y*(v: Vec2i): int =
  v[1]

proc `y=`*(v: var Vec2i, value: int) =
  v[1] = value

func `+`*(lhs, rhs: Vec2i): Vec2i =
  (lhs.x + rhs.x, lhs.y + rhs.y)

func `-`*(lhs, rhs: Vec2i): Vec2i =
  (lhs.x - rhs.x, lhs.y - rhs.y)

func `*`*(v: Vec2i, n: int): Vec2i =
  (v.x * n, v.y * n)

func `div`*(v: Vec2i, n: int): Vec2i =
  (v.x div n, v.y div n)

func `mod`*(v: Vec2i, n: int): Vec2i =
  (v.x mod n, v.y mod n)