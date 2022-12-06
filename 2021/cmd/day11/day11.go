// Solution for https://adventofcode.com/2021/day/11

package main

import (
	"fmt"
	"os"
)

const (
	InputFile = "../../input/day11.txt"
	CaveSize  = 10
	Steps     = 100
)

var stepCount uint32

type Octopus struct {
	Energy    uint32
	Lastflash uint32
}

func ReadOctos(filename string) ([]Octopus, error) {
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	octos := make([]Octopus, CaveSize*CaveSize)
	numoctos := 0

	for _, b := range data {
		if b == '\n' || b == '\r' {
			continue
		}

		if b < '0' || b > '9' {
			return nil, fmt.Errorf("invalid byte %b in cave file", b)
		}

		octos[numoctos] = Octopus{Energy: uint32(b - '0')}
		numoctos++

		if numoctos == len(octos) {
			break
		}
	}

	return octos, nil
}

func Step(octos []Octopus) (flashCount int) {
	var stack []int

	for i := 0; i < len(octos); i++ {
		octos[i].Energy++
		if octos[i].Energy > 9 {
			octos[i].Lastflash = stepCount
			stack = append(stack, i)
			flashCount++
		}
	}

	for si := 0; si < len(stack); si++ {
		px := stack[si] % CaveSize
		py := stack[si] / CaveSize

		for y := py - 1; y <= py+1; y++ {
			if y < 0 || y >= CaveSize {
				continue
			}

			for x := px - 1; x <= px+1; x++ {
				if x < 0 || x >= CaveSize || (x == px && y == py) {
					continue
				}

				i := y*CaveSize + x
				octos[i].Energy++
				if octos[i].Energy > 9 && octos[i].Lastflash != stepCount {
					octos[i].Lastflash = stepCount
					stack = append(stack, i)
					flashCount++
				}
			}
		}
	}

	for i := 0; i < len(octos); i++ {
		if octos[i].Energy > 9 {
			octos[i].Energy = 0
		}
	}

	return flashCount
}

func AllFlashed(octos []Octopus) bool {
	for i := 0; i < len(octos); i++ {
		if octos[i].Energy != 0 {
			return false
		}
	}
	return true
}

func main() {
	octos, err := ReadOctos(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, "cannot read octos: ", err)
		os.Exit(1)
	}

	var flashCount int

	for {
		stepCount++
		flashCount += Step(octos)

		if stepCount == 100 {
			fmt.Println(flashCount, "flashes after 100 steps")
		}

		if AllFlashed(octos) {
			fmt.Println("All flashed after step", stepCount)
			break
		}
	}
}
