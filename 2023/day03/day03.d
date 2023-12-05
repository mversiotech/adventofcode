/// Solution to https://adventofcode.com/2023/day/3
import std.ascii;
import std.conv;
import std.stdio;

const inputFile = "../input/day03.txt";

struct Number
{
    int value;
    int row;
    int col;
    int len;
}

struct Symbol
{
    int  row;
    int  col;
    char sym;
}

void main()
{
    Number[] numbers;
    Symbol[] symbols;
    int rownr;

    foreach (row; File(inputFile).byLine)
    {
        numbers ~= findNumbers(row, rownr);
        symbols ~= findSymbols(row, rownr);
        rownr++;
    }

    int sum;
    int ratio;

    foreach (s; symbols)
    {
        Number[] adjacent = adjacentNumbers(s, numbers);

        // part 1
        // caveat: this won't work if a number is adjacent to more than 1 symbols
        foreach (n; adjacent)
            sum += n.value; 

        // part 2
        if (s.sym == '*' && adjacent.length == 2)
            ratio += adjacent[0].value * adjacent[1].value;
    }

    writeln("Part 1: ", sum);
    writeln("Part 2: ", ratio);
}

Number[] findNumbers(char[] row, int rownr) 
{
    Number[] numbers;

    for (int i = 0; i < row.length; i++)
    {
        if (!isDigit(row[i]))
            continue;

        int j = i + 1;
        for (; j < row.length && isDigit(row[j]); j++) { }

        Number n;
        n.value = to!int(row[i .. j]);
        n.row = rownr;
        n.col = i;
        n.len = j - i;
        numbers ~= n;

        i = j;
    }

    return numbers;
}

Symbol[] findSymbols(char[] row, int rownr)
{
    Symbol[] symbols;

    for (int i = 0; i < row.length; i++)
    {
        if (row[i] != '.' && !isDigit(row[i]))
        {
            Symbol s;
            s.sym = row[i];
            s.row = rownr;
            s.col = i;
            symbols ~= s;
        }
    }

    return symbols;
}

Number[] adjacentNumbers(Symbol s, Number[] numbers)
{
    Number[] adjacent;

    foreach (n; numbers)
    {
        if (s.row < n.row - 1 || s.row > n.row + 1)
            continue;

        if ((n.col == s.col + 1) || (n.col <= s.col && n.col + n.len >= s.col))
            adjacent ~= n;
    }

    return adjacent;
}
