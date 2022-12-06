// Solution for https://adventofcode.com/2021/day/16

package main

import (
	"encoding/hex"
	"fmt"
	"os"
)

const InputFile = "../../input/day16.txt"

type LengthType uint8

const (
	BitLength LengthType = iota
	PacketCount
)

type PacketType uint8

const (
	SumType PacketType = iota
	ProductType
	MinimumType
	MaximumType
	LiteralType
	GreaterType
	LesserType
	EqualType
)

const (
	HeaderBits      = 6
	BitLengthBits   = 15
	PacketCountBits = 11
)

type Header struct {
	Version uint8
	TypeID  PacketType
}

func ReadHeader(data []byte, bitpos uint) Header {
	var h Header

	h.Version = Bit(data, bitpos+0) << 2
	h.Version |= Bit(data, bitpos+1) << 1
	h.Version |= Bit(data, bitpos+2)

	id := Bit(data, bitpos+3) << 2
	id |= Bit(data, bitpos+4) << 1
	id |= Bit(data, bitpos+5)
	h.TypeID = PacketType(id)

	return h
}

type Packet struct {
	Header
	Value uint
	Sub   []*Packet
}

func ReadPacket(data []byte, bitpos, maxbits, maxsubs uint) (*Packet, uint) {
	h := ReadHeader(data, bitpos)
	if h.TypeID == LiteralType {
		v, n := ReadVarUint(data, bitpos+HeaderBits)
		return &Packet{Header: h, Value: v}, n + HeaderBits
	}

	current := bitpos + HeaderBits
	ltype := LengthType(Bit(data, current))
	current++

	var subs []*Packet

	if ltype == BitLength {
		max := ReadFixedUint(data, current, BitLengthBits)
		if maxbits > 0 && max > maxbits {
			panic("sub-packet too large")
		}
		current += BitLengthBits

		for max > 0 {
			p, n := ReadPacket(data, current, max, 0)
			if n > max {
				panic("sub-packet too large")
			}

			subs = append(subs, p)
			current += n
			max -= n
		}
	}

	if ltype == PacketCount {
		npkg := ReadFixedUint(data, current, PacketCountBits)
		if maxsubs > 0 && npkg > maxsubs {
			panic("too many sub-packets")
		}
		current += PacketCountBits

		for npkg > 0 {
			p, n := ReadPacket(data, current, 0, 0)
			subs = append(subs, p)
			current += n
			npkg--
		}
	}

	return &Packet{Header: h, Sub: subs}, current - bitpos
}

func (p *Packet) Print(prefix string) {
	fmt.Printf("%sVersion: %d\n", prefix, p.Version)
	fmt.Printf("%sTypeID: %d\n", prefix, p.TypeID)

	if p.TypeID == LiteralType {
		fmt.Printf("%sValue: %d\n", prefix, p.Value)
	}

	for _, sub := range p.Sub {
		sub.Print(prefix + "  ")
	}
}

func (p *Packet) SumOfVersions() uint {
	sum := uint(p.Version)

	for _, sub := range p.Sub {
		sum += sub.SumOfVersions()
	}

	return sum
}

func (p *Packet) Evaluate() (value uint) {
	switch p.TypeID {
	case SumType:
		for _, sub := range p.Sub {
			value += sub.Evaluate()
		}
	case ProductType:
		value = 1
		for _, sub := range p.Sub {
			value *= sub.Evaluate()
		}
	case MinimumType:
		value = ^uint(0)
		for _, sub := range p.Sub {
			e := sub.Evaluate()
			if e < value {
				value = e
			}
		}
	case MaximumType:
		for _, sub := range p.Sub {
			e := sub.Evaluate()
			if e > value {
				value = e
			}
		}
	case LiteralType:
		value = p.Value
	case GreaterType:
		if p.Sub[0].Evaluate() > p.Sub[1].Evaluate() {
			value = 1
		}
	case LesserType:
		if p.Sub[0].Evaluate() < p.Sub[1].Evaluate() {
			value = 1
		}
	case EqualType:
		if p.Sub[0].Evaluate() == p.Sub[1].Evaluate() {
			value = 1
		}
	default:
		panic("unknown packet type")
	}

	return value
}

func ReadVarUint(data []byte, bitpos uint) (u uint, bits uint) {
	current := bitpos
	cont := uint8(1)

	for cont != 0 {
		cont = Bit(data, current)

		var nibble uint8
		nibble = Bit(data, current+1) << 3
		nibble |= Bit(data, current+2) << 2
		nibble |= Bit(data, current+3) << 1
		nibble |= Bit(data, current+4)

		current += 5

		u <<= 4
		u |= uint(nibble)
	}
	return u, current - bitpos
}

func ReadFixedUint(data []byte, bitpos, bits uint) (u uint) {
	for i := uint(0); i < bits; i++ {
		u <<= 1
		u |= uint(Bit(data, bitpos+i))
	}
	return u
}

func Bit(data []byte, n uint) uint8 {
	nbyte := n / 8
	nbit := 7 - n%8

	return (data[nbyte] >> nbit) & 1
}

func main() {
	hexstr, err := os.ReadFile(InputFile)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	n := len(hexstr) - 1 // Skip LF

	data := make([]byte, hex.DecodedLen(n))
	n, err = hex.Decode(data, hexstr[:n])
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	data = data[:n]

	p, _ := ReadPacket(data, 0, 0, 0)

	fmt.Println("Part 1:", p.SumOfVersions())
	fmt.Println("Part 2:", p.Evaluate())
}
