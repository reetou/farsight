defmodule Farsight.Audit.Log.Schema do
  @moduledoc """
  Schema for the audit log.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "logs" do
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
