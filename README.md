# `glcdfont` converter to and from PBM

QMK-based keyboards support OLED displays and use a bitmap font encoded in
`glcdfont` format. This tool decodes the font to PBM and back into char array
for use in `glcdfont.c`. PBM is a plain-text monochrome image format supported
by Gimp. 

## Usage

### Setup

Make sure you have a working Elixir 1.8+ interpreter installed. Consult your package manager.

Macos: `brew install elixir`

Easiest way:
* install the [asdf](https://asdf-vm.com/) tool
* `asdf plugin-add elixir`
* `asdf plugin-add erlang`
* `asdf install`

### Decode

Convert a `glcdfont.c` file 
```sh
cat glcdfont.c | ./decode.exs > glcdfont.pbm
```
The PBM file can be edited with Gimp. When you export it back into PBM, make sure to pick the ASCII mode.

### Encode

```sh
cat glcdfont.pbm | ./encode.exs
```

Paste output in the array in the `glcdfont.c` file. Done!
