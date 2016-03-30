module type S = sig
  val f : int -> int
end

(* module Foo [@@deriving stub] : S *)
module Foo : S = struct [%stub] end
