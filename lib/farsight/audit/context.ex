defmodule Farsight.Audit do
  @moduledoc """
  Module for logging audit logs.
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
        repo: MyApp.Repo

  """
  def log(%{} = item, fun, opts \\ []) when is_function(fun) do
    cfg = fetch_config(opts)
    log_params = fun.(item, cfg)

    schema = Keyword.fetch!(cfg, :schema)
    repo = Keyword.fetch!(cfg, :repo)

    struct(schema)
    |> schema.changeset(log_params)
    |> repo.insert()
  end

  defp fetch_config(opts) do
    otp_app = Keyword.get(opts, :otp_app) || detect_otp_app()

    Application.get_env(otp_app, __MODULE__, [])
    |> validate_config(otp_app)
  end

  defp detect_otp_app do
    # Try to find any loaded application that has Farsight configured
    find_configured_app() ||
      raise """
      Could not detect your OTP application or find Farsight configuration.

      Please configure Farsight in your config/config.exs:

          config :myapp, Farsight,
            repo: MyApp.Repo,
            schema: MyApp.Audit.Log

      Or specify the OTP app explicitly when calling:

          Farsight.Audit.log(item, fun, otp_app: :myapp)

      """
  end

  defp find_configured_app do
    Application.loaded_applications()
    |> Enum.find_value(fn {app, _, _} ->
      case Application.get_env(app, __MODULE__) do
        nil -> nil
        [] -> nil
        config when is_list(config) -> app
        _ -> nil
      end
    end)
  end

  defp validate_config([], otp_app) do
    raise """
    Farsight configuration is missing for application #{inspect(otp_app)}.

    Please add the following to your config/config.exs:

        config #{inspect(otp_app)}, Farsight,
          repo: YourApp.Repo

    """
  end

  defp validate_config(config, _otp_app) when is_list(config) do
    config
  end

  defp validate_config(invalid, otp_app) do
    raise """
    Invalid Farsight configuration for application #{inspect(otp_app)}.
    Expected a keyword list, got: #{inspect(invalid)}

    Please configure Farsight in your config/config.exs:

        config #{inspect(otp_app)}, Farsight,
          repo: YourApp.Repo

    """
  end
end
