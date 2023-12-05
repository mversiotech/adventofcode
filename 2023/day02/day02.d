/// Solution to https://adventofcode.com/2023/day/2
import std.conv;
import std.stdio;
import std.string;

const inputFile = "../input/day02.txt";

class Game
{
    int id;
    int[string][] cubeSets;

    this(char[] record)
    {
        assert(record.startsWith("Game "));
        auto colon = record.indexOf(':');
        assert(colon > 5);
        id = to!int(record[5 .. colon]);

        foreach (set; record[colon + 1 .. $].split(';'))
        {
            int[string] cubeSet;

            foreach (cubes; set.split(','))
            {
                auto colorCount = cubes.split();
                assert(colorCount.length == 2);
                int count = to!int(colorCount[0]);
                string color = colorCount[1].dup();
                assert(color == "red" || color == "green" || color == "blue");
                cubeSet[color] = count;
            }

            cubeSets ~= cubeSet;
        }
    }

    bool isPossible() const
    {
        const maxCounts = ["red": 12, "green": 13, "blue": 14];

        foreach (cubeSet; cubeSets)
            foreach (color, count; cubeSet)
                if (count > maxCounts[color])
                    return false;

        return true;
    }

    int[string] minimalSet() const
    {
        import std.algorithm : max;

        auto minSet = ["red": 0, "green": 0, "blue": 0];
        foreach (cubeSet; cubeSets)
            foreach (color, count; cubeSet)
                minSet[color] = max(minSet[color], count);

        return minSet;
    }
}

int cubePower(int[string] cubeSet)
{
    int power = 1;
    foreach (count; cubeSet)
        power *= count;

    return power;
}

void main()
{
    int idSum, powerSum;

    foreach (line; File(inputFile).byLine)
    {
        const game = new Game(line);

        if (game.isPossible())
            idSum += game.id;

        powerSum += game.minimalSet().cubePower();
    }

    writeln("Part 1: ", idSum);
    writeln("Part 2: ", powerSum);
}
