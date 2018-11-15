# ppx-ocaml
* PPX stands for “PreProcessor eXtensions” which allows the users to add entirely new syntax and features to the OCaml language.
* PPX are implemented as OCaml programs which are plugged into the OCaml compiler.
* A ppx-rewriter is a binary which receives an AST produced by the parser, performs some transformation, and outputs a modified AST.
* A typical ppx is ppx_deriving [@@_] which automatically generated code from OCaml data structures.
* OCaml compiler does not know anything about the ppx_deriving extension, it needs to be invoked in such a way that the extension runs over the code.
## How does PPX works behind the scene?
OCaml compiler looks for the tokens % or @@ or some similar constructs in our code in the AST. Software implementing PPX will walk through the AST to look for the attribute nodes. For example, ppx_deriving looks for the attribute node starting with @@deriving.
When the PPX finds such constructs, arbitrary actions are taken.
Some more insights [here](https://ocamlverse.github.io/content/ppx.html)
## Ppx-rewriter for Ocaml data types and Irmin types
We need to work on getting a ppx-rewriter which receives OCaml data type AST produced by the parser, performs some transformation, and output a modified Irmin supported data type AST. OCaml grammar has the support for extension nodes. These extension nodes help in extending the existing language. Extension nodes are generic placeholder in the syntax tree (syntax tree is a tree representation of the syntactic structure of source code written in any programming language).

## Some simple examples:
### Example 1
Example taken from [A Tutorial to OCaml -ppx Language Extensions](https://victor.darvariu.me/jekyll/update/2018/06/19/ppx-tutorial.html)
```
[%addone 1 + 2]
```

In the above expression extension nodes are made up of two parts: an attribute id (addone) and the payload (the expression 1 + 2). The attribute id identifies which type of extension node it represents so that it can be handled by the appropriate rewriter, while the payload is the body of the expression that needs to be rewritten according to the logic of language extension. 

The semantic of addone 1 + 2 is
addone 1 + 2 --> (1 + 2) + 1

addone is the extension node which is like a keyword in a language. 

The following command is used to produce the AST of the expression [%addone 1 + 2]
```
ocamlfind ppx_tools/dumpast -e "[%addone 1 + 2]"
```
![AST-addone](https://github.com/priyas13/ppx-ocaml/blob/master/AST-addone.png)

### Example 2
```
[let f x = x * x in f 5]
```
The following command is used to produce the AST of the above expression 
```
ocamlfind ppx_tools/dumpast -e "[let f x = x * x in f 5]"
```
![AST-let](https://github.com/priyas13/ppx-ocaml/blob/master/AST-let.png)
```

### AST description
[parsetree.mli](https://github.com/ocaml/ocaml/blob/trunk/parsing/parsetree.mli) contains the interface of the implementation of the grammar of AST generated during parsing.
Grammar for the expression:
```

