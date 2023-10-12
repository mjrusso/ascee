defmodule AsceeWeb.HomeLive do
  @moduledoc false
  use AsceeWeb, :live_view

  alias Ascee.Cell

  @num_rows Application.compile_env(:ascee, :num_rows)
  @num_cols Application.compile_env(:ascee, :num_cols)

  @topic Cell.topic()

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Ascee.PubSub, @topic)
    end

    {:ok,
     socket
     |> assign(:num_rows, @num_rows)
     |> assign(:num_cols, @num_cols)
     |> assign(:state, %{})}
  end

  @impl true
  def handle_info(msg, socket) do
    {row, col, char} = msg

    id = Cell.process_name(row, col)

    {:noreply, assign(socket, :state, Map.put(socket.assigns.state, id, char))}
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
