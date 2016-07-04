## Problem

OCaml complains about cyclic dependencies (see `a.ml`, `b.ml`):

```
> ocamlbuild a.native
Circular build detected (a.cmx already seen in [ b.cmx; a.cmx ])
```

Mutually recursive modules have to be defined in the same file.
Possible solution: [ppx_include](https://github.com/whitequark/ppx_include)
