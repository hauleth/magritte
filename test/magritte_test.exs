defmodule MagritteTest do
  use ExUnit.Case

  @subject Magritte

  use Magritte

  doctest @subject

  test "fails on doubled `...` operator" do
    quoted =
      quote do
        2 |> Integer.to_string(..., ...)
      end

    assert_raise CompileError, ~r"Doubled placeholder in Integer.to_string", fn ->
      Macro.expand(quoted, __ENV__)
    end
  end
end
