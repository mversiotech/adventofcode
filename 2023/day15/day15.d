// Solution to https://adventofcode.com/2023/day/15
import std.algorithm.iteration;
import std.algorithm.mutation;
import std.conv;
import std.stdio;
import std.string;

const inputFile = "../input/day15.txt";

class Step
{
    string label;
    int focalLen;
    char op;

    this(const char[] s)
    {
        if (s[$ - 1] == '-')
        {
            op = '-';
            label = s[0 .. $ - 1].dup();
        }
        else
        {
            const eq = s.indexOf('=');
            assert(eq > 0 && eq < s.length - 1);
            op = '=';
            label = s[0 .. eq].dup();
            focalLen = to!int(s[eq + 1 .. $]);
        }
    }
}

uint hash(const char[] s)
{
    uint h;
    foreach (c; s)
    {
        h += c;
        h *= 17;
        h &= 0xff;
    }
    return h;
}

void main()
{
    uint hashSum;
    Step[][256] hashMap;

    foreach (line; File(inputFile).byLine())
    {
        foreach (part; line.splitter!("a == ','"))
        {
            hashSum += hash(part);

            auto step = new Step(part);
            const box = hash(step.label);

            if (step.op == '-')
            {
                for (size_t i = 0; i < hashMap[box].length; i++)
                {
                    if (hashMap[box][i].label == step.label)
                    {
                        hashMap[box] = remove(hashMap[box], i);
                        break;
                    }
                }
            }
            else
            {
                bool replaced = false;

                for (size_t i = 0; i < hashMap[box].length; i++)
                {
                    if (hashMap[box][i].label == step.label)
                    {
                        hashMap[box][i] = step;
                        replaced = true;
                        break;
                    }
                }

                if (!replaced)
                    hashMap[box] ~= step;
            }
        }
    }

    writeln("Part 1: ", hashSum);

    int focusPower;

    for (int box = 0; box < hashMap.length; box++)
    {
        for (int slot = 0; slot < hashMap[box].length; slot++)
        {
            focusPower += (box + 1) * (slot + 1) * hashMap[box][slot].focalLen;
        }
    }

    writeln("Part 2: ", focusPower);
}
