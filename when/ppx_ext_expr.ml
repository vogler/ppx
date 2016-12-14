open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

let rec mapper argv =
  let case_to_cases m = function
    | { pc_lhs = { ppat_desc = Ppat_or (p1, p2) };
        pc_guard = Some guard;
        pc_rhs
      } ->
        let e = (mapper argv).expr m pc_rhs in
        [Exp.case p1 ~guard e
        ;Exp.case p2 ~guard e]
    | x -> [default_mapper.case m x]
  in
  let distr_mapper = { default_mapper with
    cases = fun m xs -> List.map (case_to_cases m) xs |> List.flatten }
  in
  { default_mapper with
    expr = fun m expr ->
      match expr with
      | { pexp_desc = Pexp_extension ({ txt = "distr" }, PStr [{ pstr_desc = Pstr_eval (e,a) }]) } ->
          m.expr distr_mapper { e with pexp_attributes = expr.pexp_attributes @ a }
      | x -> default_mapper.expr m x;
  }

let () = register "when" mapper
(*
ocamlc -dparsetree foo.ml
ocamlbuild -package compiler-libs.common ppx_foo.native
ocamlc -dsource -ppx ./ppx_foo.native foo.ml
*)
