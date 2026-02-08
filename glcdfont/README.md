# glcdfont

Conversion utility for the `glcdfont` LCD font format as used in QMK, written in [Gleam](https://gleam.run).

## Usage

```sh
glcdfont preview < glcdfont.c  # Preview the font using pseudographics in the terminal
glcdfont topng < glcdfont.c > glcdfont.png  # Convert font to PNG 
glcdfont frompng < glcdfont.png | pbcopy  # Convert PNG to font, paste output into the PROGMEM array in the glcdfont.c file
```

# Development

```sh
gleam run preview < glcdfont.c  # Preview the font using pseudographics in the terminal
gleam run topng < glcdfont.c > glcdfont.png  # Convert font to PNG 
gleam run frompng < glcdfont.png | pbcopy  # Convert PNG to font 
gleam test  # Run the tests
```
