defmodule Magritte do
  @moduledoc """
  Alternative pipe operator definition.

  ## Usage

  Just add `use Magritte` to the top of your module and then 
  follow the documentation for `Margitte.|>/2` below.
  """

  defmacro __using__(_) do
    quote do
      import Kernel, except: [|>: 2]
      import unquote(__MODULE__), only: [|>: 2]
    end
  end

  @doc """
  Enhanced pipe operator.

  This operator introduces the expression on the left-hand side as an argument 
  to the function call on the right-hand side. The `...` placeholder operator  
  determines the position of the given argument on the right-hand side. 

  If the `...` operator is not present, the first position is used by default.

  ## Examples

  ```elixir
  iex> [1, [2], 3] |> List.flatten()
  [1, 2, 3]
  ```

  The example above is the same as calling `List.flatten([1, [2], 3])`.

  Using `...` you can pick the position where the result of the left side will 
  be inserted:

  ```elixir
  iex> 2 |> Integer.to_string(10, ...)
  "1010"
  ```

  The example above is the same as calling `Integer.to_string(10, 2)`.

  You can also join these into longer chains:

  ```elixir
  iex> 2 |> Integer.to_string(10, ...) |> Integer.parse
  {1010, ""}
  ```

  The operator `...` can be used only once in the pipeline, otherwise
  it will return compile-time error:

  ```elixir
  2 |> Integer.to_string(..., ...)
  ** (CompileError) Doubled placeholder in Integer.to_string(..., ...)
  ```
  """
  defmacro left |> right do
    [{h, _} | t] = unpipe({:|>, [], [left, right]}, __CALLER__)

    fun = fn {x, pos}, acc ->
      Macro.pipe(acc, x, pos)
    end

    :lists.foldl(fun, h, t)
  end

  defp unpipe(ast, caller), do: :lists.reverse(unpipe(ast, [], caller))

  defp unpipe({:|>, _, [left, right]}, acc, caller) do
    unpipe(right, unpipe(left, acc, caller), caller)
  end

  defp unpipe(ast, acc, %Macro.Env{line: line, file: file}) do
    case find_pos(ast) do
      {:ok, new_ast, pos} ->
        [{new_ast, pos} | acc]

      {:error, {:already_found, _, _}} ->
        raise CompileError,
          file: file,
          line: line,
          description: "Doubled placeholder in #{Macro.to_string(ast)}"
    end
  end


  defguardp is_empty(a) when a == [] or not is_list(a)

  defp find_pos({fun, env, args}) when not is_empty(args) do
    with {:ok, found, new_args} <- locate(args, 0, nil, []),
         do: {:ok, {fun, env, new_args}, found}
  end

  defp find_pos(ast), do: {:ok, ast, 0}

  pattern = quote do: {:..., _, var!(args)}

  defp locate([unquote(pattern) | rest], pos, nil, acc) when is_empty(args),
    do: locate(rest, pos + 1, pos, acc)

  defp locate([unquote(pattern) | _], pos, found, _acc) when is_empty(args),
    do: {:error, {:already_found, found, pos}}

  defp locate([arg | rest], pos, found, args),
    do: locate(rest, pos + 1, found, [arg | args])

  defp locate([], _, found, args),
    do: {:ok, found || 0, :lists.reverse(args)}
end
