// Solution to https://adventofcode.com/2023/day/10
import std.stdio;

const inputFile = "../input/day10.txt";

struct Point
{
    int x;
    int y;
}

class Sketch
{
    Point[2][Point] pipes;
    Point start;

    this(string filename)
    {
        int y;

        foreach (line; File(filename).byLine())
        {
            int x;
            foreach (c; line)
            {
                final switch (c)
                {
                case '|':
                    pipes[Point(x, y)] = [Point(x, y - 1), Point(x, y + 1)];
                    break;
                case '-':
                    pipes[Point(x, y)] = [Point(x - 1, y), Point(x + 1, y)];
                    break;
                case 'L':
                    pipes[Point(x, y)] = [Point(x, y - 1), Point(x + 1, y)];
                    break;
                case 'J':
                    pipes[Point(x, y)] = [Point(x, y - 1), Point(x - 1, y)];
                    break;
                case '7':
                    pipes[Point(x, y)] = [Point(x, y + 1), Point(x - 1, y)];
                    break;
                case 'F':
                    pipes[Point(x, y)] = [Point(x, y + 1), Point(x + 1, y)];
                    break;
                case 'S':
                    start = Point(x, y);
                    break;
                case '.':
                    break;
                }
                x++;
            }
            y++;
        }

        // Find the two tiles connected to the starting position
        Point[] startPipes;
        foreach (from, to; pipes)
            if (to[0] == start || to[1] == start)
                startPipes ~= from;

        assert(startPipes.length == 2);
        pipes[start] = [startPipes[0], startPipes[1]];
    }

    // Follows the pipes from the starting point and returns all points on
    // the loop in an ordered slice.
    Point[] traceLoop() const
    {
        Point[] loop = [start];
        Point curPos = pipes[start][0];
        Point lastPos = start;
        Point nextPos;

        while (curPos != start)
        {
            loop ~= curPos;

            if (pipes[curPos][0] == lastPos)
                nextPos = pipes[curPos][1];
            else
                nextPos = pipes[curPos][0];

            lastPos = curPos;
            curPos = nextPos;
        }

        return loop;
    }
}

// Calculate the area of the polygon with the given vertices using the
// shoelace formula: https://en.wikipedia.org/wiki/Shoelace_formula
int polyArea(const Point[] verts)
{
    int area;

    for (auto i = 0; i < verts.length; i++)
    {
        const j = (i + 1) % verts.length;
        area += verts[i].x * verts[j].y - verts[i].y * verts[j].x;
    }

    return (area > 0) ? (area / 2) : (area / -2);
}

void main()
{
    const sketch = new Sketch(inputFile);
    const loop = sketch.traceLoop();

    // The point the farthest away is exactly on the middle of the loop
    writeln("Part 1: ", loop.length / 2);

    // The shoelace formula on its own doesn't yield the correct result,
    // because it will also include parts of the area covered by the pipes
    // themselves. Pick's theorem (https://en.wikipedia.org/wiki/Pick's_theorem)
    // defines the area of a simple polygon with integer vertex coordinates as:
    // A = i + b/2 - 1
    // where i is the number of integer points interior to the polygon and b is
    // the number of integer points on its boundary. We are looking for the
    // number of interior points, so we can rearrange the formula as:
    // i = A - b/2 + 1
    writeln("Part 2: ", polyArea(loop) - loop.length / 2 + 1);
}
