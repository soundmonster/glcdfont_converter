import glcdfont/bitmap
import glcdfont/font
import gleam/io
import gleam/list
import stdin

pub fn main() {
  let _ =
    stdin.read_lines()
    |> font.parse_c_file(6, 8)
    |> font.to_packed_pixels(32)
    |> bitmap.pixels_to_pseudographics
    |> list.map(io.println)
}
