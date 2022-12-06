// Solution for https://adventofcode.com/2021/day/12

package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

const InputFile = "../../input/day12.txt"

type Node struct {
	Name    string
	Visited bool
	Edges   []*Node
}

func (n *Node) IsSmall() bool {
	return len(n.Name) > 0 && n.Name[0] >= 'a' && n.Name[0] <= 'z'
}

func CountValidPaths(from *Node, allowTwice bool) int {
	if from.Name == "end" {
		return 1
	}

	prev := from.Visited
	if prev {
		if from.IsSmall() {
			if !allowTwice || from.Name == "start" {
				return 0
			}

			allowTwice = false
		}
	}

	from.Visited = true

	var subpaths int
	for _, n := range from.Edges {
		subpaths += CountValidPaths(n, allowTwice)
	}

	from.Visited = prev
	return subpaths
}

func ReadGraph(filename string) (nodes map[string]*Node, err error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	nodes = make(map[string]*Node)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		names := strings.FieldsFunc(scanner.Text(), func(r rune) bool { return r == '-' })
		if len(names) != 2 {
			return nil, fmt.Errorf("invalid path: %s", scanner.Text())
		}

		var path [2]*Node
		for i := 0; i < 2; i++ {
			path[i] = nodes[names[i]]
			if path[i] == nil {
				path[i] = &Node{
					Name: names[i],
				}
				nodes[names[i]] = path[i]
			}
		}
		path[0].Edges = append(path[0].Edges, path[1])
		path[1].Edges = append(path[1].Edges, path[0])
	}

	if err = scanner.Err(); err != nil {
		return nil, err
	}

	return nodes, nil
}

func main() {
	nodes, err := ReadGraph(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	start := nodes["start"]

	fmt.Println("Part 1:", CountValidPaths(start, false))
	fmt.Println("Part 2:", CountValidPaths(start, true))
}
