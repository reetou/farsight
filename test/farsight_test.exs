defmodule FarsightTest do
  use ExUnit.Case
  doctest Farsight

  test "greets the world" do
    assert Farsight.hello() == :world
  end
end
