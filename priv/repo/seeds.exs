require Logger

alias CodeExercise.{Repo, User}

# generate 1_000_000 users with default values in batches
total = 1_000_000
batch_size = 10_000
batch_count = div(total, batch_size)

1..total
|> Stream.chunk_every(batch_size)
|> Stream.map(fn [batch_start | _] = chunk ->
  batch_number = div(batch_start, batch_size)
  dt = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

  Logger.debug("[INSERT USER] Inserting batch ##{batch_number} of #{batch_count}")

  entries =
    Enum.map(chunk, fn _idx ->
      %User{points: 0, inserted_at: dt, updated_at: dt}
      |> Map.take([:points, :inserted_at, :updated_at])
    end)

  Repo.insert_all(User, entries)
end)
|> Enum.count()
