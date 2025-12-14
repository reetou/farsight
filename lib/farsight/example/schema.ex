defmodule Farsight.Example.Schema do
  @moduledoc """
  Schema for the example audit log.
  This schema will be used to store the audit logs for the example application.

  Recommended fields:
  - action: The action that is being logged.
  - actor_id: The ID of the actor that is performing the action.
  - target_id: The ID of the target item.
  - environment: The environment that the action is being performed in.
  - metadata: A map of metadata to be stored with the audit log.
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
