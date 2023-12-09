// Solution to https://adventofcode.com/2023/day/9
import std.stdio;

const inputFile = "../input/day09.txt";

void main()
{
    long[2] sum;

    foreach (line; File(inputFile).byLine)
    {
        const h = parseHistory(line);
        const p = predict(h);
        sum[0] += p[0];
        sum[1] += p[1];
    }

    writeln("Part 1: ", sum[0]);
    writeln("Part 2: ", sum[1]);
}

long[] parseHistory(const char[] line)
{
    import std.algorithm.iteration : splitter;
    import std.ascii : isWhite;
    import std.conv : to;

    long[] history;

    foreach (s; line.splitter!(isWhite))
        history ~= to!long(s);

    return history;
}

long[2] predict(const long[] history)
{
    long[2] prediction;
    long[] work = history.dup();
    size_t step;

    while (!allZeroes(work))
    {
        prediction[0] += work[$ - 1];

        // For part 2, alternate between addition and substraction. If you
        // wonder why, look at the 3rd example: the expected result (5) can be
        // written as: 10 - (3 - (0 - (2 - 0)))
        // After elimintating the parentheses we get: 10 - 3 + 0 - 2 + 0 = 5
        if ((step & 1) == 0)
            prediction[1] += work[0];
        else
            prediction[1] -= work[0];

        deltaEncode(work);
        step++;
    }

    return prediction;
}

void deltaEncode(ref long[] history)
{
    assert(history.length > 1);

    for (int i = 0; i < history.length - 1; i++)
        history[i] = history[i + 1] - history[i];

    history = history[0 .. $ - 1];
}

bool allZeroes(long[] array)
{
    import std.algorithm : any;

    return !array.any!("a != 0")();
}
