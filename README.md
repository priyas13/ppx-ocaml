# ppx-ocaml

A ppx-rewriter is a binary which receives an AST produced by the parser, performs some transformation, and outputs a modified AST.

## Ppx-rewriter for Ocaml data types and Irmin types
We need to work on getting a ppx-rewriter which recieves OCaml data type AST produced by the parser, performs some transformation, and output a modified Irmin supported data type AST. OCaml grammar has the support for extension nodes. These extension nodes help in extending the existing language.Extension nodes are generic placeholder in the syntax tree (syntax tree is a tree representation of the syntactic structure of source code written in any programming language).
