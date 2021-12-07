defmodule CodeExercise.UserManager do
  use GenServer

  import Ecto.Query

  alias CodeExercise.{Repo, User}

  defmodule State do
    @type t :: %__MODULE__{
            max_number: integer,
            timestamp: NaiveDateTime.t()
          }

    defstruct [:max_number, :timestamp]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    send self(), :refresh_later

    {:ok, %State{max_number: new_points()}}
  end

  @impl true
  def handle_info(:refresh, state) do
    batch_update_users(total_users())
    refresh_later()

    {:ok, %State{max_number: new_points(), timestamp: state.timestamp}}
  end

  def handle_info(:refresh_later, state) do
    refresh_later()

    {:ok, state}
  end

  @impl true
  def handle_call({:query, _number}, _, _state) do
  end

  defp new_points do
    Enum.random(0..100)
  end

  defp batch_update_users(0), do: 0

  defp batch_update_users(total_users) do
    1..total_users
    |> Stream.chunk_every(10_000)
    |> Stream.map(fn chunk ->
      dt = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      entries = Enum.map(chunk, &(%{id: &1, points: new_points(), inserted_at: dt, updated_at: dt}))

      Repo.insert_all(User, entries, conflict_target: [:id], on_conflict: {:replace_all_except, [:id, :inserted_at]})
    end)
    |> Enum.count()
  end

  defp total_users do
    Repo.one(from u in User, select: max(u.id))
  end

  defp refresh_later do
    Process.send_after(self(), :refresh, :timer.minutes(1))
  end
end
