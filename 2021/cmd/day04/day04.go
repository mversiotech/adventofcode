// Solution for https://adventofcode.com/2021/day/4

package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

const (
	InputFile = "../../input/day04.txt"
	BoardSize = 5
)

type Field struct {
	Number uint8
	Marked bool
}

type Board struct {
	Fields []Field
}

func NewBoard(numbers []uint8) *Board {
	if len(numbers) != BoardSize*BoardSize {
		panic("NewBoard: invalid slice length")
	}

	b := &Board{Fields: make([]Field, len(numbers))}

	for i := 0; i < len(numbers); i++ {
		b.Fields[i].Number = numbers[i]
	}

	return b
}

func (b *Board) Mark(number uint8) {
	for i := 0; i < len(b.Fields); i++ {
		if b.Fields[i].Number == number {
			b.Fields[i].Marked = true
			break
		}
	}
}

func (b *Board) Reset() {
	for i := 0; i < len(b.Fields); i++ {
		b.Fields[i].Marked = false
	}
}

func (b *Board) HasWon() bool {
	for row := 0; row < BoardSize; row++ {
		hasUnmarked := false
		for col := 0; col < BoardSize && !hasUnmarked; col++ {
			hasUnmarked = !b.Fields[row*BoardSize+col].Marked
		}

		if !hasUnmarked {
			return true
		}
	}

	for col := 0; col < BoardSize; col++ {
		hasUnmarked := false
		for row := 0; row < BoardSize && !hasUnmarked; row++ {
			hasUnmarked = !b.Fields[row*BoardSize+col].Marked
		}

		if !hasUnmarked {
			return true
		}
	}

	return false
}

func (b *Board) Score() (score int) {
	for _, f := range b.Fields {
		if !f.Marked {
			score += int(f.Number)
		}
	}

	return score
}

func ParseInput(filename string) (randnums []uint8, boards []*Board, err error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, nil, err
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)

	randnums, err = readRandomNumbers(scanner)
	if err != nil {
		return nil, nil, err
	}

	for {
		board, err := readBoard(scanner)
		if err != nil {
			return nil, nil, err
		}

		if board == nil {
			break
		}

		boards = append(boards, board)
	}

	if len(boards) == 0 {
		return nil, nil, fmt.Errorf("empty list of boards")
	}

	return randnums, boards, nil
}

func readRandomNumbers(scanner *bufio.Scanner) ([]uint8, error) {
	var randnums []uint8

	if !scanner.Scan() {
		return nil, fmt.Errorf("scanning error: %w", scanner.Err())
	}

	fields := strings.FieldsFunc(scanner.Text(), func(r rune) bool {
		return r == ','
	})

	for _, field := range fields {
		num, err := strconv.ParseUint(field, 10, 8)
		if err != nil {
			return nil, err
		}

		randnums = append(randnums, uint8(num))
	}

	if len(randnums) == 0 {
		return nil, fmt.Errorf("empty list of random guesses")
	}

	return randnums, nil
}

func readBoard(scanner *bufio.Scanner) (*Board, error) {
	var boardnums []uint8

	expect := BoardSize * BoardSize

	for len(boardnums) < expect && scanner.Scan() {
		fields := strings.Fields(scanner.Text())

		if len(fields) == 0 && len(boardnums) == 0 {
			continue
		}

		if len(fields) != BoardSize {
			return nil, fmt.Errorf("format error in input file")
		}

		for _, field := range fields {
			num, err := strconv.ParseUint(field, 10, 8)
			if err != nil {
				return nil, err
			}

			boardnums = append(boardnums, uint8(num))
		}
	}

	if err := scanner.Err(); err != nil {
		return nil, err
	}

	switch len(boardnums) {
	case 0:
		return nil, nil
	case expect:
		return NewBoard(boardnums), nil
	default:
		return nil, fmt.Errorf("unexpected EOF")
	}
}

func main() {
	randnums, boards, err := ParseInput(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

part1:
	for _, rand := range randnums {
		for _, board := range boards {
			board.Mark(rand)

			if board.HasWon() {
				fmt.Println("Part 1:", board.Score()*int(rand))
				break part1
			}
		}
	}

	for _, b := range boards {
		b.Reset()
	}

	var (
		lastwinner *Board
		lastbingo  uint8
	)

	for _, rand := range randnums {
		for i := 0; i < len(boards); i++ {
			boards[i].Mark(rand)

			if boards[i].HasWon() {
				lastwinner = boards[i]
				lastbingo = rand
				boards[i] = boards[len(boards)-1]
				boards = boards[:len(boards)-1]
				i--
			}
		}
	}

	if lastwinner == nil {
		fmt.Fprintln(os.Stderr, "No winner")
		os.Exit(1)
	}

	fmt.Println("Part 2:", lastwinner.Score()*int(lastbingo))
}
