import argv
import clip
import clip/help
import clip/opt
import glcdfont/bitmap
import glcdfont/font
import gleam/bit_array
import gleam/io
import gleam/list
import gleam/result
import simplifile
import stdin

type Args {
  Preview
  ToPng(outfile: String)
  FromPng
}

fn to_png_command() -> clip.Command(Args) {
  clip.command(fn(outfile) { ToPng(outfile:) })
  |> clip.opt(
    opt.new("outfile") |> opt.short("o") |> opt.help("PNG output file"),
  )
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

pub fn main() -> Nil {
  let command =
    command()
    |> clip.help(help.simple(
      "glcdfont",
      "Convert between glcdfont.c PROGMEM arrays and PNGs",
    ))
    |> clip.run(argv.load().arguments)
  case command {
    Error(e) -> io.println_error(e)
    Ok(Preview) -> preview()
    Ok(ToPng(outfile)) -> to_png(outfile)
    Ok(FromPng) -> from_png()
  }
}

fn preview() -> Nil {
  stdin.read_lines()
  |> font.parse_c_file(6, 8)
  |> font.to_packed_pixels(32)
  |> bitmap.pixels_to_pseudographics
  |> list.each(io.println)
}

fn to_png(outfile) -> Nil {
  let maybe_png =
    stdin.read_lines()
    |> font.parse_c_file(6, 8)
    |> font.to_packed_pixels(32)
    |> bitmap.pixels_to_png
  case maybe_png {
    Ok(png) -> {
      case simplifile.write_bits(outfile, png) {
        Ok(Nil) -> Nil
        Error(e) -> {
          echo e
          Nil
        }
      }
    }
    Error(Nil) -> io.println_error("Can not convert input to PNG")
  }

  Nil
}

fn from_png() -> Nil {
  todo
}
