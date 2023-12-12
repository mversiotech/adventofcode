import std.file;
import std.stdio;
import std.string;

const inputFile = "../input/day11.txt";

struct Point
{
    long x;
    long y;
}

Point[] parseInput(const string[] input, long expansion)
{
    Point[] points;
    bool[long] nonemptyCols;
    long maxx, y;

    foreach (line; input)
    {
        long x;
        bool nonemptyRow = false;
        foreach (c; line)
        {
            if (c == '#')
            {
                points ~= Point(x: x, y: y);
                nonemptyRow = true;
                nonemptyCols[x] = true;
                maxx = (x > maxx) ? x : maxx;
            }
            x++;
        }

        // Adjust the y-coordinate to expand empty rows
        y += (nonemptyRow) ? 1 : expansion;
    }

    // To expand empty columns, loop from right to left and increment the
    // x-coordinate of every point to the right of an empty column.
    for (long x = maxx - 1; x > 0; x--)
    {
        if (x in nonemptyCols)
            continue;

        foreach (ref p; points)
            if (p.x > x)
                p.x += expansion - 1; // -1 because the original column also counts
    }

    return points;
}

long manhattanDistance(Point a, Point b)
{
    import std.math : abs;

    return abs(b.x - a.x) + abs(b.y - a.y);
}

long distanceSum(Point[] points)
{
    long sum;
    foreach (i, a; points)
        foreach (b; points[i + 1 .. $])
            sum += manhattanDistance(a, b);

    return sum;
}

void main()
{
    const input = readText(inputFile).split('\n');

    writeln("Part 1: ", distanceSum(parseInput(input, 2)));
    writeln("Part 2: ", distanceSum(parseInput(input, 1000000)));
}
