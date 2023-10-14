defmodule Ascee.Cell do
  @moduledoc false
  use GenServer

  alias Ascee.Chars
  alias Phoenix.PubSub

  @topic "cell:update"

  def topic, do: @topic

  defp process_name(row, col) do
    :"r#{row}c#{col}"
  end

  # Client

  def start_link({row, col}) do
    GenServer.start_link(__MODULE__, {row, col}, name: process_name(row, col))
  end

  defp get(server) do
    GenServer.call(server, :get)
  end

  def get(row, col) do
    server = process_name(row, col)
    get(server)
  end

  defp crash(server) do
    GenServer.cast(server, :this_will_deliberately_crash)
  end

  def crash(row, col) do
    server = process_name(row, col)
    crash(server)
  end

  # Server (callbacks)

  @impl true
  def init({row, col}) do
    :timer.send_interval(1_000, self(), :tick)
    state = {row, col, Chars.random()}
    PubSub.broadcast(Ascee.PubSub, @topic, state)
    {:ok, state}
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
