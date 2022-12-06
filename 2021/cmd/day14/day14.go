// Solution for https://adventofcode.com/2021/day/14

package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strings"
)

const InputFile = "../../input/day14.txt"

func ParseInput(filename string) (template string, rules map[string]byte, err error) {
	f, err := os.Open(filename)
	if err != nil {
		return "", nil, err
	}
	defer f.Close()

	rules = make(map[string]byte)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if len(template) == 0 {
			template = line
			continue
		}

		if len(line) == 0 {
			continue
		}

		if len(line) != 7 || strings.Index(line, " -> ") != 2 {
			return "", nil, fmt.Errorf("invalid input line " + line)
		}

		rules[line[:2]] = line[6]
	}
	if err = scanner.Err(); err != nil {
		return "", nil, err
	}

	return template, rules, nil
}

func PairCounts(s string) map[string]int {
	counts := make(map[string]int)

	for i := 0; i < len(s)-1; i++ {
		counts[s[i:i+2]]++
	}

	return counts
}

func ApplyRules(pairs map[string]int, rules map[string]byte) map[string]int {
	newpairs := make(map[string]int)

	for pair, count := range pairs {
		b, ok := rules[pair]
		if !ok {
			newpairs[pair] += count
			continue
		}

		new1 := string([]byte{pair[0], b})
		new2 := string([]byte{b, pair[1]})

		newpairs[new1] += count
		newpairs[new2] += count
	}

	return newpairs
}

func MinMaxChar(pairs map[string]int, lastchar byte) (min, max int) {
	counts := make(map[byte]int)
	counts[lastchar] = 1

	for pair, count := range pairs {
		counts[pair[0]] += count
	}

	min = math.MaxInt

	for _, count := range counts {
		if count < min {
			min = count
		}
		if count > max {
			max = count
		}
	}

	return min, max
}

func main() {
	template, rules, err := ParseInput(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	pairs := PairCounts(template)

	for i := 0; i < 40; i++ {
		pairs = ApplyRules(pairs, rules)

		if i == 9 {
			min, max := MinMaxChar(pairs, template[len(template)-1])
			fmt.Println("Part 1: ", max-min)
		}
	}

	min, max := MinMaxChar(pairs, template[len(template)-1])
	fmt.Println("Part 2: ", max-min)
}
