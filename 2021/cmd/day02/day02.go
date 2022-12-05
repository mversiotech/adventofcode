// Solution for https://adventofcode.com/2021/day/2

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

const InputFile = "../../input/day02.txt"

type Direction int

const (
	Forward Direction = iota
	Down
	Up
)

type Command struct {
	Dir   Direction
	Delta int
}

func ParseCommand(line string) (*Command, error) {
	fields := strings.Fields(line)
	if len(fields) != 2 {
		return nil, fmt.Errorf("invalid line: " + line)
	}

	var c Command

	switch fields[0] {
	case "forward":
		c.Dir = Forward
	case "down":
		c.Dir = Down
	case "up":
		c.Dir = Up
	default:
		return nil, fmt.Errorf("unknown command \"%s\"", fields[0])
	}

	delta, err := strconv.Atoi(fields[1])
	if err != nil {
		return nil, err
	}
	c.Delta = delta

	return &c, nil
}

type Submarine struct {
	Aim   int
	HPos  int
	Depth int
}

func (s *Submarine) SteerDirectly(cmd *Command) {
	switch cmd.Dir {
	case Forward:
		s.HPos += cmd.Delta
	case Down:
		s.Depth += cmd.Delta
	case Up:
		s.Depth -= cmd.Delta
	}
}

func (s *Submarine) SteerWithAim(cmd *Command) {
	switch cmd.Dir {
	case Forward:
		s.HPos += cmd.Delta
		s.Depth += s.Aim * cmd.Delta
	case Down:
		s.Aim += cmd.Delta
	case Up:
		s.Aim -= cmd.Delta
	}
}

func main() {
	f, err := os.Open(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, "cannot open input: %v\n", err)
		os.Exit(1)
	}
	defer f.Close()

	var subs [2]Submarine

	scanner := bufio.NewScanner(f)

	for scanner.Scan() {
		cmd, err := ParseCommand(scanner.Text())
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}

		subs[0].SteerDirectly(cmd)
		subs[1].SteerWithAim(cmd)
	}

	if err = scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fmt.Println("Part 1:", subs[0].HPos*subs[0].Depth)
	fmt.Println("Part 2:", subs[1].HPos*subs[1].Depth)
}
