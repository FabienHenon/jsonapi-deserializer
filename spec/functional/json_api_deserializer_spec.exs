defmodule JsonApiDeserializerSpec do
  use ESpec, async: true

  describe "deserialize" do
    let!(:payload, do: valid_payload(:ok))

    subject(do: JsonApiDeserializer.deserialize(payload()))

    context "when payload is valid" do
      context "when payload has relationships and data is a list" do
        it(do: is_expected() |> to(be_ok_result()))

        it(
          do:
            is_expected()
            |> to(
              eql(
                {:ok,
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
                 ]}
              )
            )
        )
      end

      context "when relationship object is empty" do
        let!(:payload, do: valid_payload(:empty_relationship_object))

        it(do: is_expected() |> to(be_ok_result()))

        it(
          do:
            is_expected()
            |> to(
              eql(
                {:ok,
                 %{
                   "__metadata" => %{
                     "links" => %{"self" => "http://link-to-post/1"},
                     "type" => "posts"
                   },
                   "content" => "First post content",
                   "creator" => nil,
                   "id" => "13608770-76dd-47e5-a1c4-4d0d9c2483ad",
                   "title" => "First post"
                 }}
              )
            )
        )
      end
    end

    context "when payload is invalid" do
      context "when this is not valid json" do
        let!(:payload, do: invalid_payload(:bad_json))

        it(do: is_expected() |> to_not(be_ok_result()))
      end

      context "when data is not present" do
        let!(:payload, do: invalid_payload(:invalid_data))

        it(do: is_expected() |> to_not(be_ok_result()))

        it(do: is_expected() |> to(eql({:error, :invalid_data})))
      end

      context "when relationships object is not valid" do
        let!(:payload, do: invalid_payload(:bad_relationships_type))

        it(do: is_expected() |> to_not(be_ok_result()))

        it(do: is_expected() |> to(eql({:error, :bad_relationships_type})))
      end

      context "when included object is not valid" do
        let!(:payload, do: invalid_payload(:bad_included_type))

        it(do: is_expected() |> to_not(be_ok_result()))

        it(do: is_expected() |> to(eql({:error, :bad_included_type})))
      end

      context "when relationship is not found" do
        let!(:payload, do: invalid_payload(:relationship_not_found))

        it(do: is_expected() |> to_not(be_ok_result()))

        it(do: is_expected() |> to(eql({:error, :relationship_not_found})))
      end

      context "when relationship data object is not valid" do
        let!(:payload, do: invalid_payload(:bad_relationship_data))

        it(do: is_expected() |> to_not(be_ok_result()))

        it(do: is_expected() |> to(eql({:error, :bad_relationship_data})))
      end
    end
  end

  def valid_payload(:ok) do
    """
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
    """
  end

  def valid_payload(:empty_relationship_object) do
    """
    {
        "data": {
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
                "creator": {}
            }
        }
    }
    """
  end

  def invalid_payload(:bad_json) do
    """
    {
        "data":
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
                }
            }
        },
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
            }
        ]
    }
    """
  end

  def invalid_payload(:invalid_data) do
    """
    {
        "no-data": {
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
                }
            }
        },
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
            }
        ]
    }
    """
  end

  def invalid_payload(:bad_relationships_type) do
    """
    {
        "data": {
            "type": "posts",
            "id": "13608770-76dd-47e5-a1c4-4d0d9c2483ad",
            "links": {
                "self": "http://link-to-post/1"
            },
            "attributes": {
                "title": "First post",
                "content": "First post content"
            },
            "relationships": [
              {
                "creator": {
                    "data": {
                        "type": "creators",
                        "id": "22208770-76dd-47e5-a1c4-4d0d9c2483ad"
                    },
                    "links": {
                        "related": "http://link-to-creator/1"
                    }
                }
              }
            ]
        },
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
            }
        ]
    }
    """
  end

  def invalid_payload(:bad_included_type) do
    """
    {
        "data": {
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
                }
            }
        }
    }
    """
  end

  def invalid_payload(:relationship_not_found) do
    """
    {
        "data": {
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
                        "id": "22208770-76dd-47e5-a1c4-bad"
                    },
                    "links": {
                        "related": "http://link-to-creator/1"
                    }
                }
            }
        },
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
            }
        ]
    }
    """
  end

  def invalid_payload(:bad_relationship_data) do
    """
    {
        "data": {
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
                        "no-id": "22208770-76dd-47e5-a1c4-4d0d9c2483ad"
                    },
                    "links": {
                        "related": "http://link-to-creator/1"
                    }
                }
            }
        },
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
            }
        ]
    }
    """
  end
end
