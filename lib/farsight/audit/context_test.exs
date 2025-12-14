defmodule Farsight.AuditTest do
  use ExUnit.Case, async: true

  alias Farsight.Audit

  describe "log/3" do
    setup do
      # Save original config
      original_config = Application.get_env(:farsight, Farsight.Audit)

      on_exit(fn ->
        # Restore original config
        if original_config do
          Application.put_env(:farsight, Farsight.Audit, original_config)
        else
          Application.delete_env(:farsight, Farsight.Audit)
        end
      end)

      :ok
    end

    test "successfully logs with valid configuration" do
      # Setup mock schema and repo
      mock_schema = create_mock_schema()
      mock_repo = create_mock_repo()

      # Configure Farsight
      Application.put_env(:farsight, Farsight.Audit,
        repo: mock_repo,
        schema: mock_schema
      )

      item = %{id: 1, name: "Test Item"}

      log_params = %{
        action: "create",
        actor_id: "actor_123",
        target_id: "target_456",
        environment: "test",
        metadata: %{key: "value"}
      }

      fun = fn _item, _cfg -> log_params end

      result = Audit.log(item, fun, otp_app: :farsight)

      assert {:ok, _log} = result
    end

    test "calls function with item and config" do
      mock_schema = create_mock_schema()
      mock_repo = create_mock_repo()

      config = [
        repo: mock_repo,
        schema: mock_schema,
        custom_key: "custom_value"
      ]

      Application.put_env(:farsight, Farsight.Audit, config)

      item = %{id: 1}

      fun = fn item, cfg ->
        send(self(), {:function_called, item, cfg})

        %{
          action: "test",
          actor_id: "actor",
          target_id: "target",
          environment: "test"
        }
      end

      Audit.log(item, fun, otp_app: :farsight)

      assert_receive {:function_called, received_item, received_cfg}
      assert received_item == item
      assert received_cfg[:repo] == mock_repo
      assert received_cfg[:schema] == mock_schema
      assert received_cfg[:custom_key] == "custom_value"
    end

    test "uses explicit otp_app option" do
      mock_schema = create_mock_schema()
      mock_repo = create_mock_repo()

      # Configure a different app
      Application.put_env(:test_app, Farsight.Audit,
        repo: mock_repo,
        schema: mock_schema
      )

      item = %{id: 1}

      fun = fn _item, _cfg ->
        %{
          action: "test",
          actor_id: "actor",
          target_id: "target",
          environment: "test"
        }
      end

      result = Audit.log(item, fun, otp_app: :test_app)

      assert {:ok, _log} = result

      # Cleanup
      Application.delete_env(:test_app, Farsight.Audit)
    end

    test "detects otp_app from loaded applications" do
      mock_schema = create_mock_schema()
      mock_repo = create_mock_repo()

      # Configure farsight app
      Application.put_env(:farsight, Farsight.Audit,
        repo: mock_repo,
        schema: mock_schema
      )

      item = %{id: 1}

      fun = fn _item, _cfg ->
        %{
          action: "test",
          actor_id: "actor",
          target_id: "target",
          environment: "test"
        }
      end

      # Don't pass otp_app, should auto-detect
      result = Audit.log(item, fun)

      assert {:ok, _log} = result
    end

    test "raises error when configuration is missing" do
      # Ensure no config exists
      Application.delete_env(:farsight, Farsight.Audit)

      item = %{id: 1}
      fun = fn _item, _cfg -> %{} end

      assert_raise RuntimeError, ~r/Farsight configuration is missing/, fn ->
        Audit.log(item, fun, otp_app: :farsight)
      end
    end

    test "raises error when configuration is empty list" do
      Application.put_env(:farsight, Farsight.Audit, [])

      item = %{id: 1}
      fun = fn _item, _cfg -> %{} end

      assert_raise RuntimeError, ~r/Farsight configuration is missing/, fn ->
        Audit.log(item, fun, otp_app: :farsight)
      end
    end

    test "raises error when configuration is invalid type" do
      Application.put_env(:farsight, Farsight.Audit, "invalid")

      item = %{id: 1}
      fun = fn _item, _cfg -> %{} end

      assert_raise RuntimeError, ~r/Invalid Farsight configuration/, fn ->
        Audit.log(item, fun, otp_app: :farsight)
      end
    end

    test "raises error when cannot detect otp_app and no config found" do
      # Remove all Farsight configs from loaded apps
      Application.loaded_applications()
      |> Enum.each(fn {app, _, _} ->
        Application.delete_env(app, Farsight.Audit)
      end)

      item = %{id: 1}
      fun = fn _item, _cfg -> %{} end

      assert_raise RuntimeError, ~r/Could not detect your OTP application/, fn ->
        Audit.log(item, fun)
      end
    end

    test "requires repo and schema in config" do
      mock_schema = create_mock_schema()
      mock_repo = create_mock_repo()

      Application.put_env(:farsight, Farsight.Audit,
        repo: mock_repo,
        schema: mock_schema
      )

      item = %{id: 1}

      fun = fn _item, cfg ->
        # Try to access required keys
        Keyword.fetch!(cfg, :repo)
        Keyword.fetch!(cfg, :schema)

        %{
          action: "test",
          actor_id: "actor",
          target_id: "target",
          environment: "test"
        }
      end

      result = Audit.log(item, fun, otp_app: :farsight)

      assert {:ok, _log} = result
    end
  end

  # Mock modules defined at module level to avoid redefinition warnings
  defmodule MockSchema do
    defstruct [:action, :actor_id, :target_id, :environment, :metadata]

    def changeset(struct, attrs) do
      %Ecto.Changeset{
        valid?: true,
        data: struct,
        changes: attrs
      }
    end
  end

  defmodule MockRepo do
    def insert(changeset) do
      if changeset.valid? do
        {:ok, struct(changeset.data, changeset.changes)}
      else
        {:error, changeset}
      end
    end
  end

  # Helper functions to return mock modules
  defp create_mock_schema, do: MockSchema
  defp create_mock_repo, do: MockRepo
end
