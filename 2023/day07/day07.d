// Solution to https://adventofcode.com/2023/day/7
import std.algorithm : sort;
import std.conv : to;
import std.stdio;
import std.string;

const inputFile = "../input/day07.txt";

enum HandType
{
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind
}

int[char] cardStrength;

class Hand
{
    const char[] cards;
    int bid;
    HandType type;

    this(const char[] cards, int bid)
    {
        assert(cards.length == 5);
        this.cards = cards.dup();
        this.bid = bid;
        this.type = classifyHand(cards);
    }

    void replaceJoker()
    {
        if (cards.indexOf('J') == -1)
            return;

        HandType bestType = type;

        foreach (c; "23456789TQKA")
        {
            const testCards = cards.replace('J', c);
            const testType = classifyHand(testCards);
            if (testType > bestType)
                bestType = testType;
        }

        type = bestType;
    }

    override int opCmp(Object o)
    {
        if (auto oh = cast(Hand) o)
        {
            if (type != oh.type)
                return cast(int)(type - oh.type);

            for (int i = 0; i < 5; i++)
            {
                if (cards[i] == oh.cards[i])
                    continue;

                return cardStrength[cards[i]] - cardStrength[oh.cards[i]];
            }

            return 0;
        }
        else
        {
            return -1;
        }
    }
}

HandType classifyHand(const char[] cards)
{
    int[char] cardCounts;
    foreach (c; cards)
    {
        if (c in cardCounts)
            cardCounts[c]++;
        else
            cardCounts[c] = 1;
    }

    bool containsValue(int[char] array, int value)
    {
        foreach (n; array.byValue())
            if (n == value)
                return true;
        return false;
    }

    final switch (cardCounts.length)
    {
    case 1:
        return HandType.FiveOfAKind;
    case 2:
        if (containsValue(cardCounts, 4))
            return HandType.FourOfAKind;
        else
            return HandType.FullHouse;
    case 3:
        if (containsValue(cardCounts, 3))
            return HandType.ThreeOfAKind;
        else
            return HandType.TwoPair;
    case 4:
        return HandType.OnePair;
    case 5:
        return HandType.HighCard;
    }
}

void main()
{
    Hand[] hands;

    foreach (line; File(inputFile).byLine())
    {
        const parts = line.split();
        assert(parts.length == 2);
        const bid = to!int(parts[1]);
        hands ~= new Hand(parts[0], bid);
    }

    foreach (i, c; "23456789TJQKA")
        cardStrength[c] = cast(int) i;

    hands.sort();

    int winnings;
    foreach (i, h; hands)
    {
        winnings += h.bid * (i + 1);
        h.replaceJoker(); // prepare for part 2
    }

    writeln("Part 1: ", winnings);

    foreach (i, c; "J23456789TQKA")
        cardStrength[c] = cast(int) i;

    hands.sort();

    winnings = 0;
    foreach (i, h; hands)
        winnings += h.bid * (i + 1);

    writeln("Part 2: ", winnings);
}
