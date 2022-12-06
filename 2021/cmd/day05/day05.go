// Solution for https://adventofcode.com/2021/day/5

package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
)

const InputFile = "../../input/day05.txt"

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func sign(n int) int {
	switch {
	case n < 0:
		return -1
	case n > 0:
		return 1
	default:
		return 0
	}
}

type Point struct {
	X, Y int
}

type Line struct {
	P1, P2 Point
}

func (l *Line) IsAxisAligned() bool {
	return l.P1.X == l.P2.X || l.P1.Y == l.P2.Y
}

func (l *Line) Draw(grid []uint8, bounds Point) {
	v := Point{l.P2.X - l.P1.X, l.P2.Y - l.P1.Y}
	step := Point{sign(v.X), sign(v.Y)}

	p := l.P1
	for p != l.P2 {
		grid[p.Y*bounds.X+p.X]++
		p.X += step.X
		p.Y += step.Y
	}

	grid[p.Y*bounds.X+p.X]++
}

var lineRx = regexp.MustCompile(`(\d+),(\d+)\s*->\s*(\d+),(\d+)`)

func ParseLine(s string) (*Line, error) {
	matches := lineRx.FindStringSubmatch(s)
	if len(matches) != 5 {
		return nil, fmt.Errorf("invalid formatted line \"%s\"", s)
	}

	var coords [4]int

	for i := 1; i < len(matches); i++ {
		c, err := strconv.Atoi(matches[i])
		if err != nil {
			return nil, fmt.Errorf("invalid formatted line \"%s\" (%w)", s, err)
		}

		coords[i-1] = c
	}

	l := &Line{
		P1: Point{coords[0], coords[1]},
		P2: Point{coords[2], coords[3]},
	}

	return l, nil
}

func ParseLinesFile(filename string) (lines []*Line, err error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		l, err := ParseLine(scanner.Text())
		if err != nil {
			return nil, err
		}

		lines = append(lines, l)
	}

	if err = scanner.Err(); err != nil {
		return nil, err
	}

	return lines, nil
}

func countOverlaps(grid []uint8) int {
	var count int
	for _, u := range grid {
		if u > 1 {
			count++
		}
	}
	return count
}

func main() {
	lines, err := ParseLinesFile(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, "cannot parse input file: ", err)
		os.Exit(1)
	}

	bounds := Point{}
	for _, l := range lines {
		bounds.X = max(bounds.X, max(l.P1.X, l.P2.X)+1)
		bounds.Y = max(bounds.Y, max(l.P1.Y, l.P2.Y)+1)
	}

	grid := make([]uint8, bounds.X*bounds.Y)

	for _, l := range lines {
		if l.IsAxisAligned() {
			l.Draw(grid, bounds)
		}
	}

	fmt.Println("Part 1:", countOverlaps(grid))

	for _, l := range lines {
		if !l.IsAxisAligned() {
			l.Draw(grid, bounds)
		}
	}

	fmt.Println("Part 2:", countOverlaps(grid))
}
