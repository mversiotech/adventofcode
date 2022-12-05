// Solution for https://adventofcode.com/2021/day/1

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

const InputFile = "../../input/day01.txt"

func main() {
	depths, err := readDepths(InputFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "cannot read input: %v\n", err)
		os.Exit(1)
	}

	var incr int

	for i := 1; i < len(depths); i++ {
		if depths[i] > depths[i-1] {
			incr++
		}
	}

	fmt.Println("Part 1:", incr)

	incr = 0

	for i := 0; i < len(depths)-3; i++ {
		first := sliceSum(depths[i : i+3])
		second := sliceSum(depths[i+1 : i+4])

		if second > first {
			incr++
		}
	}

	fmt.Println("Part 2:", incr)
}

func sliceSum(s []int) (sum int) {
	for _, i := range s {
		sum += i
	}
	return sum
}

func readDepths(filename string) ([]int, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}

	var depths []int

	scanner := bufio.NewScanner(f)

	for scanner.Scan() {
		d, err := strconv.Atoi(scanner.Text())
		if err != nil {
			return nil, err
		}

		depths = append(depths, d)
	}

	if err = scanner.Err(); err != nil {
		return nil, err
	}

	return depths, nil
}
