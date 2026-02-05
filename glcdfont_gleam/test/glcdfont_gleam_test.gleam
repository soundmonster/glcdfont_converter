import glcdfont_gleam
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn zip_test() {
  let lists = [
    [1, 2, 3, 4, 5],
    [6, 7, 8, 9, 10],
    [11, 12, 13, 14, 15],
    [16, 17, 18, 19, 20],
  ]

  assert glcdfont_gleam.zip(lists)
    == [
      [1, 6, 11, 16],
      [2, 7, 12, 17],
      [3, 8, 13, 18],
      [4, 9, 14, 19],
      [5, 10, 15, 20],
    ]
  assert lists == glcdfont_gleam.zip(glcdfont_gleam.zip(lists))
}
