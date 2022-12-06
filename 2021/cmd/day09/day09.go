// Solution for https://adventofcode.com/2021/day/9

package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
)

const (
	InputFile = "../../input/day09.txt"
	MaxHeight = 9
)

type Point struct {
	X, Y int
}

type Heightmap struct {
	Width  int
	Height int
	Data   []int
}

func (h *Heightmap) Contains(p Point) bool {
	return p.X >= 0 && p.Y >= 0 && p.X < h.Width && p.Y < h.Height
}

func (h *Heightmap) HeightAt(p Point) int {
	return h.Data[p.Y*h.Width+p.X]
}

func (h *Heightmap) SetHeightAt(p Point, n int) {
	h.Data[p.Y*h.Width+p.X] = n
}

func (h *Heightmap) IsLowPoint(p Point) bool {
	center := h.HeightAt(p)
	neighbors := []Point{
		{X: p.X - 1, Y: p.Y},
		{X: p.X + 1, Y: p.Y},
		{X: p.X, Y: p.Y - 1},
		{X: p.X, Y: p.Y + 1},
	}

	for _, n := range neighbors {
		if h.Contains(n) && h.HeightAt(n) <= center {
			return false
		}
	}

	return true
}

func (h *Heightmap) FirstBelow(n int) (Point, bool) {
	for y := 0; y < h.Height; y++ {
		for x := 0; x < h.Width; x++ {
			p := Point{x, y}
			if h.HeightAt(p) < n {
				return p, true
			}
		}
	}

	return Point{}, false
}

func ReadHeightmap(filename string) (*Heightmap, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	h := new(Heightmap)

	scanner := bufio.NewScanner(f)

	for scanner.Scan() {
		h.Height++
		line := scanner.Bytes()
		if len(line) != h.Width {
			if h.Width == 0 {
				h.Width = len(line)
			} else {
				return nil, fmt.Errorf("non-rectangular input data")
			}
		}

		for _, b := range line {
			if b >= '0' && b <= '9' {
				h.Data = append(h.Data, int(b-'0'))
			} else {
				return nil, fmt.Errorf("invalid byte %b in input data", b)
			}
		}
	}

	if err = scanner.Err(); err != nil {
		return nil, fmt.Errorf("read error: %w", err)
	}

	return h, nil
}

func main() {
	h, err := ReadHeightmap(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	var riskSum int

	for y := 0; y < h.Height; y++ {
		for x := 0; x < h.Width; x++ {
			if h.IsLowPoint(Point{x, y}) {
				riskSum += 1 + h.HeightAt(Point{x, y})
			}
		}
	}

	fmt.Println("Part 1:", riskSum)

	var sizes []int

	for {
		var stack []Point

		p, ok := h.FirstBelow(MaxHeight)
		if !ok {
			break
		}
		h.SetHeightAt(p, MaxHeight)

		stack = append(stack, p)

		for i := 0; i < len(stack); i++ {
			p = stack[i]

			neighbors := []Point{
				{X: p.X - 1, Y: p.Y},
				{X: p.X + 1, Y: p.Y},
				{X: p.X, Y: p.Y - 1},
				{X: p.X, Y: p.Y + 1},
			}

			for _, n := range neighbors {
				if h.Contains(n) && h.HeightAt(n) != MaxHeight {
					h.SetHeightAt(n, MaxHeight)
					stack = append(stack, n)
				}
			}
		}

		sizes = append(sizes, len(stack))
	}

	sort.Sort(sort.Reverse(sort.IntSlice(sizes)))

	prod := 1

	for i := 0; i < 3 && i < len(sizes); i++ {
		prod *= sizes[i]
	}

	fmt.Println("Part 2:", prod)
}
