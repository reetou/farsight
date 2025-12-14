defmodule Farsight do
  @moduledoc """
  Documentation for `Farsight`.
  """

  @doc """
  Logs an item and a function to be called.

  Arguments:
  - item: The item that is being edited during logging
  - fun: A function that should return insertable changeset for the audit log. Receives the item and the Farsight configuration as arguments.
  - opts: An optional keyword list of options. You can pass `:otp_app` to explicitly specify the OTP app to read config from.

  ## Configuration

  Configure Farsight in your application's `config/config.exs`:

      config :myapp, Farsight,
        repo: MyApp.Repo,
        schema: MyApp.Audit.Log


  Create a schema for the audit log.
  ```elixir
  defmodule MyApp.Audit.Log do
    use Ecto.Schema
    import Ecto.Changeset

    schema "audit_logs" do
      field :action, :string
      field :actor_id, :string
      field :target_id, :string
      field :environment, :string
      field :metadata, :map, default: %{}

      timestamps()
    end

    def changeset(log, attrs) do
      log
      |> cast(attrs, [:action, :actor_id, :target_id, :environment, :metadata])
      |> validate_required([:action, :actor_id, :target_id, :environment])
    end
  end
  ```

  Use independently:
  ```elixir
  Farsight.Audit.log(user, fn item, cfg ->
    %{action: "create", actor_id: "my_admin_user_id", target_id: user.id, environment: "production", metadata: %{}}
  end)
  ```

  ### Custom module (Recommended)

  Create a custom module to handle the audit logging.
  ```elixir
  defmodule MyApp.Audit do
    def log(%User{id: id} = item, opts) do
      actor_id = Keyword.fetch!(opts, :actor_id)
      action = Keyword.get(opts, :action, :create)
      log = %{action: action, actor_id: actor_id, target_id: id, environment: :production, metadata: opts[:metadata] || %{}}

      {:ok, _} = Farsight.Audit.log(item, fn item, _cfg -> log end)
      item
    end
  end
  ```

  Use the custom module:
  ```elixir
  alias MyApp.Audit
  me = %{id: 1}
  user = MyApp.User.changeset(%MyApp.User{id: 1}, %{name: "John Doe"})

  user
  |> Repo.insert()
  |> Audit.log(actor_id: me.id, metadata: %{path: "/admin/users"})
  ```

  Inside a transaction:
  ```elixir
  MyApp.Repo.transaction(fn ->
    MyApp.Audit.log(%{id: 1}, actor_id: "123", metadata: %{path: "/admin/users"})
    MyApp.Repo.insert(user)
  end)
  ```
  """
  defdelegate log(item, fun, opts \\ []), to: Farsight.Audit
end
