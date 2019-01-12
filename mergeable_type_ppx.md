# Building the ppx rewriter 
ocamlbuild -package lwt -package cohttp-lwt -package ppx_sexp_conv -package ppx_bin_prot -package ocaml-migrate-parsetree.driver-main ppx_dali.native

This works fine, the ppx rewriter is build up succefully. But I dont know whether it is correct.

# For producing the transformed code
./ppx_dali.native canvas.ml

Not working. 
