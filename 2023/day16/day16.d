// Solution to https://adventofcode.com/2023/day/16
import std.stdio;
import std.string;

const inputFile = "../input/day16.txt";

struct Point
{
    int x;
    int y;
}

enum Direction
{
    Up         = 1,
    Right      = 2,
    Down       = 4,
    Left       = 8,
    Horizontal = Right | Left,
    Vertical   = Up | Down
};

struct Beam
{
    Point pos;
    Direction dir;
}

class Map
{
    char[] tiles;
    Direction[Point] visited;
    int width;
    int height;

    this(string filename)
    {
        foreach (line; File(filename).byLine())
        {
            if (width == 0)
                width = cast(int) line.length;

            assert(width > 0 && width == line.length);

            tiles ~= line.dup();
            height++;
        }
    }

    bool contains(Point p) const
    {
        return p.x >= 0 && p.x < width && p.y >= 0 && p.y < height;
    }

    char tileAt(Point p) const
    {
        return tiles[p.y * width + p.x];
    }

    void markVisited(Beam[] beams)
    {
        foreach (b; beams)
        {
            if (Direction *dir = b.pos in visited)
                *dir |= b.dir;
            else
                visited[b.pos] = b.dir;
        }
    }

    void clearVisited()
    {
        visited.clear();
    }

    bool alreadyVisited(Beam b) const
    {
        if (const Direction *dir = b.pos in visited)
            return ((*dir & b.dir) != 0);

        return false;
    }

    size_t visitedCount() const
    {
        return visited.length;
    }

    Beam[] step(Beam beam) const
    {
        Beam[] next;
        Point nextPos;

        switch (beam.dir)
        {
        case Direction.Up:
            nextPos = Point(beam.pos.x, beam.pos.y - 1);
            break;
        case Direction.Right:
            nextPos = Point(beam.pos.x + 1, beam.pos.y);
            break;
        case Direction.Down:
            nextPos = Point(beam.pos.x, beam.pos.y + 1);
            break;
        case Direction.Left:
            nextPos = Point(beam.pos.x - 1, beam.pos.y);
            break;
        default:
            assert(false);
            break;
        }

        if (!contains(nextPos))
            return next;

        final switch (tileAt(nextPos))
        {
        case '.':
            next ~= Beam(pos: nextPos, dir: beam.dir);
            break;
        case '/':
            if (beam.dir == Direction.Right)
                next ~= Beam(pos: nextPos, dir: Direction.Up);
            else if (beam.dir == Direction.Left)
                next ~= Beam(pos: nextPos, dir: Direction.Down);
            else if (beam.dir == Direction.Down)
                next ~= Beam(pos: nextPos, dir: Direction.Left);
            else if (beam.dir == Direction.Up)
                next ~= Beam(pos: nextPos, dir: Direction.Right);
            break;
        case '\\':
            if (beam.dir == Direction.Right)
                next ~= Beam(pos: nextPos, dir: Direction.Down);
            else if (beam.dir == Direction.Left)
                next ~= Beam(pos: nextPos, dir: Direction.Up);
            else if (beam.dir == Direction.Down)
                next ~= Beam(pos: nextPos, dir: Direction.Right);
            else if (beam.dir == Direction.Up)
                next ~= Beam(pos: nextPos, dir: Direction.Left);
            break;
        case '-':
            if (beam.dir & Direction.Horizontal)
            {
                next ~= Beam(pos: nextPos, dir: beam.dir);
            }
            else
            {
                next ~= Beam(pos: nextPos, dir: Direction.Left);
                next ~= Beam(pos: nextPos, dir: Direction.Right);
            }
            break;
        case '|':
            if (beam.dir & Direction.Vertical)
            {
                next ~= Beam(pos: nextPos, dir: beam.dir);
            }
            else
            {
                next ~= Beam(pos: nextPos, dir: Direction.Up);
                next ~= Beam(pos: nextPos, dir: Direction.Down);
            }
            break;
        }

        return next;
    }

    void shootBeam(Beam beam)
    {
        Beam[] beams = [ beam ];

        while (beams.length > 0)
        {
            markVisited(beams);

            Beam[] next;
            foreach (b; beams)
                foreach (n; step(b))
                    if (!alreadyVisited(n))
                        next ~= n;

            beams = next;
        }
    }
}

void main()
{
    auto map = new Map(inputFile);

    size_t maxVisited;

    for (int y=0; y < map.height; y++)
    {
        // Left edge
        map.shootBeam(Beam(pos: Point(-1, y), dir: Direction.Right));

        // -1 because the first position is outside the map
        size_t n = map.visitedCount() - 1;

        if (y == 0)
            writeln("Part 1: ", n);

        maxVisited = (n > maxVisited) ? n : maxVisited;

        map.clearVisited();

        // Right edge
        map.shootBeam(Beam(pos: Point(map.width, y), dir: Direction.Left));
        n = map.visitedCount() - 1;
        maxVisited = (n > maxVisited) ? n : maxVisited;

        map.clearVisited();
    }

    for (int x=0; x < map.width; x++)
    {
        // Top edge
        map.shootBeam(Beam(pos: Point(x, -1), dir: Direction.Down));
        size_t n = map.visitedCount() - 1;
        maxVisited = (n > maxVisited) ? n : maxVisited;

        map.clearVisited();

        // Bottom edge
        map.shootBeam(Beam(pos: Point(x, map.height), dir: Direction.Up));
        n = map.visitedCount() - 1;
        maxVisited = (n > maxVisited) ? n : maxVisited;

        map.clearVisited();
    }

    writeln("Part 2: ", maxVisited);
}
