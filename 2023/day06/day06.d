/// Solution to https://adventofcode.com/2023/day/6
import std.algorithm : max;
import std.conv : to;
import std.file : readText;
import std.stdio;
import std.string;

const inputFile = "../input/day06.txt";

struct Race
{
    long duration;
    long record;

    long distanceTraveled(long holdTime) const
    {
        return (duration - holdTime) * holdTime;
    }

    long waysOfWinning() const
    {
        long minWin, maxWin;

        for (long i = 1; i < duration; i++)
        {
            if (distanceTraveled(i) > record)
            {
                minWin = i;
                break;
            }
        }

        for (long i = duration - 1; i > 0; i--)
        {
            if (distanceTraveled(i) > record)
            {
                maxWin = i;
                break;
            }
        }

        return maxWin - minWin + 1;
    }
}

Race[] readRaces(string filename)
{
    const lines = readText(filename).strip().split('\n');
    assert(lines.length == 2);
    assert(lines[0].startsWith("Time:"));
    assert(lines[1].startsWith("Distance:"));

    const timeparts = lines[0].split();
    const distparts = lines[1].split();
    assert(timeparts.length == distparts.length);

    Race[] races;

    for (int i = 1; i < timeparts.length; i++)
        races ~= Race(duration : to!int(timeparts[i]), record:
                to!int(distparts[i]));

    const jointime = timeparts[1 .. $].join();
    const joindist = distparts[1 .. $].join();

    races ~= Race(duration : to!long(jointime), record:
            to!long(joindist));

    return races;
}

void main()
{
    const races = readRaces(inputFile);
    int margin = 1;
    for (int i = 0; i < races.length - 1; i++)
        margin *= races[i].waysOfWinning();

    writeln("Part 1: ", margin);

    writeln("Part 2: ", races[$ - 1].waysOfWinning());
}
