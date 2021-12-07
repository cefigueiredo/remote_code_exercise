defmodule CodeExercise.UserManagerTest do
  use CodeExercise.DataCase

  alias CodeExercise.{Repo, User, UserManager}

  setup do
    dt = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    user_entries =
      [
        %{id: 1, points: 0, inserted_at: dt, updated_at: dt},
        %{id: 2, points: 0, inserted_at: dt, updated_at: dt},
        %{id: 3, points: 0, inserted_at: dt, updated_at: dt}
      ]
    {_, users} = Repo.insert_all(User, user_entries, returning: true)

    {:ok, users: users}
  end

  describe "init/1" do
    test "sets initial state max_number and schedule to refresh state" do
      {:ok, %UserManager.State{} = state} = UserManager.init([])

      assert state.max_number >= 0
      assert is_nil(state.timestamp)

      assert_received :refresh_later
    end
  end

  describe "handle_info(:refresh, state)" do
    test "refreshes points of all users", %{users: users} do
      [%User{points: previous_points} = user | _] = users

      previous_state = %{max_number: 0, timestamp: NaiveDateTime.utc_now()}
      {:ok, new_state} = UserManager.handle_info(:refresh, previous_state)

      user = Repo.reload(user)

      refute new_state.max_number == previous_state.max_number
      refute user.points == previous_points
    end
  end
end
