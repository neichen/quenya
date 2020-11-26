defmodule Quenya.Parser.Util do
  @moduledoc """
  Utility functions
  """

  @doc """
  Update the map recursively for $ref
  """
  def update_map(components, %{"$ref" => path}, recursive, process_ref_fn) do
    process_ref_fn.(components, path, recursive)
  end

  def update_map(components, val, recursive, process_ref_fn) when is_map(val) do
    Enum.reduce(val, %{}, fn {k, v}, acc ->
      result =
        case v do
          %{"$ref" => _path} ->
            update_map(components, v, recursive, process_ref_fn)

          v when is_list(v) ->
            Enum.map(v, fn item -> update_map(components, item, recursive, process_ref_fn) end)

          v when is_map(v) ->
            update_map(components, v, recursive, process_ref_fn)

          v ->
            v
        end

      Map.put(acc, k, result)
    end)
  end

  def update_map(_components, val, _recursive, _process_ref_fn), do: val
end
