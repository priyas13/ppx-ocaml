# OCaml-migrate-parsetree
- Convert OCaml parsetrees between different versions
- Supported versions are 4.02, 4.03, 4.04, 4.05 and 4.06.
- For each version, there is a snapshot of the parsetree and conversion functions to the next/previous version.
Complete details can be found [here](https://github.com/ocaml-ppx/ocaml-migrate-parsetree)
```
ocamlfind ocamlopt -predicates ppx_driver -o ppx -linkpkg \
  -package ppx_sexp_conv -package ppx_bin_prot \
  -package ocaml-migrate-parsetree.driver-main
  ```
