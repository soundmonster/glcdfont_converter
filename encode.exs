#! /usr/bin/env elixir

colmax = 32
rowmax = 7
fontw = 6
fonth = 8

IO.binread(:all)
|> String.split("\n")
|> Enum.map(&String.trim/1)
|> Enum.reject(fn s -> s == "" end)
|> Enum.reject(fn s -> s == "P1" end)
|> Enum.reject(fn s -> s == "192 56" end)
|> Enum.reject(fn s -> String.starts_with?(s, "#") end)
|> Enum.join()
|> String.to_charlist()
|> Enum.chunk_every(colmax * fontw)
|> Enum.zip()
|> Enum.map(&Tuple.to_list/1)
|> Enum.map(&Enum.reverse/1)
|> Enum.map(&Enum.chunk_every(&1, fonth))
|> Enum.map(&Enum.reverse/1)
|> Enum.zip()
|> Enum.flat_map(&Tuple.to_list/1)
|> Enum.map(&to_string/1)
|> Enum.map(fn bin -> String.to_integer(bin, 2) end)
|> Enum.map(fn int -> Integer.to_string(int, 16) end)
|> Enum.map(fn hex -> "0x#{String.pad_leading(hex, 2, "0")}" end)
|> Enum.chunk_every(6)
|> Enum.map(&Enum.join(&1, ", "))
|> Enum.join(",\n")
|> IO.puts()
