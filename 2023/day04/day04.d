import std.conv;
import std.stdio;
import std.string;

const inputFile = "../input/day04.txt";

class Card
{
    int id;
    int matches;
    int instances = 1;

    this(const char[] line)
    {
        assert(line.startsWith("Card "));
        const colon = line.indexOf(':');
        assert(colon > 5);
        id = to!int(line[5 .. colon].strip());

        const bar = line.indexOf('|', colon + 1);
        assert(bar > colon + 1);

        bool[int] winning;

        foreach (s; line[colon + 1 .. bar].split())
        {
            const n = to!int(s);
            winning[n] = true;
        }

        foreach (s; line[bar + 1 .. $].split())
        {
            const n = to!int(s);
            if (n in winning)
                matches++;
        }
    }

    int score() const
    {
        return (matches == 0) ? 0 : (1 << (matches - 1));
    }
}

void manifoldInstances(Card[] cards)
{
    for (int i = 0; i < cards.length; i++)
    {
        const matches = cards[i].matches;
        const instances = cards[i].instances;

        for (int j = i + 1; j < cards.length && j < i + matches + 1; j++)
            cards[j].instances += instances;
    }
}

int countInstances(const Card[] cards)
{
    int instances;
    foreach (c; cards)
        instances += c.instances;

    return instances;
}

void main()
{
    Card[] cards;
    int points;

    foreach (line; File(inputFile).byLine())
    {
        auto card = new Card(line);
        points += card.score();
        cards ~= card;
    }

    writeln("Part 1: ", points);

    manifoldInstances(cards);

    writeln("Part 2: ", countInstances(cards));
}
