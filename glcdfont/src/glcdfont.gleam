import argv
import clip
import clip/help
import glcdfont/bitmap
import glcdfont/font
import gleam/io
import gleam/list
import stdin

type Args {
  Preview
  ToPng
  FromPng
}

fn to_png_command() -> clip.Command(Args) {
  clip.return(ToPng)
  |> clip.help(help.simple(
    "glcdfont topng",
    "Convert from glcdfont.c (stdin) to PNG (stdout)",
  ))
}

fn from_png_command() -> clip.Command(Args) {
  clip.return(FromPng)
  |> clip.help(help.simple(
    "glcdfont frompng",
    "Convert from PNG (stdin) to PRORMEM array (stdout) that you can paste into your glcdfont.c",
  ))
}

fn preview_command() -> clip.Command(Args) {
  clip.return(Preview)
  |> clip.help(help.simple(
    "glcdfont preview",
    "Preview font from glcdfont.c (stdin) in the terminal",
  ))
}

fn command() -> clip.Command(Args) {
  clip.subcommands([
    #("preview", preview_command()),
    #("topng", to_png_command()),
    #("frompng", from_png_command()),
  ])
}

pub fn main() {
  let command =
    command()
    |> clip.help(help.simple(
      "glcdfont",
      "Convert between glcdfont.c PROGMEM arrays and PNGs",
    ))
    |> clip.run(argv.load().arguments)
  case command {
    Error(e) -> io.println_error(e)
    Ok(Preview) ->
      stdin.read_lines()
      |> font.parse_c_file(6, 8)
      |> font.to_packed_pixels(32)
      |> bitmap.pixels_to_pseudographics
      |> list.each(io.println)
    Ok(ToPng) -> todo
    Ok(FromPng) -> todo
  }
}
