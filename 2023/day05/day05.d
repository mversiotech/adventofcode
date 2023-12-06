/// Solution to https://adventofcode.com/2023/day/5
import std.algorithm : min, max;
import std.conv : to;
import std.stdio;
import std.string;

const inputFile = "../input/day05.txt";

class Almanac
{
    Range[] seedRanges;
    Map[] maps;

    this(File f)
    {
        const head = f.readln();
        assert(head.startsWith("seeds: "));
        const parts = head.split();
        assert((parts.length & 1) == 1);
        for (int i = 1; i < parts.length; i += 2)
            seedRanges ~= Range(start: to!long(parts[i]), len: to!long(parts[i+1]));

        f.readln();
        while (!f.eof())
            maps ~= new Map(f);
    }
}

class Map
{
    string name;
    MapRange[] ranges;

    this(File f)
    {
        name = f.readln().strip();
        assert(name.endsWith(" map:"));

        while (!f.eof())
        {
            const line = f.readln().strip();
            if (line.length == 0)
                break;

            ranges ~= new MapRange(line);
        }
    }

    long mapSource(long src) const
    {
        foreach (r; ranges)
            if (r.containsSource(src))
                return r.mapSource(src);

        return src;
    }

    void mapSourceRanges(ref Range[] srcRanges) const
    {
        for (int i=0; i < srcRanges.length; i++)
        {
            foreach (r; ranges)
            {
                const inter = r.srcRange.intersect(srcRanges[i]);
                if (inter[1].isValid())
                {
                    srcRanges[i] = r.mapSourceRange(inter[1]);

                    if (inter[0].isValid())
                        srcRanges ~= inter[0];

                    if (inter[2].isValid())
                        srcRanges ~= inter[2];

                    break;
                }
            }
        }
    }
}

class MapRange
{
    Range srcRange;
    long dstStart;

    this(const char[] line)
    {
        auto parts = line.split();
        assert(parts.length == 3);
        dstStart = to!long(parts[0]);
        srcRange.start = to!long(parts[1]);
        srcRange.len = to!long(parts[2]);
    }

    bool containsSource(long src) const
    {
        return src >= srcRange.start && src < srcRange.start + srcRange.len;
    }

    long mapSource(long src) const
    {
        return src - srcRange.start + dstStart;
    }

    Range mapSourceRange(Range src) const
    {
        const start = dstStart + src.start - srcRange.start;
        return Range(start: start, len: src.len);
    }
}

struct Range
{
    long start;
    long len;

    bool isValid() const
    {
        return len > 0;
    }

    // Intersects this range with another Range named r. Returns 3 ranges:
    // The first one is the part of r that lies below the values in the
    // current range. The second one is the intersection, and the third
    // one is the part of r that lies above the current range.
    Range[3] intersect(Range r) const
    {
        Range[3] ranges;

        const end = start + len;
        const rend = r.start + r.len;

        if (r.start < start)
        {
            ranges[0].start = r.start;
            if (r.start + r.len < start)
                ranges[0].len = r.len;
            else
                ranges[0].len = start - r.start;
        }

        if (rend > start && r.start < end)
        {
            ranges[1].start = max(start, r.start);
            ranges[1].len = min(end, rend) - ranges[1].start;
        }

        if (rend > end)
        {
            if (r.start > end)
                ranges[2].start = r.start;
            else
                ranges[2].start = end;

            ranges[2].len = rend - ranges[2].start;
        }

        return ranges;
    }
}

void main()
{
    auto f = File(inputFile, "r");
    const almanac = new Almanac(f);
    long minLoc = long.max;

    foreach (seedRange; almanac.seedRanges)
    {
        Range r = seedRange;
        foreach (map; almanac.maps)
        {
            r.start = map.mapSource(r.start);
            r.len = map.mapSource(r.len);
        }

        minLoc = min(minLoc, r.start, r.len);
    }

    writeln("Part 1: ", minLoc);

    Range[] srcRanges = almanac.seedRanges.dup();

    foreach (map; almanac.maps)
        map.mapSourceRanges(srcRanges);

    minLoc = long.max;
    foreach (r; srcRanges)
        minLoc = min(minLoc, r.start);

    writeln("Part 2: ", minLoc);
}
