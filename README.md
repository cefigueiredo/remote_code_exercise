# CodeExercise

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

## Database dev/test

To connect to database on dev/test environment, the app expects to exist a 
PostgreSQL role with permission to create database with the following login:

  * username: `remote_user`
  * password: `remote`

## Production Environment Variables

The app will look for the following environment variables when initializing on a `prod` 
environment

  * DATABASE_URL (mandatory) like `postgres://user:pass@host/database`
  * SECRET_KEY_BASE (mandatory)
  * POOL_SIZE (optional fallbacks to 10)
  * PORT (optional fallbacks to 3000)
