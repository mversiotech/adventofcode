// Solution for https://adventofcode.com/2021/day/15
// Implements A* over a square grid

package main

import (
	"bufio"
	"container/heap"
	"fmt"
	"os"
)

const InputFile = "../../input/day15.txt"

type Point struct {
	X, Y uint32
}

func ManhattanDist(a, b Point) uint {
	diff := func(a, b uint32) uint {
		if a > b {
			return uint(a - b)
		}
		return uint(b - a)
	}

	return diff(a.X, b.X) + diff(a.Y, b.Y)
}

type PPoint struct {
	Point
	Priority uint // Lower value = higher priority
}

type PQueue []PPoint

func (q PQueue) Len() int {
	return len(q)
}

func (q PQueue) Less(i, j int) bool {
	return q[i].Priority < q[j].Priority
}

func (q PQueue) Swap(i, j int) {
	q[i], q[j] = q[j], q[i]
}

func (q *PQueue) Push(x any) {
	*q = append(*q, x.(PPoint))
}

func (q *PQueue) Pop() any {
	n := len(*q) - 1
	p := (*q)[n]
	*q = (*q)[:n]
	return p
}

type Cave struct {
	Width, Height uint32
	Nodes         []uint8
}

func (c *Cave) RiskAt(p Point) uint8 {
	return c.Nodes[p.Y*c.Width+p.X]
}

func (c *Cave) Neighbors(p Point) []Point {
	if p.X < 0 || p.Y < 0 || p.X >= c.Width || p.Y >= c.Height {
		panic("point out of range")
	}

	n := make([]Point, 0, 4)

	if p.X > 0 {
		n = append(n, Point{p.X - 1, p.Y})
	}

	if p.X < c.Width-1 {
		n = append(n, Point{p.X + 1, p.Y})
	}

	if p.Y > 0 {
		n = append(n, Point{p.X, p.Y - 1})
	}

	if p.Y < c.Height-1 {
		n = append(n, Point{p.X, p.Y + 1})
	}

	return n
}

func (c *Cave) CostBetween(start, end Point) uint {
	q := make(PQueue, 0)
	heap.Init(&q)
	heap.Push(&q, PPoint{Point: start, Priority: 0})

	pathCost := make([]uint, len(c.Nodes))

	for q.Len() > 0 {
		current := heap.Pop(&q).(PPoint)

		if current.Point == end {
			return pathCost[end.Y*c.Width+end.X]
		}

		nb := c.Neighbors(current.Point)
		for _, next := range nb {
			cost := pathCost[current.Y*c.Width+current.X] + uint(c.RiskAt(next))
			nextCost := pathCost[next.Y*c.Width+next.X]
			if nextCost == 0 || cost < nextCost {
				pathCost[next.Y*c.Width+next.X] = cost
				priority := cost + ManhattanDist(end, next)
				heap.Push(&q, PPoint{Point: next, Priority: priority})
			}
		}
	}

	panic("target node unreachable")
}

func (c *Cave) Expanded(ntimes uint32) *Cave {
	nc := &Cave{
		Width:  c.Width * ntimes,
		Height: c.Height * ntimes,
	}
	nc.Nodes = make([]uint8, nc.Width*nc.Height)

	for y := uint32(0); y < nc.Height; y++ {
		dy := y / c.Height
		oy := y % c.Height
		for x := uint32(0); x < nc.Width; x++ {
			dx := x / c.Width
			ox := x % c.Width

			risk := c.RiskAt(Point{ox, oy}) - 1
			risk += uint8(dx + dy)
			risk = risk%9 + 1

			nc.Nodes[y*nc.Width+x] = risk
		}
	}

	return nc
}

func ReadCave(filename string) (*Cave, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var cave Cave

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		if cave.Width == 0 {
			cave.Width = uint32(len(line))
			cave.Nodes = make([]uint8, 0, cave.Width*cave.Width)
		} else if int(cave.Width) != len(line) {
			return nil, fmt.Errorf("non-rectangular cave")
		}

		for _, r := range line {
			if r < '0' || r > '9' {
				return nil, fmt.Errorf("invalid data")
			}
			cave.Nodes = append(cave.Nodes, uint8(r-'0'))
		}

		cave.Height++
	}
	if err = scanner.Err(); err != nil {
		return nil, err
	}

	return &cave, nil
}

func main() {
	cave, err := ReadCave(InputFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%s: %v\n", InputFile, err)
		os.Exit(1)
	}

	start := Point{X: 0, Y: 0}
	end := Point{X: cave.Width - 1, Y: cave.Height - 1}

	fmt.Println("Part 1: ", cave.CostBetween(start, end))

	expanded := cave.Expanded(5)
	end = Point{X: expanded.Width - 1, Y: expanded.Height - 1}

	fmt.Println("Part 2: ", expanded.CostBetween(start, end))
}
