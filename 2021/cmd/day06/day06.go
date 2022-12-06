// Solution for https://adventofcode.com/2021/day/6

package main

import (
	"bytes"
	"fmt"
	"os"
	"strconv"
	"unicode"
)

const (
	InputFile        = "../../input/day06.txt"
	P1SimulationDays = 80
	P2SimulationDays = 256
)

func ReadInitialState(filename string) (state []int, err error) {
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

func sliceSum(slice []int) (sum int) {
	for _, n := range slice {
		sum += n
	}
	return sum
}

func main() {
	state, err := ReadInitialState(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
	}

	fishperage := make([]int, 9)

	for _, fish := range state {
		fishperage[fish]++
	}

	for i := 0; i < P2SimulationDays; i++ {
		spawn := fishperage[0]
		for j := 0; j < len(fishperage)-1; j++ {
			fishperage[j] = fishperage[j+1]
		}

		fishperage[8] = spawn
		fishperage[6] += spawn

		if i == P1SimulationDays-1 {
			fmt.Println("Part 1:", sliceSum(fishperage))
		}
	}

	fmt.Println("Part 2:", sliceSum(fishperage))
}
