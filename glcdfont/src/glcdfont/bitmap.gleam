import gleam/bit_array
import gleam/list
import gleam/result
import gleam/string
import pngleam

pub type Pixels =
  List(List(Bool))

const braille_pattern_base: Int = 0x2800

// Braille pattern bit values
// 0x01  0x08
// 0x02  0x10
// 0x04  0x20
// 0x40  0x80
const braille_pattern_weights: List(Int) = [
  0x01,
  0x08,
  0x02,
  0x10,
  0x04,
  0x20,
  0x40,
  0x80,
]

/// Convert pixels to a pseudographic form suitable for printing to a terminal
pub fn pixels_to_pseudographics(pixels: List(List(Bool))) -> List(String) {
  pixels
  |> list.map(list.sized_chunk(_, 2))
  |> list.sized_chunk(4)
  |> list.map(fn(pseudographic_row) {
    pseudographic_row
    |> list.transpose()
    |> list.map(list.flatten)
    |> list.map(list.zip(_, braille_pattern_weights))
    |> list.filter_map(fn(cell) {
      let flags =
        list.fold(cell, 0, fn(acc, pair) {
          case pair {
            #(True, weight) -> acc + weight
            #(False, _) -> acc
          }
        })
      string.utf_codepoint(braille_pattern_base + flags)
    })
    |> string.from_utf_codepoints
  })
}

const bitwise: List(Int) = [
  0b00000001,
  0b00000010,
  0b00000100,
  0b00001000,
  0b00010000,
  0b00100000,
  0b01000000,
  0b10000000,
]

pub fn pixels_to_bit_arrays(pixels: Pixels) -> List(BitArray) {
  pixels
  |> list.map(fn(row) {
    row
    |> list.sized_chunk(8)
    |> list.map(fn(byte) {
      byte
      |> list.reverse
      |> list.map2(bitwise, fn(x, y) {
        case x {
          True -> y
          False -> 0
        }
      })
      |> list.fold(0, fn(x, y) { x + y })
    })
    |> list.fold(<<>>, fn(acc, x) { bit_array.append(acc, <<x>>) })
  })
}

pub fn pixels_to_png(pixels: Pixels) -> Result(BitArray, Nil) {
  let bits = pixels_to_bit_arrays(pixels)
  let height = list.length(bits)
  use first_row <- result.try(list.first(bits))
  let width = bit_array.bit_size(first_row)
  use color_info <- result.try(pngleam.color_info(pngleam.Greyscale, 1))

  bits
  |> pngleam.from_packed(width, height, color_info, pngleam.default_compression)
  |> Ok
}
