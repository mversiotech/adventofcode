// Solution for https://adventofcode.com/2021/day/13

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

const InputFile = "../../input/day13.txt"

type Point struct {
	X, Y uint32
}

type PointSet map[Point]struct{}

type Axis int

const (
	XAxis Axis = iota
	YAxis
)

type FoldCmd struct {
	Axis Axis
	Pos  uint32
}

func (cmd FoldCmd) Exec(points PointSet) {
	var newpoint Point

	for oldpoint := range points {
		if cmd.Axis == XAxis {
			if oldpoint.X < cmd.Pos {
				continue
			}
			newpoint.X = oldpoint.X - 2*(oldpoint.X-cmd.Pos)
			newpoint.Y = oldpoint.Y
		} else {
			if oldpoint.Y < cmd.Pos {
				continue
			}
			newpoint.X = oldpoint.X
			newpoint.Y = oldpoint.Y - 2*(oldpoint.Y-cmd.Pos)
		}
		delete(points, oldpoint)
		points[newpoint] = struct{}{}
	}
}

func ParseFoldCmd(s string) (FoldCmd, error) {
	var cmd FoldCmd

	eq := strings.IndexByte(s, '=')
	if eq < 1 {
		return cmd, fmt.Errorf("invalid fold command: " + s)
	}

	switch s[eq-1] {
	case 'x':
		cmd.Axis = XAxis
	case 'y':
		cmd.Axis = YAxis
	default:
		return cmd, fmt.Errorf("invalid fold command: " + s)
	}

	pos, err := strconv.ParseUint(s[eq+1:], 10, 32)
	if err != nil {
		return cmd, fmt.Errorf("invalid fold command: %s (%w)", s, err)
	}
	cmd.Pos = uint32(pos)

	return cmd, nil
}

func ParseInput(filename string) (PointSet, []FoldCmd, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, nil, err
	}
	defer f.Close()

	points := make(map[Point]struct{})
	var cmds []FoldCmd

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		if len(line) == 0 {
			continue
		}

		if strings.HasPrefix(line, "fold along ") {
			cmd, err := ParseFoldCmd(line)
			if err != nil {
				return nil, nil, err
			}
			cmds = append(cmds, cmd)
			continue
		}

		comma := strings.IndexByte(line, ',')
		if comma == -1 {
			return nil, nil, fmt.Errorf("invalid input line" + scanner.Text())
		}

		x, err := strconv.ParseUint(line[:comma], 10, 32)
		if err != nil {
			return nil, nil, fmt.Errorf("invalid input line" + scanner.Text())
		}

		y, err := strconv.ParseUint(line[comma+1:], 10, 32)
		if err != nil {
			return nil, nil, fmt.Errorf("invalid input line" + scanner.Text())
		}

		points[Point{X: uint32(x), Y: uint32(y)}] = struct{}{}
	}
	if err = scanner.Err(); err != nil {
		return nil, nil, err
	}

	return points, cmds, nil
}

func PrintPoints(points PointSet) {
	var max Point

	for p := range points {
		if p.X > max.X {
			max.X = p.X
		}
		if p.Y > max.Y {
			max.Y = p.Y
		}
	}

	for y := uint32(0); y <= max.Y; y++ {
		for x := uint32(0); x <= max.X; x++ {
			if _, ok := points[Point{x, y}]; ok {
				fmt.Print("#")
			} else {
				fmt.Print(".")
			}
		}
		fmt.Println()
	}
}

func main() {
	points, cmds, err := ParseInput(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	for i, cmd := range cmds {
		cmd.Exec(points)

		if i == 0 {
			fmt.Printf("Part 1: %d points\n", len(points))
		}
	}

	fmt.Println("Part 2:")
	PrintPoints(points)
}
