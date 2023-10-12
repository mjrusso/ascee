defmodule Ascee.Cell do
  @moduledoc false
  use GenServer

  alias Ascee.Chars
  alias Phoenix.PubSub

  @topic "cell:update"

  def topic, do: @topic

  def process_name(row, col) do
    :"r#{row}c#{col}"
  end

  # Client

  def start_link({row, col}) do
    GenServer.start_link(__MODULE__, {row, col}, name: process_name(row, col))
  end

  def get(server) do
    GenServer.call(server, :get)
  end

  # Server (callbacks)

  @impl true
  def init({row, col}) do
    :timer.send_interval(1_000, self(), :tick)

    {:ok, {row, col, Chars.random()}}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {_row, _col, char} = state
    {:reply, char, state}
  end

  @impl true
  def handle_info(:tick, state) do
    state = put_elem(state, 2, Chars.random())
    PubSub.broadcast(Ascee.PubSub, @topic, state)
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger

    Logger.debug("Unexpected message in #{__MODULE__}: #{inspect(msg)}")
    {:noreply, state}
  end
end
