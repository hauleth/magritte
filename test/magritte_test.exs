defmodule MagritteTest do
  use ExUnit.Case, async: true

  @subject Magritte

  use Magritte

  doctest @subject

  test "fails on repeated `...` operator" do
    quoted =
      quote do
        2 |> id(..., ...)
      end

    assert_raise ArgumentError, ~r"Repeated placeholder in id\(..., ...\)", fn ->
      Macro.expand(quoted, __ENV__)
    end
  end

  test "fails on non-function pipe" do
    quoted =
      quote do
        2 |> [...]
      end

    assert_raise ArgumentError, ~r"cannot pipe 2 into \[...\]", fn ->
      Macro.expand(quoted, __ENV__)
    end
  end

  test "works with calls without parens" do
    assert 1 == (1 |> id)
    assert 1 == (1 |> __MODULE__.id)
    assert 1 == (1 |> id ...)
    assert 1 == (1 |> __MODULE__.id ...)
    assert {1, 2, 3} == (1 |> id 2, 3)
    assert {1, 2, 3} == (1 |> id ..., 2, 3)
    assert {1, 2, 3} == (1 |> __MODULE__.id 2, 3)
    assert {1, 2, 3} == (1 |> __MODULE__.id ..., 2, 3)
  end

  test "unary functions are left as is" do
    assert 1 == (1 |> id())
    assert 1 == (1 |> id(...))
  end

  test "multiple arguments are still passed as expected" do
    assert {1, 2, 3} == (1 |> id(2, 3))
    assert {1, 2, 3} == (1 |> id(..., 2, 3))
    assert {1, 2, 3} == (2 |> id(1, ..., 3))
    assert {1, 2, 3} == (3 |> id(1, 2, ...))
  end

  test "remote calls" do
    assert {1, 2, 3} == (1 |> __MODULE__.id(2, 3))
    assert {1, 2, 3} == (1 |> __MODULE__.id(..., 2, 3))
    assert {1, 2, 3} == (2 |> __MODULE__.id(1, ..., 3))
    assert {1, 2, 3} == (3 |> __MODULE__.id(1, 2, ...))

    mod = __MODULE__
    assert {1, 2, 3} == (1 |> mod.id(2, 3))
    assert {1, 2, 3} == (1 |> mod.id(..., 2, 3))
    assert {1, 2, 3} == (2 |> mod.id(1, ..., 3))
    assert {1, 2, 3} == (3 |> mod.id(1, 2, ...))
  end

  test "foo" do
    ... = 1
    quoted = quote do
      id(...) |> id(..., 2, 3)
      end

    IO.inspect(Macro.expand(quoted, __ENV__))
  end

  def id(a), do: a

  def id(a, b, c), do: {a, b, c}
end
