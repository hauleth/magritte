defmodule MagritteTest do
  use ExUnit.Case

  @subject Magritte

  use Magritte

  doctest @subject

  test "fails on doubled `^_` operator" do
    quoted =
      quote do
        2 |> Integer.to_string(^_, ^_)
      end

    assert_raise CompileError, ~r"Doubled placeholder in Integer.to_string", fn ->
      Macro.expand(quoted, __ENV__)
    end
  end

  test "works with calls without parens" do
    assert "1010" == (2 |> Integer.to_string(10, ^_))
  end

  test "multiple arguments are still passed as expected" do
    assert {1, 2, 3} == (1 |> id(2, 3))
    assert {1, 2, 3} == (1 |> id(^_, 2, 3))
    assert {1, 2, 3} == (2 |> id(1, ^_, 3))
    assert {1, 2, 3} == (3 |> id(1, 2, ^_))
  end

  def id(a, b, c), do: {a, b, c}
end
