(*
structure_item (name.ml[1,0+0]..[4,58+21])
    Pstr_module
    "Foo" (name.ml[1,0+7]..[1,0+10])
      attribute "deriving"
        [
          structure_item (name.ml[4,58+16]..[4,58+20])
            Pstr_eval
            expression (name.ml[4,58+16]..[4,58+20])
              Pexp_ident "name" (name.ml[4,58+16]..[4,58+20])
        ]
      module_expr (name.ml[1,0+13]..[4,58+3])
        Pmod_structure
        [
          structure_item (name.ml[3,45+2]..[3,45+12])
            Pstr_value Nonrec
            [
              <def>
                pattern (name.ml[3,45+6]..[3,45+7])
                  Ppat_var "v" (name.ml[3,45+6]..[3,45+7])
                expression (name.ml[3,45+10]..[3,45+12])
                  Pexp_constant Const_int 42
            ]
        ]
]
*)
open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

let modname_mapper argv =
  { default_mapper with
    module_binding = (fun mapper mbind ->
      let f_attr (loc,payload) = loc.txt in
      print_endline @@ "attributes: " ^ (String.concat ", " @@ List.map f_attr  mbind.pmb_attributes);
      print_endline @@ "module " ^ mbind.pmb_name.txt;
      default_mapper.module_binding mapper mbind);
    (*module_declaration = fun mapper mdecl -> mdecl;*)
    (*module_expr = fun mapper mexpr -> mexpr;*)
  }

(* ocamlc -dparsetree foo.ml *)
(* ocamlbuild -package compiler-libs.common ppx_getenv.native *)
(* ocamlc -dsource -ppx ./ppx_getenv.native foo.ml *)
let () = register "modname" modname_mapper
