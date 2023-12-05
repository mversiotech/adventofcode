/// Solution to https://adventofcode.com/2023/day/1
import std.stdio;

const inputFile = "../input/day01.txt";

const digits = [
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
];

void main()
{
    int[2] results;

    foreach (chars; File(inputFile).byLine)
    {
        string line = cast(string) chars;
        results[0] += calibrationValue(line, false);
        results[1] += calibrationValue(line, true);
    }

    writeln("Part 1: ", results[0]);
    writeln("Part 2: ", results[1]);
}

/// Returns the first and last digit found in line combined to form a single
/// two-digit number. If parseDigits is true, calibrationValue will also
/// consider digits given in their string representation, e.g. "one" for 1.
int calibrationValue(string line, bool parseDigits)
{
    int first, last;

    for (size_t i = 0; i < line.length; i++)
        if (frontValue(line[i .. $], &first, parseDigits))
            break;

    for (size_t i = line.length - 1; i < line.length; i--)
        if (frontValue(line[i .. $], &last, parseDigits))
            break;

    return 10 * first + last;
}

/// If s starts with a digit, frontValue will copy it to *value and return
/// true. If parseDigits is true, frontValue will also consider digits given
/// in their string representation. If s does not start with a digit, frontValue
/// returns false.
bool frontValue(string s, int* value, bool parseDigits)
{
    import std.ascii : isDigit;
    import std.string : startsWith;

    if (isDigit(s[0]))
    {
        *value = s[0] - '0';
        return true;
    }

    if (parseDigits)
    {
        foreach (i, digit; digits)
        {
            if (s.startsWith(digit))
            {
                *value = cast(int)(i + 1);
                return true;
            }
        }
    }

    return false;
}
