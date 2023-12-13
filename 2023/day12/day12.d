// Solution to https://adventofcode.com/2023/day/12
import std.stdio;
import std.string;

const inputFile = "../input/day12.txt";

struct CacheEntry
{
    int springPos;
    int firstGroup;
}

class Record
{
    string springs;
    int[] groupLengths;

    long[CacheEntry] cache;

    this(const char[] line)
    {
        import std.algorithm.iteration : splitter;
        import std.conv : to;

        const space = line.indexOf(' ');
        assert(space > 0 && space < line.length - 1);
        springs = line[0 .. space].dup();

        foreach (s; line[space + 1 .. $].splitter!("a == ','"))
            groupLengths ~= to!int(s);
    }

    // Checks if a group with the given length and starting position can exist.
    // The function also verifies that no broken springs (pound signs) exist
    // in the range [prev, pos). 
    bool isGroupPossible(int pos, int len, int prev) const
    {
        const next = pos + len;

        if (pos < 0 || next > springs.length)
            return false;

        for (int i = prev; i < pos; i++)
            if (springs[i] == '#')
                return false;

        for (int i = pos; i < next; i++)
            if (springs[i] == '.')
                return false;

        return (next == springs.length) || (springs[next] != '#');
    }

    // Verifies that there are no broken springs (pound signs) at and after
    // the given position.
    bool noGroupAfter(int pos) const
    {
        for (int i = pos; i < springs.length; i++)
            if (springs[i] == '#')
                return false;

        return true;
    }

    long countArrangements(int springPos, int firstGroup)
    {
        CacheEntry ce = {springPos, firstGroup};
        if (auto n = ce in cache)
            return *n;

        long arrangements;
        const len = groupLengths[firstGroup];

        for (int i = springPos; i <= springs.length - len; i++)
        {
            if (isGroupPossible(i, len, springPos))
            {
                if (firstGroup == groupLengths.length - 1)
                    arrangements += (noGroupAfter(i + len)) ? 1 : 0;
                else
                    arrangements += countArrangements(i + len + 1, firstGroup + 1);
            }
        }

        cache[ce] = arrangements;

        return arrangements;
    }

    void unfold()
    {
        string ufSprings;
        int[] ufGroupLengths;

        for (int i = 0; i < 5; i++)
        {
            ufSprings ~= springs;
            ufGroupLengths ~= groupLengths;

            if (i < 4)
                ufSprings ~= '?';
        }

        springs = ufSprings;
        groupLengths = ufGroupLengths;
        cache.clear();
    }
}

void main()
{
    long[2] arrangements;

    foreach (line; File(inputFile).byLine())
    {
        auto r = new Record(line);
        arrangements[0] += r.countArrangements(0, 0);

        r.unfold();
        arrangements[1] += r.countArrangements(0, 0);
    }

    writeln("Part 1: ", arrangements[0]);
    writeln("Part 2: ", arrangements[1]);
}
