import std.stdio;
import std.string;

const inputFile = "../input/day13.txt";

char[][] readPattern(File f)
{
    char[][] pattern;
    char[] line;

    while (!f.eof())
    {
        const n = f.readln(line);
        if (n <= 1)
            return pattern;

        pattern ~= line[0 .. n-1].dup();
        assert(pattern[0].length == n-1);
    }

    return pattern;
}

bool rowsEqual(const char[][] pattern, int i, int j)
{
    return pattern[i] == pattern[j];
}

bool colsEqual(const char[][] pattern, int i, int j)
{
    foreach (row; pattern)
        if (row[i] != row[j])
            return false;

    return true;
}

bool isMirroredAfterRow(const char[][] pattern, int row)
{
    if (row >= pattern.length-1)
        return false;

    int i = row;
    int j = row+1;

    while (i >= 0 && j < pattern.length)
    {
        if (!pattern.rowsEqual(i, j))
            return false;
        
        i--;
        j++;
    }

    return true;
}

bool isMirroredAfterCol(const char[][] pattern, int col)
{
    const rowLen = pattern[0].length;

    if (col >= rowLen-1)
        return false;

    int i = col;
    int j = col+1;

    while (i >= 0 && j < rowLen)
    {
        if (!pattern.colsEqual(i, j))
            return false;

        i--;
        j++;
    }

    return true;
}

int mirrorScore(const char[][] pattern)
{
    for (int row=0; row < pattern.length; row++)
        if (pattern.isMirroredAfterRow(row))
            return 100 * (row+1);

    const rowLen = pattern[0].length;

    for (int col=0; col < rowLen; col++)
        if (pattern.isMirroredAfterCol(col))
            return col + 1;

    return -1;
}

void main()
{
    int[2] sum;

    auto f = File(inputFile);

    mainLoop: while (!f.eof())
    {
        auto pattern = readPattern(f);
        const score1 = pattern.mirrorScore();
        assert(score1 >= 0);
        sum[0] += score1;

        foreach (row; pattern)
        {
            foreach (i, c; row)
            {
                row[i] = (c == '.') ? '#' : '.';
                const score2 = pattern.mirrorScore();
                row[i] = (c == '.') ? '.' : '#';

                if (score2 > 0 && score2 != score1)
                {
                    sum[1] += score2;
                    continue mainLoop;
                }
            }
        }

        sum[1] += score1;
    }

    writeln("Part 1: ", sum[0]);
    writeln("Part 2: ", sum[1]); // Want: 29083 > x > 34289
}
