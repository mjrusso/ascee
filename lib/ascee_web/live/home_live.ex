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
  def render(assigns) do
    ~H"""
    <div class="mx-auto text-center font-mono">
      <div class="grid gap-0" style={"grid-template-columns: repeat(#{@num_cols}, minmax(0, 1fr))"}>
        <%= for row <- 1..@num_rows, col <- 1..@num_cols  do %>
          <div
            class="col-span-1 bg-gray-100"
            phx-click="kill"
            phx-value-row={row}
            phx-value-col={col}
            phx-value-char={Map.get(@state, {row, col}, " ")}
          >
            <%= Map.get(@state, {row, col}, " ") %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info(msg, socket) do
    {row, col, char} = msg

    existing = Map.get(socket.assigns.state, {row, col}, " ")

    if char != existing do
      state = Map.put(socket.assigns.state, {row, col}, char)
      {:noreply, assign(socket, :state, state)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("kill", %{"row" => row, "col" => col, "char" => _char}, socket) do
    Cell.crash(row, col)
    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "ascee")
    |> assign(:user, nil)
  end
end
