# ascee

`ascee` is a tiny example project, created to help learn some
[Elixir](https://elixir-lang.org/),
[LiveView](https://www.phoenixframework.org/), and
[OTP](https://www.erlang.org/doc/design_principles/des_princ) concepts.

In particular:

- every cell in the grid is backed by a process; the "value" of each cell is an
  ASCII character
- each cell periodically broadcasts its current value using [Phoenix
  PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html)
  - all [LiveView
    processes](https://fly.io/phoenix-files/a-liveview-is-a-process/) _(note:
    one LiveView process per open browser tab)_ receive these messages and
    update internal state, which automatically re-renders the grid
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


## Demos

### Grid + Message Passing

https://github.com/mjrusso/ascee/assets/100451/ecd2e072-eaa7-4f84-aeba-3288cafef4b7

### Individual Process Crash + Restart

https://github.com/mjrusso/ascee/assets/100451/d04f6eb5-e581-40d7-8a32-2fe3257c324c

### Too Many Crashes: Supervisor Restarts All Child Processes

https://github.com/mjrusso/ascee/assets/100451/b9b0dfd9-b383-4930-897c-154cccd32480

### Built-in Sync Across Tabs

https://github.com/mjrusso/ascee/assets/100451/41eabdd7-3626-4c34-bbab-b863dfa26a03

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
