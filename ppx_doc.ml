
open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident


let mapper argv =
  { default_mapper with
    expr = (fun mapper expr ->
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
      | x -> default_mapper.expr mapper x);
    module_binding = (fun mapper mbind ->
      let f_attr (loc,payload) = loc.txt in
      print_endline @@ "attributes: " ^ (String.concat ", " @@ List.map f_attr  mbind.pmb_attributes);
      print_endline @@ "module " ^ mbind.pmb_name.txt;
      default_mapper.module_binding mapper mbind);
    (*module_declaration = fun mapper mdecl -> mdecl;*)
    (*module_expr = fun mapper mexpr -> mexpr;*)
  }

(* ocamlc -dparsetree foo.ml *)
(* ocamlc -dtypedtree foo.ml *)
(* ocamlbuild -package compiler-libs.common ppx_getenv.native *)
(* ocamlc -dsource -ppx ./ppx_getenv.native foo.ml *)
let () = register "doc" mapper
