import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/yielder
import stdin

pub fn main() {
  stdin.read_lines()
  |> extract_hex_array()
  |> decode_to_binary_string()
  |> encode_to_pbm()
  |> io.println
}

fn extract_hex_array(input: yielder.Yielder(String)) -> yielder.Yielder(String) {
  input
  |> yielder.drop_while(fn(l) { !string.contains(l, "font[] PROGMEM") })
  |> yielder.drop(1)
  |> yielder.take_while(fn(l) { !string.contains(l, "}") })
  |> yielder.map(string.trim)
}

fn decode_to_binary_string(
  input: yielder.Yielder(String),
) -> yielder.Yielder(String) {
  input
  |> yielder.flat_map(fn(l) { yielder.from_list(string.split(l, ",")) })
  |> yielder.map(string.trim)
  |> yielder.filter_map(fn(hex: String) {
    case hex {
      "0x" <> hx -> int.base_parse(hx, 16)
      _ -> Error(Nil)
    }
  })
  |> yielder.map(int.to_base2)
  |> yielder.map(string.pad_start(_, to: 8, with: "0"))
}

fn encode_to_pbm(input: yielder.Yielder(String)) -> String {
  let col_max = 32
  let row_max = 7
  let font_width = 6
  let font_height = 8
  let header =
    [
      "P1",
      "# this is a pbm file",
      int.to_string(col_max * font_width)
        <> " "
        <> int.to_string(row_max * font_height),
      "",
    ]
    |> string.join(with: "\n")

  let body =
    input
    |> yielder.sized_chunk(col_max * font_width)
    |> yielder.to_list()
    |> zip()
    |> list.map(list.reverse)
    |> list.map(string.join(_, ""))
    |> list.map(string.to_graphemes)
    |> list.map(list.reverse)
    |> zip()
    |> list.flatten()
    |> list.sized_chunk(76)
    |> list.map(string.join(_, ""))
    |> string.join("\n")
  header <> body
}

pub fn zip(lists: List(List(a))) {
  do_zip(lists, [])
}

fn do_zip(lists: List(List(a)), acc: List(List(a))) -> List(List(a)) {
  let heads = list.filter_map(lists, list.first)
  let tails = list.filter_map(lists, list.rest)

  case heads {
    [] -> list.reverse(acc)
    heads -> do_zip(tails, [heads, ..acc])
  }
}
