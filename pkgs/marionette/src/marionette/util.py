def append_right_aligned(string: str, suffix: str, align_column: int, min_spaces: int=0) -> str:
  num_spaces = max(min_spaces, align_column - len(suffix) - len(string))
  return string + " " * num_spaces + suffix
