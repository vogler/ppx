p=${1-"ppx_ext_expr"}
ocamlbuild -package compiler-libs.common $p.native && ocamlfind ppx_tools/rewriter ./$p.native example.ml
