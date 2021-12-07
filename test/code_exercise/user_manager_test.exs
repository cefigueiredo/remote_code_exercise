defmodule CodeExercise.UserManagerTest do
  use CodeExercise.DataCase

  alias CodeExercise.{Repo, User, UserManager}
  alias CodeExercise.UserManager.State

  setup do
    dt = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    user_entries = [
      %{id: 1, points: 10, inserted_at: dt, updated_at: dt},
      %{id: 2, points: 10, inserted_at: dt, updated_at: dt},
      %{id: 3, points: 10, inserted_at: dt, updated_at: dt}
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
      {:noreply, new_state} = UserManager.handle_info(:refresh, previous_state)

      user = Repo.reload(user)

      refute new_state.max_number == previous_state.max_number
      refute user.points == previous_points
    end
  end

  describe "handle_call/3" do
    test "fetches only 2 users that have the given points" do
      previous_state = %State{max_number: 10}

      {:reply, %{users: users, timestamp: timestamp}, state} =
        UserManager.handle_call({:query, 10}, nil, previous_state)

      assert Enum.count(users) == 2
      refute is_nil(timestamp)
    end
  end
end
