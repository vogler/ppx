p=${1-"ppx_attr_guard"}
ocamlbuild -package compiler-libs.common $p.native && ocamlfind ppx_tools/rewriter ./$p.native when.ml
