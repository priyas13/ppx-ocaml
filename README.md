# ppx-ocaml

A ppx-rewriter is a binary which receives an AST produced by the parser, performs some transformation, and outputs a modified AST.

## Ppx-rewriter for Ocaml data types and Irmin types
We need to work on getting a ppx-rewriter which recieves OCaml data type AST produced by the parser, performs some transformation, and output a modified Irmin supported data type AST. OCaml grammar has the support for extension nodes. These extension nodes help in extending the existing language. Extension nodes are generic placeholder in the syntax tree (syntax tree is a tree representation of the syntactic structure of source code written in any programming language).

### Example
Example taken from [A Tutorial to OCaml -ppx Language Extensions](https://victor.darvariu.me/jekyll/update/2018/06/19/ppx-tutorial.html)
```
[%addone 1 + 2]
```

In the above expression extension nodes are made up of two parts: an attribute id (addone) and the payload (the expression 1 + 2). The attribute id identifies which type of extension node it represents so that it can be handled by the appropriate rewriter, while the payload is the body of the expression that needs to be rewritten according to the logic of language extension. 

The semantic of addone 1 + 2 is
addone 1 + 2 --> (1 + 2) + 1

addone is the extension node which is like a keyword in a language. 

### Let us talk about the compilation pipeline of OCaml
The compiler generates the intermediate files with different filename extensions to use as it advances through the compilation sages. 
* OCaml source files which mainly contain the implementation are saved with .ml extension.
* OCaml interface files which mainly contain the signature of any module are saved with .mli extension
* The file with .mll are the lexer files for tokenising .ml or .mli file
* The file with .mly are used for specifying the grammar. Generates a parser for specified grammar.

The various stages are:
![compilation-pipeline](https://github.com/priyas13/ppx-ocaml/blob/master/compilation-rename.png)
* When the source code written in OCaml is passed to the OCaml compiler, its first task is to parse the text into a structured AST. The parsing codes are present here [parsing-directory](https://github.com/ocaml/ocaml/tree/trunk/parsing). The source code is transformed into AST which mainly consist of following:
 * constant: int, char, float, strings
 * attribute: identifiers or keywords. These are ignored by the type checker
 * extension: generic placeholder in the syntax tree
 * payload: contents of an attribute or an extension - structure, signature, type or a pattern
