import gleam/list
import gleam/string

pub type Pixels =
  List(List(Bool))

const braille_pattern_base = 0x2800

// Braille pattern bit values
// 0x01  0x08
// 0x02  0x10
// 0x04  0x20
// 0x40  0x80
const braille_pattern_weights = [0x01, 0x08, 0x02, 0x10, 0x04, 0x20, 0x40, 0x80]

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
