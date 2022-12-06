// Solution for https://adventofcode.com/2021/day/17

package main

import (
	"fmt"
	"math"
	"os"
	"runtime"
)

const (
	InputFile   = "../../input/day17.txt"
	InputFormat = "target area: x=%d..%d, y=%d..%d"
)

type TargetArea struct {
	XMin, XMax int
	YMin, YMax int
}

func ReadTargetArea(filename string) (*TargetArea, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var ta TargetArea
	_, err = fmt.Fscanf(f, InputFormat, &ta.XMin, &ta.XMax, &ta.YMin, &ta.YMax)
	if err != nil {
		return nil, err
	}
	return &ta, nil
}

func (ta *TargetArea) CanHit(vx, vy int) bool {
	var px, py, stepx int

	if vx < 0 {
		stepx = 1
	} else if vx > 0 {
		stepx = -1
	}

	for {
		px += vx
		py += vy

		if vx != 0 {
			vx += stepx
		}
		vy--

		if px < ta.XMin || py > ta.YMax {
			continue
		}

		return px <= ta.XMax && py >= ta.YMin
	}
}

func abs(n int) int {
	if n < 0 {
		return -n
	}
	return n
}

func main() {
	ta, err := ReadTargetArea(InputFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s: %v\n", InputFile, err)
		os.Exit(1)
	}

	vxmin := int(math.Ceil(-0.5 + math.Sqrt(0.25+float64(ta.XMin*2))))
	vxmax := ta.XMax
	vymin := ta.YMin
	vymax := abs(((ta.YMin) * (abs(ta.YMin) - 1)) / 2)

	fmt.Println("Part 1:", vymax)

	sum := make(chan int)

	ncpu := runtime.NumCPU()
	for cpu := 0; cpu < ncpu; cpu++ {
		go func(offset int) {
			var hits int

			for vy := vymin + offset; vy <= vymax; vy += ncpu {
				for vx := vxmin; vx <= vxmax; vx++ {
					if ta.CanHit(vx, vy) {
						hits++
					}
				}
			}

			sum <- hits
		}(cpu)
	}

	var hits int

	for cpu := 0; cpu < ncpu; cpu++ {
		hits += <-sum
	}

	fmt.Println("Part 2:", hits)
}
