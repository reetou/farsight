# Farsight

Farsight is an Elixir library that provides a simple, flexible interface for recording audit log events in your application. It helps you track who did what, when, and where by providing a lightweight wrapper around Ecto for persisting audit trail data.

## Features

- **Simple API**: Log audit events with a clean, function-based interface
- **Flexible Configuration**: Use your own Ecto repo and schema for complete control over your audit log structure
- **Transaction Support**: Works seamlessly within database transactions
- **Customizable**: Create wrapper modules tailored to your application's needs

## What is it?

Farsight provides a standardized way to record audit events (like user actions, data changes, etc.) in your Elixir/Phoenix applications. It handles the mechanics of inserting audit log records while giving you full control over what data gets logged and how it's structured.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `farsight` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:farsight, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/farsight>.
