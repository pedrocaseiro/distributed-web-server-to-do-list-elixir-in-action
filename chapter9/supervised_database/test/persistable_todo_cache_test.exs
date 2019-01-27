defmodule PersistableTodoCacheTest do
  use ExUnit.Case
  doctest PersistableTodoCache

  test "greets the world" do
    assert PersistableTodoCache.hello() == :world
  end
end
