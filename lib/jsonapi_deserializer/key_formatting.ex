defmodule JsonApiDeserializer.KeyFormatting do
  def parse(params) when is_list(params), do: Enum.map(params, &parse/1)

  def parse(params) when is_map(params) do
    Enum.reduce(params, %{}, fn {key, val}, map ->
      Map.put(map, format_key(key), parse(val))
    end)
  end

  def parse(params), do: params

  def format_key(key) do
    case Application.get_env(:jsonapi_deserializer, :key_format, :dasherized) do
      :dasherized -> dash_to_underscore(key)
      :underscored -> key
      {:custom, module, _, fun} -> apply(module, fun, [key])
      _ -> key
    end
  end

  defp dash_to_underscore(key), do: String.replace(key, "-", "_")
end
