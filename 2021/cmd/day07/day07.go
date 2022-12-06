// Solution for https://adventofcode.com/2021/day/7

package main

import (
	"bytes"
	"fmt"
	"os"
	"sort"
	"strconv"
	"unicode"
)

const (
	InputFile = "../../input/day07.txt"
)

func ReadPositions(filename string) (state []int, err error) {
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	fields := bytes.FieldsFunc(data, func(r rune) bool { return r == ',' || unicode.IsSpace(r) })

	for _, field := range fields {
		n, err := strconv.Atoi(string(field))
		if err != nil {
			return nil, err
		}

		state = append(state, n)
	}

	return state, nil
}

func abs(n int) int {
	if n >= 0 {
		return n
	}
	return -n
}

func sliceMode(slice []int) int {
	if len(slice)%2 == 0 {
		return (slice[len(slice)/2] + slice[len(slice)/2-1]) / 2
	}
	return slice[len(slice)/2]
}

func sliceMean(slice []int) int {
	sum := 0
	for _, n := range slice {
		sum += n
	}

	return sum / len(slice)
}

func fuelCost(x1, x2 int) int {
	n := abs(x2 - x1)
	return n * (n + 1) / 2
}

func main() {
	pos, err := ReadPositions(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
	}

	sort.Ints(pos)

	mode := sliceMode(pos)

	var fuel int
	for _, n := range pos {
		fuel += abs(n - mode)
	}

	fmt.Println("Part 1:", fuel)
	fuel = 0

	mean := sliceMean(pos)

	for _, n := range pos {
		fuel += fuelCost(n, mean)
	}

	fmt.Println("Part 2:", fuel)
}
