defmodule Ascee.CellSupervisor do
  @moduledoc false
  use Supervisor

  alias Ascee.Cell

  @num_rows Application.compile_env(:ascee, :num_rows)
  @num_cols Application.compile_env(:ascee, :num_cols)

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children =
      for row <- 1..@num_rows, col <- 1..@num_cols do
        Supervisor.child_spec({Cell, {row, col}}, id: {Cell, row, col})
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end
