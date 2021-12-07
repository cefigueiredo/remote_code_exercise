defmodule CodeExerciseWeb.UserController do
  use CodeExerciseWeb, :controller

  alias CodeExercise.UserManager

  def index(conn, _) do
    data = GenServer.call(UserManager, :query)
    json(conn, data)
  end
end
