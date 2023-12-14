// Solution to https://adventofcode.com/2023/day/14
import std.stdio;
import std.string;

const inputFile = "../input/day14.txt";

char[][] readMap(string filename)
{
    char[][] map;

    foreach (line; File(filename).byLine())
    {
        map ~= line.dup();
        assert(map[0].length == map[$ - 1].length);
    }

    return map;
}

void tiltNorth(char[][] map)
{
    for (long top = 1; top < map.length; top++)
    {
        for (long row = top; row > 0; row--)
        {
            for (long col = 0; col < map[row].length; col++)
            {
                if (map[row][col] == 'O' && map[row - 1][col] == '.')
                {
                    map[row][col] = '.';
                    map[row - 1][col] = 'O';
                }
            }
        }
    }
}

void tiltSouth(char[][] map)
{
    const last = map.length - 2;
    for (long bottom = last; bottom >= 0; bottom--)
    {
        for (long row = bottom; row <= last; row++)
        {
            for (long col = 0; col < map[row].length; col++)
            {
                if (map[row][col] == 'O' && map[row + 1][col] == '.')
                {
                    map[row][col] = '.';
                    map[row + 1][col] = 'O';
                }
            }
        }
    }
}

void tiltWest(char[][] map)
{
    for (long left = 1; left < map[0].length; left++)
    {
        for (long col = left; col > 0; col--)
        {
            for (long row = 0; row < map.length; row++)
            {
                if (map[row][col] == 'O' && map[row][col - 1] == '.')
                {
                    map[row][col] = '.';
                    map[row][col - 1] = 'O';
                }
            }
        }
    }
}

void tiltEast(char[][] map)
{
    const last = map[0].length - 2;
    for (long right = last; right >= 0; right--)
    {
        for (long col = right; col <= last; col++)
        {
            for (long row = 0; row < map.length; row++)
            {
                if (map[row][col] == 'O' && map[row][col + 1] == '.')
                {
                    map[row][col] = '.';
                    map[row][col + 1] = 'O';
                }
            }
        }
    }
}

ulong supportLoad(const char[][] map)
{
    ulong load;

    for (ulong row = 0; row < map.length; row++)
    {
        for (ulong col = 0; col < map[0].length; col++)
        {
            if (map[row][col] == 'O')
                load += map.length - row;
        }
    }

    return load;
}

ulong hash(const char[][] map)
{
    const ulong prime = 1099511628211;
    ulong h = 14695981039346656037;

    for (ulong row = 0; row < map.length; row++)
    {
        for (ulong col = 0; col < map[row].length; col++)
        {
            h *= prime;
            h ^= map[row][col];
        }
    }

    return h;
}

void main()
{
    auto map = readMap(inputFile);
    map.tiltNorth();

    ulong[] loads;
    loads ~= map.supportLoad();

    writeln("Part 1: ", loads[0]);

    map.tiltWest();
    map.tiltSouth();
    map.tiltEast();

    ulong[ulong] hashes;
    hashes[0] = map.hash();

    const ulong iterations = 1_000_000_000;

    for (ulong cycles = 1; cycles < 1000; cycles++)
    {
        map.tiltNorth();
        map.tiltWest();
        map.tiltSouth();
        map.tiltEast();

        const h = map.hash();
        if (h in hashes)
        {
            const cycleStart = hashes[h];
            const cycleLen = cycles - cycleStart;
            const loadIndex = ((iterations - cycleStart) % cycleLen) + cycleStart - 1;
            writeln("Part 2: ", loads[loadIndex]);
            return;
        }

        hashes[h] = cycles;
        loads ~= map.supportLoad();
    }

    writeln("Part 2: no cycle found");
}
