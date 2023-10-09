defmodule AsceeWeb.HomeLive do
  @moduledoc false
  use AsceeWeb, :live_view

  alias Ascee.Cell
  alias Ascee.CellSupervisor

  @num_rows Application.compile_env(:ascee, :num_rows)
  @num_cols Application.compile_env(:ascee, :num_cols)

  @impl true
  def mount(_params, _session, socket) do
    state =
      for row <- 1..@num_rows, col <- 1..@num_cols, into: %{} do
        id = CellSupervisor.process_name_for_cell(row, col)
        {id, Cell.get(id)}
      end

    if connected?(socket) do
      :timer.send_interval(1, self(), :tick)
    end

    {:ok,
     socket
     |> assign(:num_rows, @num_rows)
     |> assign(:num_cols, @num_cols)
     |> assign(:state, state)}
  end

  @impl true
  def handle_info(:tick, socket) do
    state =
      for row <- 1..@num_rows, col <- 1..@num_cols, into: %{} do
        id = CellSupervisor.process_name_for_cell(row, col)

        {id, Cell.get(id)}
      end

    {:noreply, assign(socket, :state, state)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "ASCEE")
    |> assign(:user, nil)
  end
end
