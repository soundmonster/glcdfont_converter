import glcdfont/bitmap.{type Pixels}
import gleam/int
import gleam/list
import gleam/string
import gleam/yielder

pub type Font {
  Font(char_width: Int, char_height: Int, glyphs: List(Pixels))
}

pub fn parse_c_file(
  glcd_font_in_c_code: yielder.Yielder(String),
  char_width: Int,
  char_height: Int,
) -> Font {
  let glyphs =
    glcd_font_in_c_code
    |> extract_hex_array
    |> decode
    |> glyphs(char_width, char_height)
    |> yielder.to_list

  Font(char_width:, char_height:, glyphs:)
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

fn decode(input: yielder.Yielder(String)) {
  input
  |> yielder.flat_map(fn(l) { yielder.from_list(string.split(l, ",")) })
  |> yielder.map(string.trim)
  |> yielder.filter_map(fn(hex: String) {
    case hex {
      "0x" <> hx -> int.base_parse(hx, 16)
      _ -> Error(Nil)
    }
  })
  |> yielder.flat_map(int_to_bits)
}

fn glyphs(bits: yielder.Yielder(Bool), char_width: Int, char_height: Int) {
  bits
  |> yielder.sized_chunk(char_width * char_height)
  |> yielder.map(list.sized_chunk(_, char_height))
  |> yielder.map(list.transpose)
  |> yielder.map(list.reverse)
}

fn int_to_bits(i: Int) {
  // TODO there must be a way more efficient way to do this?

  i
  |> int.to_base2
  |> string.pad_start(to: 8, with: "0")
  |> string.to_graphemes
  |> yielder.from_list
  |> yielder.map(fn(c) { c == "1" })
}

fn extract_hex_array(
  glcd_font_in_c_code: yielder.Yielder(String),
) -> yielder.Yielder(String) {
  glcd_font_in_c_code
  |> yielder.drop_while(fn(l) {
    !{
      string.contains(l, "PROGMEM")
      && string.contains(l, "font[]")
      && string.contains(l, "unsigned char")
      && string.contains(l, "const")
    }
  })
  |> yielder.drop(1)
  |> yielder.take_while(fn(l) { !string.contains(l, "}") })
  |> yielder.map(string.trim)
}
