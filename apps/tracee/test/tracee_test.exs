defmodule TraceeTest do
  use ExUnit.Case
  doctest Tracee

  test "greets the world" do
    assert Tracee.hello() == :world
  end
end
