defmodule Ascee.Cell do
  @moduledoc false
  use GenServer

  alias Ascee.Chars
  alias Phoenix.PubSub

  require Logger

  @num_rows Application.compile_env(:ascee, :num_rows)
  @num_cols Application.compile_env(:ascee, :num_cols)

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
    :timer.send_interval(2_000, self(), :tock)

    # Format: {row, col, char, neighbour_chars}
    state = {row, col, Chars.random(), []}

    broadcast(state)

    {:ok, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {_row, _col, char, _neighbour_chars} = state
    {:reply, char, state}
  end

  @impl true
  def handle_info(:tick, state) do
    broadcast(state)
    {:noreply, state}
  end

  @impl true
  def handle_info(:tock, {row, col, _, _} = state) do
    ask_all_neighbours_for_current_value(row, col)
    {:noreply, state}
  end

  @impl true
  def handle_info({ref, neighbour_char}, {row, col, char, neighbour_chars}) do
    Process.demonitor(ref, [:flush])

    neighbour_chars = [neighbour_char | neighbour_chars]

    # Sort all surrounding characters (neighbours, plus the current cell's
    # value) by frequency, and pick the most frequent.
    char =
      [char | neighbour_chars]
      |> Enum.group_by(& &1)
      |> Enum.sort_by(fn {_, list} -> -length(list) end)
      |> Enum.map(fn {char, _} -> char end)
      |> List.first(char)

    {:noreply, {row, col, char, Enum.take(neighbour_chars, num_neighbours(row, col))}}
  end

  @impl true
  def handle_info({:DOWN, _ref, _, _, reason}, state) do
    Logger.debug("Got down for ref with reason #{inspect(reason)}")
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.debug("Unexpected message in #{__MODULE__}: #{inspect(msg)}")
    {:noreply, state}
  end

  defp broadcast(state) do
    {row, col, char, _neighbour_chars} = state
    PubSub.broadcast(Ascee.PubSub, @topic, {row, col, char})
  end

  defp neighbour_indices(row, col) do
    Enum.filter(
      [
        {row - 1, col - 1},
        {row - 1, col},
        {row - 1, col + 1},
        {row, col - 1},
        {row, col + 1},
        {row + 1, col - 1},
        {row + 1, col},
        {row + 1, col + 1}
      ],
      fn {row, col} ->
        row > 0 and row <= @num_rows and col > 0 and
          col <= @num_cols
      end
    )
  end

  defp num_neighbours(row, col) do
    Enum.count(neighbour_indices(row, col))
  end

  defp ask_all_neighbours_for_current_value(row, col) do
    indices = neighbour_indices(row, col)

    for {row, col} <- indices do
      Task.Supervisor.async_nolink(Ascee.CellTaskSupervisor, fn -> get(row, col) end)
    end
  end
end
