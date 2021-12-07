defmodule CodeExercise.Repo do
  use Ecto.Repo,
    otp_app: :code_exercise,
    adapter: Ecto.Adapters.Postgres
end
