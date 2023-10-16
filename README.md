# ascee

`ascee` is a tiny example project, created to help learn some
[Elixir](https://elixir-lang.org/),
[LiveView](https://www.phoenixframework.org/), and
[OTP](https://www.erlang.org/doc/design_principles/des_princ) concepts.

In particular:

- every cell in the grid is backed by a process; the "value" of each cell is an
  ASCII character
- cells periodically ask their neighbouring cells what their value is
- each cell updates its value to match the most common neighbouring value
  - (the goal is for the grid to eventually converge on a common value,
    although this is not directly codified; each cell is an independent
    process)
- clicking on a cell will deliberately crash the process associated with cell
  - when the associate supervisor restarts the process, it will start with a
    random value
  - all cells will be restarted if cells are crashed more than `max_restarts`
    times in `max_seconds` periods; see [this
    commit](https://github.com/mjrusso/ascee/commit/f9bbe3cabaae25f0053f9a7313ea9c17b73a6081)
    for details

## Setup and Usage

- Exact versions of required system dependencies (Elixir and Erlang) are
  specified via [.tool-versions](./.tool-versions). Using
  [asdf](https://asdf-vm.com/) is recommended, but not required. (Read the
  [.tool-versions file](./.tool-versions) for documentation on how to install
  _asdf_ and all of the required plugins.)

- After installing Elixir and Erlang, run `mix setup` to install and setup
  project dependencies

- Start the Phoenix endpoint with `mix phx.server`, or inside IEx with `iex -S
  mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
