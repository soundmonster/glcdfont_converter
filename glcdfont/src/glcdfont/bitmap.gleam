import gleam/list
import gleam/string

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
  0b010000000,
  0b10000000,
]

pub fn pixels_to_bit_arrays(pixels: Pixels) -> List(List(List(Int))) {
  pixels
  |> list.map(list.sized_chunk(_, 8))
  |> list.map(
    list.map(_, fn(byte) {
      byte
      |> list.reverse
      |> list.map2(bitwise, fn(x, y) {
        case x {
          True -> y
          False -> 0
        }
      })
    }),
  )
}
