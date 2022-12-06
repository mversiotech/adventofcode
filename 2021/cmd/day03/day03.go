// Solution for https://adventofcode.com/2021/day/3

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

const (
	InputFile  = "../../input/day03.txt"
	FieldWidth = 12
)

func main() {
	f, err := os.Open(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	var numbers []uint
	lines := 0

	scanner := bufio.NewScanner(f)

	for scanner.Scan() {
		lines++
		num, err := strconv.ParseUint(scanner.Text(), 2, FieldWidth)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}

		numbers = append(numbers, uint(num))
	}

	if err = scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	var gamma uint

	for i := 0; i < FieldWidth; i++ {
		gamma <<= 1
		mc, _ := countBits(numbers, i)
		gamma |= uint(mc)
	}

	epsilon := ^gamma & ((1 << FieldWidth) - 1)

	fmt.Println("Part 1:", gamma*epsilon)

	oxygen := numbers

	for pos := 0; pos < FieldWidth && len(oxygen) > 1; pos++ {
		mc, _ := countBits(oxygen, pos)
		oxygen = filter(oxygen, mc, pos)
	}

	if len(oxygen) != 1 {
		fmt.Fprintln(os.Stderr, "oxygen ", len(oxygen))
		os.Exit(1)
	}

	scrubber := numbers

	for pos := 0; pos < FieldWidth && len(scrubber) > 1; pos++ {
		_, lc := countBits(scrubber, pos)
		scrubber = filter(scrubber, lc, pos)
	}

	if len(scrubber) != 1 {
		fmt.Fprintln(os.Stderr, "scrubber ", len(scrubber))
		os.Exit(1)
	}

	fmt.Println("Part 2:", oxygen[0]*scrubber[0])
}

func countBits(numbers []uint, pos int) (mostCommon, leastCommon uint8) {
	var ones, zeroes int

	for _, n := range numbers {
		if (n>>(FieldWidth-1-pos))&1 == 0 {
			zeroes++
		} else {
			ones++
		}
	}

	if ones >= zeroes {
		mostCommon = 1
	} else {
		leastCommon = 1
	}

	return mostCommon, leastCommon
}

func filter(numbers []uint, bit uint8, pos int) []uint {
	var filtered []uint

	for _, n := range numbers {
		if (n>>(FieldWidth-1-pos))&1 == uint(bit) {
			filtered = append(filtered, n)
		}
	}

	return filtered
}
