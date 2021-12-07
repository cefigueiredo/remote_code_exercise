# CodeExercise

This app listen to the port 3000 on http://localhost/ returning a json with a list of 2 users that matches a particular amount of points in the format of:
```json
{
  "users": [{"id": 1, "points": 10}, {"id": 1, "points": 10}],
  "timestamp": "2021-12-07T06:57:00.00000"
}
```

The amount of points rotates every minute and are in a range of [0-100]

Each minute a process updates every user to add a random point to it.

## Technical decisions

In order to comply with the initial requirements of seed 1_000_000 users, I opted to make the seeds use `Ecto.Repo.insert_all/3` to insert the users in batches of `10_000`, to speed up the process.

The same apply for the GenServer that updates every user to set a random value for `points` on each user.
To be able to update the users in a timely way, I opted to use `Ecto.Repo.insert_all/3` again with `upsert` clauses, to update the users in batches, and setting a different random number on the `points` field.

On the Genserver, I also opted to update the users inside a concurrent Task to not block the GenServer queue. The task will not be awaited as the results of this operation are not needed.

## Setup

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

### Database dev/test

To connect to database on dev/test environment, the app expects to exist a 
PostgreSQL role with permission to create database with the following login:

  * username: `remote_user`
  * password: `remote`

### Production Environment Variables

The app will look for the following environment variables when initializing on a `prod` 
environment

  * DATABASE_URL (mandatory) like `postgres://user:pass@host/database`
  * SECRET_KEY_BASE (mandatory)
  * POOL_SIZE (optional fallbacks to 10)
  * PORT (optional fallbacks to 3000)
