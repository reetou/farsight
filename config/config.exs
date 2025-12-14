import Config

config :farsight, Farsight.Repo,
  database: "farsight_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :farsight, ecto_repos: [Farsight.Repo]
