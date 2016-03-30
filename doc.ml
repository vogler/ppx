type t = { a : int [@default 0] [@doc "foo"] } [@@doc "bar"] [@@deriving create, doc]
