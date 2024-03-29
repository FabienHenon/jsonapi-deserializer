# JsonApiDeserializer

Json api deserializer able to deserialize json api documents with relationships for Elixir projects.

## Installation

The package can be installed by adding `jsonapi_deserializer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jsonapi_deserializer, "~> 0.1.0"}
  ]
end
```

Documentation [https://hexdocs.pm/jsonapi_deserializer](https://hexdocs.pm/jsonapi_deserializer).

## Example 

Using the json api deserializer with a payload like this:

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