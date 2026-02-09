import glcdfont/bitmap.{type Pixels}
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string

pub type Font {
  Font(glyph_width: Int, glyph_height: Int, glyphs: List(Pixels))
}

pub fn parse_c_file(
  glcd_font_in_c_code: String,
  glyph_width: Int,
  glyph_height: Int,
) -> Result(Font, Nil) {
  use bytes <- result.try(extract_hex_array(glcd_font_in_c_code))
  let glyphs =
    bytes
    |> decode
    |> glyphs(glyph_width, glyph_height)

  Ok(Font(glyph_width:, glyph_height:, glyphs:))
}

pub fn to_packed_pixels(font: Font, glyphs_per_row: Int) -> Pixels {
  font.glyphs
  |> list.sized_chunk(glyphs_per_row)
  |> list.filter_map(list.reduce(_, concat_glyphs))
  |> list.fold([], list.append)
}

fn concat_glyphs(glyph: Pixels, another: Pixels) {
  list.map2(glyph, another, list.append)
}

fn decode(input: List(String)) {
  input
  |> list.filter_map(fn(hex: String) {
    case hex {
      "0x" <> hx -> int.base_parse(hx, 16)
      _ -> Error(Nil)
    }
  })
  |> list.flat_map(int_to_bits)
}

fn glyphs(bits: List(Bool), glyph_width: Int, glyph_height: Int) {
  bits
  |> list.sized_chunk(glyph_width * glyph_height)
  |> list.map(list.sized_chunk(_, glyph_height))
  |> list.map(list.transpose)
  |> list.map(list.reverse)
}

fn int_to_bits(i: Int) {
  // TODO there must be a way more efficient way to do this?

  i
  |> int.to_base2
  |> string.pad_start(to: 8, with: "0")
  |> string.to_graphemes
  |> list.map(fn(c) { c == "1" })
}

fn extract_hex_array(glcd_font_in_c_code: String) -> Result(List(String), Nil) {
  let assert Ok(array_regex) =
    regexp.from_string(
      "\\{\\s*(?:0x[0-9a-fA-F]{1,2}\\s*,\\s*)*0x[0-9a-fA-F]{1,2}\\s*,?\\s*\\}",
    )

  let assert Ok(byte_regex) = regexp.from_string("0x[0-9a-fA-F]{1,2}")

  let flat_file = glcd_font_in_c_code |> string.replace("\n", "")

  regexp.scan(array_regex, flat_file)
  |> list.map(fn(match) { match.content })
  |> list.max(fn(l, r) { int.compare(string.length(l), string.length(r)) })
  |> result.try(fn(arr) {
    regexp.scan(byte_regex, arr)
    |> list.map(fn(match) { match.content })
    |> Ok
  })
}
