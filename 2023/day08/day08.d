// Solution to https://adventofcode.com/2023/day/8
// This solution assumes that a path that reaches an end node in n steps will
// reach the next end node after another n steps and so forth. If this
// assumption holds (it does for the test input and my personal input), the
// final result is the least common multiple of all the individual path lengths
// to a goal node.
import std.algorithm : any;
import std.numeric : lcm;
import std.string : strip;
import std.stdio;

const inputFile = "../input/day08.txt";

// Represent the 3-byte node names as an BE uint32 for faster comparison
alias NodeType = uint;

NodeType toNodeType(const char[] label)
{
    assert(label.length == 3);
    return ((cast(uint) label[0])) << 16 | ((cast(uint) label[1])) << 8 | (cast(uint) label[2]);
}

bool isStartNode(NodeType n)
{
    return (n & 0xff) == cast(uint) 'A';
}

bool isGoalNode(NodeType n)
{
    return (n & 0xff) == cast(uint) 'Z';
}

struct Node
{
    NodeType left;
    NodeType right;
}

Node[NodeType] readNetwork(File f)
{
    Node[NodeType] network;

    while (!f.eof())
    {
        const line = f.readln();
        if (line.length == 0)
            break;

        assert(line.length == 17);
        assert(line[3] == ' ' && line[4] == '=' && line[5] == ' ' && line[6] == '(');
        assert(line[10] == ',' && line[11] == ' ' && line[15] == ')');

        const current = toNodeType(line[0 .. 3]);
        const left = toNodeType(line[7 .. 10]);
        const right = toNodeType(line[12 .. 15]);

        network[current] = Node(left : left, right:
                right);
    }

    return network;
}

// Calculate the least common multiple of a slice of ulongs.
// (The stdlib lcm function only accepts 2 parameters)
ulong sliceLCM(ulong[] num)
{
    ulong l = num[0];
    foreach (n; num[1 .. $])
        l = lcm(l, n);
    return l;
}

void main()
{
    auto f = File(inputFile, "r");
    const instructions = f.readln().strip();
    assert(instructions.length > 0);
    assert(!instructions.any!("(a != 'L' && a != 'R')"));
    f.readln();

    const network = readNetwork(f);

    NodeType[] currentNodes;
    foreach (n; network.byKey())
        if (n.isStartNode())
            currentNodes ~= n;

    const zzz = toNodeType("ZZZ");

    ulong step = 0;
    ulong[] stepsToGoal;

    while (currentNodes.length != 0)
    {
        const instr = instructions[step % instructions.length];

        for (int i = 0; i < currentNodes.length; i++)
        {
            const n = currentNodes[i];
            if (n.isGoalNode())
            {
                if (n == zzz)
                    writeln("Part 1: ", step);

                stepsToGoal ~= step;

                // Remove the finished node by swapping it with the last
                // node and truncating the slice.
                currentNodes[i] = currentNodes[$ - 1];
                currentNodes = currentNodes[0 .. $ - 1];
                i--;
            }
            else
            {
                if (instr == 'L')
                    currentNodes[i] = network[n].left;
                else
                    currentNodes[i] = network[n].right;
            }
        }

        step++;
    }

    writeln("Part 2: ", sliceLCM(stepsToGoal));
}
