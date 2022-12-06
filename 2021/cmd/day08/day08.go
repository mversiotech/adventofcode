// Solution for https://adventofcode.com/2021/day/8

package main

import (
	"bufio"
	"fmt"
	"math/bits"
	"os"
	"strings"
)

const (
	InputFile = "../../input/day08.txt"
)

type Pattern uint8

const (
	SegA Pattern = 1 << iota
	SegB
	SegC
	SegD
	SegE
	SegF
	SegG
)

func PatternFromString(s string) (p Pattern) {
	for _, r := range s {
		switch r {
		case 'a':
			p |= SegA
		case 'b':
			p |= SegB
		case 'c':
			p |= SegC
		case 'd':
			p |= SegD
		case 'e':
			p |= SegE
		case 'f':
			p |= SegF
		case 'g':
			p |= SegG
		default:
			panic("invalid segment pattern " + s)
		}
	}

	return p
}

func PatternsFromStrings(list []string) []Pattern {
	patterns := make([]Pattern, len(list))

	for i, s := range list {
		patterns[i] = PatternFromString(s)
	}

	return patterns
}

func NewPatternDecoder(patterns []Pattern) map[Pattern]int {
	if len(patterns) != 10 {
		panic("pattern list must have 10 entries")
	}

	encoder := make([]Pattern, 10)
	decoder := make(map[Pattern]int)

	var l5, l6 []Pattern

	// Find-fixed lengh patterns
	for _, p := range patterns {
		switch bits.OnesCount8(uint8(p)) {
		case 2:
			encoder[1] = p
			decoder[p] = 1
		case 3:
			encoder[7] = p
			decoder[p] = 7
		case 4:
			encoder[4] = p
			decoder[p] = 4
		case 5:
			l5 = append(l5, p)
		case 6:
			l6 = append(l6, p)
		case 7:
			encoder[8] = p
			decoder[p] = 8
		default:
			panic("wrong number of bits set in pattern")
		}
	}

	AssertSliceLength(l5, 3)
	AssertSliceLength(l6, 3)

	// 0 and 9 have both bits from 1 set, 6 only one of them
	for i, p := range l6 {
		if p&encoder[1] != encoder[1] {
			encoder[6] = p
			decoder[p] = 6
			l6[i] = l6[len(l6)-1]
			l6 = l6[:len(l6)-1]
			break
		}
	}

	AssertSliceLength(l6, 2)

	// 9 has all bits from 4 set, 0 doesn't
	if l6[0]&encoder[4] == encoder[4] {
		encoder[9] = l6[0]
		decoder[l6[0]] = 9
		encoder[0] = l6[1]
		decoder[l6[1]] = 0
	} else {
		encoder[9] = l6[1]
		decoder[l6[1]] = 9
		encoder[0] = l6[0]
		decoder[l6[0]] = 0
	}

	// 3 has all bits from 1 set, 2 and 5 do not
	for i, p := range l5 {
		if p&encoder[1] == encoder[1] {
			encoder[3] = p
			decoder[p] = 3
			l5[i] = l5[len(l5)-1]
			l5 = l5[:len(l5)-1]
			break
		}
	}

	AssertSliceLength(l5, 2)

	// 6 has all bits of 5 set, but not of 2
	if l5[0]&encoder[6] == l5[0] {
		encoder[5] = l5[0]
		decoder[l5[0]] = 5
		encoder[2] = l5[1]
		decoder[l5[1]] = 2
	} else {
		encoder[5] = l5[1]
		decoder[l5[1]] = 5
		encoder[2] = l5[0]
		decoder[l5[0]] = 2
	}

	for i := 0; i < 10; i++ {
		if decoder[encoder[i]] != i {
			panic(fmt.Sprintf("no valid decoding for %d", i))
		}
	}

	return decoder
}

func AssertSliceLength(slice []Pattern, n int) {
	if len(slice) != n {
		panic(fmt.Sprintf("expected slice length %d, got %d", n, len(slice)))
	}
}

func EvaluateEntry(entry string) (int, int) {
	parts := strings.FieldsFunc(entry, func(r rune) bool { return r == '|' })
	if len(parts) != 2 {
		panic(fmt.Sprintf("invalid entry with %d parts", len(parts)))
	}

	patterns := PatternsFromStrings(strings.Fields(parts[0]))
	outputs := PatternsFromStrings(strings.Fields(parts[1]))

	if len(patterns) == 0 || len(outputs) == 0 {
		panic(fmt.Sprintf("invalid entry %s", entry))
	}

	decoder := NewPatternDecoder(patterns)
	var uniques, value int

	for i, val := range outputs {
		n, ok := decoder[val]
		if !ok {
			panic(fmt.Sprintf("invalid output value %x", outputs[i]))
		}
		value = 10*value + n

		if n == 1 || n == 4 || n == 7 || n == 8 {
			uniques++
		}
	}

	return uniques, value
}

func main() {
	f, err := os.Open(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	var values, uniques int

	for scanner.Scan() {
		u, v := EvaluateEntry(scanner.Text())
		uniques += u
		values += v
	}

	if err = scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "input: ", err)
		os.Exit(1)
	}

	fmt.Println("Part 1:", uniques)
	fmt.Println("Part 2:", values)
}
