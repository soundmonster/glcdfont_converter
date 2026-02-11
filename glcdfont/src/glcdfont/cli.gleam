import argv
import clip
import clip/help
import clip/opt
import glcdfont/bitmap
import glcdfont/font
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import gleave
import simplifile
import stdin

type Args {
  Args(glyph_width: Int, glyph_height: Int, columns: Int, infile: String)
}

type CLICommand {
  Preview(args: Args)
  ToPng(args: Args, outfile: String)
  FromPng(args: Args)
}

fn common_opts(
  cmd: clip.Command(fn(Int) -> fn(Int) -> fn(Int) -> fn(String) -> a),
) -> clip.Command(a) {
  cmd
  |> clip.opt(
    opt.new("width")
    |> opt.short("w")
    |> opt.help("Width of each font glyph in pixels")
    |> opt.int()
    |> opt.default(6),
  )
  |> clip.opt(
    opt.new("height")
    |> opt.short("h")
    |> opt.help("Height of each font glyph in pixels")
    |> opt.int()
    |> opt.default(8),
  )
  |> clip.opt(
    opt.new("cols")
    |> opt.short("c")
    |> opt.help("Number of glyphs in a row")
    |> opt.int()
    |> opt.default(32),
  )
  |> clip.opt(
    opt.new("input")
    |> opt.short("i")
    |> opt.help("Input file")
    |> opt.default("-"),
  )
}

fn parse_common_opts(
  callback: fn(Args) -> a,
) -> fn(Int) -> fn(Int) -> fn(Int) -> fn(String) -> a {
  use glyph_width <- clip.parameter
  use glyph_height <- clip.parameter
  use columns <- clip.parameter
  use infile <- clip.parameter
  callback(Args(glyph_width:, glyph_height:, columns:, infile:))
}

fn to_png_command() -> clip.Command(CLICommand) {
  clip.command({
    use args <- parse_common_opts()
    use outfile <- clip.parameter
    ToPng(args:, outfile:)
  })
  |> common_opts()
  |> clip.opt(
    opt.new("outfile") |> opt.short("o") |> opt.help("PNG output file"),
  )
  |> clip.help(help.simple(
    "glcdfont topng",
    "Convert from glcdfont.c (stdin) to PNG (stdout)",
  ))
}

fn from_png_command() -> clip.Command(CLICommand) {
  clip.command({
    use args <- parse_common_opts()
    FromPng(args:)
  })
  |> common_opts()
  |> clip.help(help.simple(
    "glcdfont frompng",
    "Convert from PNG (stdin) to PRORMEM array (stdout) that you can paste into your glcdfont.c",
  ))
}

fn preview_command() -> clip.Command(CLICommand) {
  clip.command({
    use args <- parse_common_opts()
    Preview(args:)
  })
  |> common_opts()
  |> clip.help(help.simple(
    "glcdfont preview",
    "Preview font from glcdfont.c (stdin) in the terminal",
  ))
}

fn command() -> clip.Command(CLICommand) {
  clip.subcommands([
    #("preview", preview_command()),
    #("topng", to_png_command()),
    #("frompng", from_png_command()),
  ])
}

pub fn run() -> Nil {
  let command =
    command()
    |> clip.help(help.simple(
      "glcdfont",
      "Convert between glcdfont.c PROGMEM arrays and PNGs",
    ))
    |> clip.run(argv.load().arguments)
  case command {
    Error(e) -> io.println_error(e)
    Ok(Preview(args)) -> cli(preview(args))
    Ok(ToPng(args, outfile)) -> cli(to_png(args, outfile))
    Ok(FromPng(args)) -> cli(from_png(args))
  }
}

fn cli(command_result: Result(a, String)) -> Nil {
  case command_result {
    Ok(_) -> Nil
    Error(message) -> {
      io.println_error(message)
      gleave.exit(1)
    }
  }
}

fn preview(args: Args) -> Result(Nil, String) {
  use input <- with_file(args.infile)
  use font <- result.try(
    font.parse_c_file(input, args.glyph_width, args.glyph_height)
    |> result.replace_error("Could not parse file"),
  )

  font
  |> font.to_packed_pixels(args.columns)
  |> bitmap.pixels_to_pseudographics
  |> list.each(io.println)
  |> Ok
}

fn to_png(args: Args, outfile: String) -> Result(Nil, String) {
  use input <- with_file(args.infile)
  use font <- result.try(
    font.parse_c_file(input, args.glyph_width, args.glyph_height)
    |> result.replace_error("Could not parse file"),
  )

  use png <- result.try(
    font
    |> font.to_packed_pixels(args.columns)
    |> bitmap.pixels_to_png
    |> result.replace_error("Could not produce valid PNG from given input"),
  )
  simplifile.write_bits(outfile, png)
  |> result.map_error(simplifile.describe_error)
}

fn with_file(
  infile: String,
  fun: fn(String) -> Result(a, String),
) -> Result(a, String) {
  case infile {
    "-" -> Ok(stdin.read_lines() |> yielder.to_list() |> string.concat)
    filename -> simplifile.read(filename)
  }
  |> result.map_error(simplifile.describe_error)
  |> result.try(fun)
}

fn from_png(_args: Args) -> Result(Nil, String) {
  todo
}
