defmodule Ascee.Cell do
  @moduledoc false
  use GenServer

  @ascii [
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

  # Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get(server) do
    GenServer.call(server, :get)
  end

  def update(server) do
    GenServer.cast(server, :update)
  end

  # Server (callbacks)

  @impl true
  def init(:ok) do
    :timer.send_interval(1_000, self(), :tick)

    {:ok, Enum.random(@ascii)}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:update, _state) do
    {:noreply, Enum.random(@ascii)}
  end

  @impl true
  def handle_info(:tick, state) do
    {:noreply, Enum.random(@ascii)}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger

    Logger.debug("Unexpected message in #{__MODULE__}: #{inspect(msg)}")
    {:noreply, state}
  end
end
