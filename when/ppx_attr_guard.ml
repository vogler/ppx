open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

(* | A x, _ | _, A x when (x<>0) [@distr] -> 1 (* w/o ppx we only get w57, problem: guard expr needs to be in brackets, and we need to annotate every guard *) *)

let rec when_mapper argv =
  let case_to_cases mapper = function
    | { pc_lhs = { ppat_desc = pattern };
        pc_guard = Some ({
          pexp_loc = loc;
          pexp_attributes = ({ txt = "distr"; _}, _) :: attrs
        } as guard);
        pc_rhs
      } ->
      begin match pattern with
        | Ppat_or (p1, p2) ->
          let e = (when_mapper argv).expr mapper pc_rhs in
          let g = { guard with pexp_attributes = attrs } in
          [Exp.case p1 ~guard:g e
          ;Exp.case p2 ~guard:g e]
        | _ ->
          raise (Location.Error (Location.error ~loc "[@distr] currently only supports simple or-patterns."))
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
