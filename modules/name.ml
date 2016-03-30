module Foo = struct
  (*let name = [%name]*)
  let v = 42
end [@@deriving name]
