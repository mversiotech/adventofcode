// Solution for https://adventofcode.com/2021/day/10

package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
)

const InputFile = "../../input/day10.txt"


func lastRune(stack []rune) rune {
	if len(stack) == 0 {
		return 0
	}
	return stack[len(stack)-1]
}

func ErrorScore(line string) (score int) {
	var stack []rune

	for _, r := range line {
		switch r {
		case '(', '[', '{', '<':
			stack = append(stack, r)
		case ')':
			if lastRune(stack) == '(' {
				stack = stack[:len(stack)-1]
			} else {
				return 3
			}
		case ']':
			if lastRune(stack) == '[' {
				stack = stack[:len(stack)-1]
			} else {
				return 57
			}
		case '}':
			if lastRune(stack) == '{' {
				stack = stack[:len(stack)-1]
			} else {
				return 1197
			}
		case '>':
			if lastRune(stack) == '<' {
				stack = stack[:len(stack)-1]
			} else {
				return 25137
			}
		default:
			panic(fmt.Sprintf("invalid character %v", r))
		}
	}

	return 0
}

func CompletionScore(line string) (score int) {
	var stack []rune

	for _, r := range line {
		switch r {
		case '(', '[', '{', '<':
			stack = append(stack, r)
		case ')':
			if lastRune(stack) == '(' {
				stack = stack[:len(stack)-1]
			} else {
				return 0
			}
		case ']':
			if lastRune(stack) == '[' {
				stack = stack[:len(stack)-1]
			} else {
				return 0
			}
		case '}':
			if lastRune(stack) == '{' {
				stack = stack[:len(stack)-1]
			} else {
				return 0
			}
		case '>':
			if lastRune(stack) == '<' {
				stack = stack[:len(stack)-1]
			} else {
				return 0
			}
		default:
			panic(fmt.Sprintf("invalid character %r", r))
		}
	}

	for i := len(stack) - 1; i >= 0; i-- {
		switch stack[i] {
		case '(':
			score = score*5 + 1
		case '[':
			score = score*5 + 2
		case '{':
			score = score*5 + 3
		case '<':
			score = score*5 + 4
		}
	}

	return score
}

func main() {
	f, err := os.Open(InputFile)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)

	var (
		errscore   int
		compscores []int
	)

	for scanner.Scan() {
		line := scanner.Text()

		errscore += ErrorScore(line)
		compscore := CompletionScore(line)

		if compscore > 0 {
			compscores = append(compscores, compscore)
		}
	}

	sort.Ints(compscores)

	fmt.Println("Part 1:", errscore)
	fmt.Println("Part 2:", compscores[len(compscores)/2])
}
