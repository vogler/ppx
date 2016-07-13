open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

(* (A x, _ | _, A x) [@when x<>0] -> 1 (* problem: or patterns need to be in brackets, leading | becomes syntax error, compiles w/o ppx but then w/o the guard -> unacceptable *) *)

let rec when_mapper argv =
  let case_to_cases mapper = function
    | { pc_lhs = {
          ppat_desc = pattern;
          ppat_loc = loc;
          ppat_attributes = [{ txt = "when"; _}, payload]
        };
        pc_guard = guard;
        pc_rhs = e
      } ->
      begin match pattern, guard, payload with
        | Ppat_or (p1, p2), None, PStr [{ pstr_desc = Pstr_eval (g,_) }] ->
          let e = (when_mapper argv).expr mapper e in
          [Exp.case p1 ~guard:g e
          ;Exp.case p2 ~guard:g e]
        | _ ->
          raise (Location.Error (Location.error ~loc "[@when g] currently only supports simple or-patterns without additional guards, where g is the guard that should be checked for each pattern."))
      end
    | x -> [default_mapper.case mapper x]
  in
  { default_mapper with
    cases = fun m xs -> List.map (case_to_cases m) xs |> List.flatten }

let () = register "when" when_mapper
(*
ocamlc -dparsetree foo.ml
ocamlbuild -package compiler-libs.common ppx_foo.native
ocamlc -dsource -ppx ./ppx_foo.native foo.ml
*)
