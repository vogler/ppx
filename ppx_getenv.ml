open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

let getenv s = try Sys.getenv s with Not_found -> ""

let getenv_mapper argv =
  (* Our getenv_mapper only overrides the handling of expressions in the default mapper. *)
  { default_mapper with
    expr = fun mapper expr ->
      match expr with
      (* Is this an extension node? *)
      | { pexp_desc =
          (* Should have name "getenv". *)
          Pexp_extension ({ txt = "getenv"; loc }, pstr)} ->
        begin match pstr with
        | (* Should have a single structure item, which is evaluation of a constant string. *)
          PStr [{ pstr_desc =
                  Pstr_eval ({ pexp_loc  = loc;
                               pexp_desc = Pexp_constant (Const_string (sym, None))}, _)}] ->
          (* Replace with a constant string with the value from the environment. *)
          Exp.constant ~loc (Const_string (getenv sym, None))
        | _ ->
          raise (Location.Error (
                  Location.error ~loc "[%getenv] accepts a string, e.g. [%getenv \"USER\"]"))
        end
      (* Delegate to the default mapper. *)
      | x -> default_mapper.expr mapper x;
  }

let () = register "getenv" getenv_mapper
(*
ocamlc -dparsetree getenv.ml
ocamlbuild -package compiler-libs.common ppx_getenv.native
ocamlc -dsource -ppx ./ppx_getenv.native getenv.ml
or
ocamlfind ppx_tools/rewriter ./ppx_getenv.native getenv.ml
*)
