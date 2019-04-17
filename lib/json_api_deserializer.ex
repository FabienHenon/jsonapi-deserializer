defmodule JsonApiDeserializer do
  @moduledoc """
  Json api deserializer able to deserialize json api documents with relationships.

  For instance, this payload:

  ```
  {
      "data": [
          {
              "type": "posts",
              "id": "13608770-76dd-47e5-a1c4-4d0d9c2483ad",
              "links": {
                  "self": "http://link-to-post/1"
              },
              "attributes": {
                  "title": "First post",
                  "content": "First post content"
              },
              "relationships": {
                  "creator": {
                      "data": {
                          "type": "creators",
                          "id": "22208770-76dd-47e5-a1c4-4d0d9c2483ad"
                      },
                      "links": {
                          "related": "http://link-to-creator/1"
                      }
                  },
                  "comments": {
                      "links": {},
                      "data": [
                          {
                              "type": "comment",
                              "id": "22208770-76dd-47e5-a1c4-4d0d9c2483ab"
                          },
                          {
                              "type": "comment",
                              "id": "cb0759b0-03ab-4291-b067-84a9017fea6f"
                          }
                      ]
                  }
              }
          },
          {
              "type": "posts",
              "id": "13608770-76dd-47e5-a1c4-4d0d9c2483ae",
              "links": {
                  "self": "http://link-to-post/2"
              },
              "attributes": {
                  "title": "Second post",
                  "content": "Second post content"
              },
              "relationships": {
                  "creator": {
                      "data": {
                          "type": "creators",
                          "id": "22208770-76dd-47e5-a1c4-4d0d9c2483ad"
                      },
                      "links": {
                          "related": "http://lnk-to-creator/1"
                      }
                  },
                  "comments": {
                      "links": {},
                      "data": [
                          {
                              "type": "comment",
                              "id": "22208770-76dd-47e5-a1c4-4d0d9c2483ac"
                          }
                      ]
                  }
              }
          }
      ],
      "included": [
          {
              "type": "creators",
              "id": "22208770-76dd-47e5-a1c4-4d0d9c2483ad",
              "attributes": {
                  "firstname": "John",
                  "lastname": "Doe"
              },
              "links": {
                  "self": "http://link-to-creator/1"
              },
              "relationships": {}
          },
          {
              "type": "comment",
              "id": "22208770-76dd-47e5-a1c4-4d0d9c2483ac",
              "attributes": {
                  "content": "Comment 1 content",
                  "email": "john@doe.com"
              },
              "links": {
                  "self": "http://link-to-comment/1"
              },
              "relationships": {}
          },
          {
              "type": "comment",
              "id": "22208770-76dd-47e5-a1c4-4d0d9c2483ab",
              "attributes": {
                  "content": "Comment 2 content",
                  "email": "john@doe.com"
              },
              "links": {
                  "self": "http://link-to-comment/2"
              },
              "relationships": {}
          },
          {
              "type": "comment",
              "id": "cb0759b0-03ab-4291-b067-84a9017fea6f",
              "attributes": {
                  "content": "Comment 3 content",
                  "email": "john@doe.com"
              },
              "links": {
                  "self": "http://link-to-comment/3"
              },
              "relationships": {}
          }
      ]
  }
  ```

  Will be deserialized in a map like this one:

  ```
  [
    %{
      "__metadata" => %{
        "links" => %{"self" => "http://link-to-post/1"},
        "type" => "posts"
      },
      "comments" => [
        %{
          "__metadata" => %{
            "links" => %{"self" => "http://link-to-comment/2"},
            "type" => "comment"
          },
          "content" => "Comment 2 content",
          "email" => "john@doe.com",
          "id" => "22208770-76dd-47e5-a1c4-4d0d9c2483ab"
        },
        %{
          "__metadata" => %{
            "links" => %{"self" => "http://link-to-comment/3"},
            "type" => "comment"
          },
          "content" => "Comment 3 content",
          "email" => "john@doe.com",
          "id" => "cb0759b0-03ab-4291-b067-84a9017fea6f"
        }
      ],
      "content" => "First post content",
      "creator" => %{
        "__metadata" => %{
          "links" => %{"self" => "http://link-to-creator/1"},
          "type" => "creators"
        },
        "firstname" => "John",
        "id" => "22208770-76dd-47e5-a1c4-4d0d9c2483ad",
        "lastname" => "Doe"
      },
      "id" => "13608770-76dd-47e5-a1c4-4d0d9c2483ad",
      "title" => "First post"
    },
    %{
      "__metadata" => %{
        "links" => %{"self" => "http://link-to-post/2"},
        "type" => "posts"
      },
      "comments" => [
        %{
          "__metadata" => %{
            "links" => %{"self" => "http://link-to-comment/1"},
            "type" => "comment"
          },
          "content" => "Comment 1 content",
          "email" => "john@doe.com",
          "id" => "22208770-76dd-47e5-a1c4-4d0d9c2483ac"
        }
      ],
      "content" => "Second post content",
      "creator" => %{
        "__metadata" => %{
          "links" => %{"self" => "http://link-to-creator/1"},
          "type" => "creators"
        },
        "firstname" => "John",
        "id" => "22208770-76dd-47e5-a1c4-4d0d9c2483ad",
        "lastname" => "Doe"
      },
      "id" => "13608770-76dd-47e5-a1c4-4d0d9c2483ae",
      "title" => "Second post"
    }
  ]
  ```
  """

  @doc """
  Deserialize a payload.

  Payload can be a map or a string that will be decoded with `Jason`.

  The return value is `{:ok, data}` with data beeing the decoded document as a list
  or a map. Or `{:error, error}` if something went wrong when decoding.

  Possible errors are:
  * `Jason.DecodeError.t()` is an error from json decoding
  * `:invalid_data` is when `"data"` is not a map or a list
  * `:bad_relationships_type` is when `"relationships"` is not a map
  * `:bad_included_type` is when `"included"` is not a list
  * `:relationship_not_found` is when no relationship could be found for a specified type and id
  * `:bad_relationship_data` is when the relationship data does not have an `id` or a `type` field
  """
  @spec deserialize(binary() | map()) ::
          {:ok, list() | map()}
          | {:error, Jason.DecodeError.t()}
          | {:error, :invalid_data}
          | {:error, :bad_relationships_type}
          | {:error, :bad_included_type}
          | {:error, :relationship_not_found}
          | {:error, :bad_relationship_data}
  def deserialize(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, data} ->
        deserialize(data)

      {:error, error} ->
        {:error, error}
    end
  end

  def deserialize(%{"data" => data} = body) when is_list(data) do
    data
    |> Enum.map(&deserialize(&1, Map.get(body, "included")))
    |> Enum.reduce({:ok, []}, fn
      {:ok, data}, {:ok, list} ->
        {:ok, [data | list]}

      {:ok, _data}, {:error, error} ->
        {:error, error}

      {:error, error}, _ ->
        {:error, error}
    end)
    |> case do
      {:ok, list} -> {:ok, Enum.reverse(list)}
      {:error, error} -> {:error, error}
    end
  end

  def deserialize(%{"data" => data} = body), do: deserialize(data, Map.get(body, "included"))

  def deserialize(_), do: {:error, :invalid_data}

  defp deserialize(nil, _), do: {:error, :invalid_data}
  defp deserialize({:error, error}, _), do: {:error, error}

  defp deserialize(data, included) do
    case find_relationships(Map.get(data, "relationships", nil), included) do
      {:ok, relationships} ->
        {:ok,
         data
         |> Map.get("attributes", %{})
         |> Map.merge(%{"id" => Map.get(data, "id", nil)})
         |> Map.merge(%{
           "__metadata" => %{
             "type" => Map.get(data, "type", nil),
             "links" => Map.get(data, "links", nil)
           }
         })
         |> Map.merge(relationships)
         |> JsonApiDeserializer.KeyFormatting.parse()}

      {:error, error} ->
        {:error, error}
    end
  end

  defp find_relationships(nil, _), do: {:ok, %{}}

  defp find_relationships(relationships, included)
       when is_map(relationships) do
    relationships
    |> Map.to_list()
    |> Enum.reduce({:ok, %{}}, fn
      {key, value}, {:ok, map} ->
        case find_relationship(value, included) do
          {:ok, relationship} ->
            {:ok, Map.put(map, key, relationship)}

          {:error, error} ->
            {:error, error}
        end

      _key, {:error, error} ->
        {:error, error}
    end)
  end

  defp find_relationships(_, _included),
    do: {:error, :bad_relationships_type}

  defp find_relationship(%{"data" => data}, included) when is_list(data) do
    data
    |> Enum.map(&find_relationship_in_included(&1, included))
    |> Enum.reduce({:ok, []}, fn
      {:ok, data}, {:ok, list} ->
        {:ok, [data | list]}

      {:ok, _data}, {:error, error} ->
        {:error, error}

      {:error, error}, _ ->
        {:error, error}
    end)
    |> case do
      {:ok, list} -> {:ok, Enum.reverse(list)}
      {:error, error} -> {:error, error}
    end
  end

  defp find_relationship(%{"data" => data}, included),
    do: find_relationship_in_included(data, included)

  defp find_relationship(%{}, _included), do: {:ok, nil}

  defp find_relationship(_, _),
    do: {:error, :bad_relationship_object}

  defp find_relationship_in_included(%{"type" => type, "id" => id}, included)
       when is_list(included) do
    included
    |> Enum.find({:error, :relationship_not_found}, &is_relationship(type, id, &1))
    |> deserialize(included)
  end

  defp find_relationship_in_included(_, included) when is_list(included),
    do: {:error, :bad_relationship_data}

  defp find_relationship_in_included(_, _), do: {:error, :bad_included_type}

  defp is_relationship(type, id, %{"type" => type_, "id" => id_})
       when type == type_ and id == id_,
       do: true

  defp is_relationship(_, _, _), do: false
end
