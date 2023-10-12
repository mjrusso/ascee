defmodule Ascee.Chars do
  @moduledoc false
  @chars [
    ".",
    "!",
    "@",
    "#",
    "$",
    "%",
    "^",
    "&",
    "*",
    "(",
    ")",
    "_",
    "-",
    "+",
    "=",
    "~",
    "`",
    ":",
    ";",
    "'",
    "\"",
    ",",
    "<",
    ">",
    "?",
    "/",
    "|",
    "\\",
    "[",
    "]",
    "{",
    "}"
  ]

  def random, do: Enum.random(@chars)
end
