import std.algorithm : min;
import std.conv : to;
import std.stdio;
import std.string;

const inputFile = "../input/day05.txt";

class Almanac
{
    long[] seeds;
    Map[] maps;

    this(File f)
    {
        const head = f.readln();
        assert(head.startsWith("seeds: "));
        const parts = head.split();
        for (int i = 1; i < parts.length; i++)
            seeds ~= to!long(parts[i]);

        f.readln();
        while (!f.eof())
            maps ~= new Map(f);
    }
}

class Map
{
    string name;
    Range[] ranges;

    this(File f)
    {
        name = f.readln().strip();
        assert(name.endsWith(" map:"));

        while (!f.eof())
        {
            const line = f.readln().strip();
            if (line.length == 0)
                break;

            ranges ~= new Range(line);
        }
    }

    long mapSource(long src) const
    {
        foreach (r; ranges)
            if (r.containsSource(src))
                return r.mapSource(src);

        return src;
    }
}

class Range
{
    long dstStart;
    long srcStart;
    long len;

    this(const char[] line)
    {
        auto parts = line.split();
        assert(parts.length == 3);
        dstStart = to!long(parts[0]);
        srcStart = to!long(parts[1]);
        len = to!long(parts[2]);
    }

    bool containsSource(long src) const
    {
        return src >= srcStart && src < srcStart + len;
    }

    long mapSource(long src) const
    {
        return src - srcStart + dstStart;
    }
}

void main()
{
    auto f = File(inputFile, "r");
    const almanac = new Almanac(f);
    long minLoc = long.max;

    foreach (seed; almanac.seeds)
    {
        long src = seed;
        foreach (map; almanac.maps)
            src = map.mapSource(src);

        minLoc = min(minLoc, src);
    }

    writeln("Part 1: ", minLoc);
}
