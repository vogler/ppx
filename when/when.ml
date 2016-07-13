type t = A of int | B

(*
let f = function
  | A x, _ (* A 0, A 1 would match here and fail the guard *)
  | _, A x when x<>0 -> 1 (* warning 57 *)
*)
let f = function
  (* attributes can be attached to pattern and expr but not when or case: *)
  (* (A x, _ | _, A x) [@when x<>0] -> 1 (* [ppx_attr_pattern.ml] problem: or patterns need to be in brackets, leading | becomes syntax error, compiles w/o ppx but then w/o the guard -> unacceptable *) *)
  (* | [%distr ? x | x | x when x<>0] -> 2 (* better: use extension nodes, but then it only works with ppx *) *)
  | A x, _ | _, A x when (x<>0) [@distr] -> 1 (* [ppx_attr_guard.ml] better: w/o ppx we only get w57, problem: guard expr needs to be in brackets, and we need to annotate every guard *)
  | _ -> 2

(*
let f = function%distr (* [ppx_ext_match.ml]: only append extension to KW, applies to all cases, no brackets, does not compile w/o ppx *)
  | A x, _ | _, A x when x<>0 -> 1
  | _ -> 2
*)

(* let () = print_endline ("Result: " ^ string_of_int (f (A 0, A 1))) *)
