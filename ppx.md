# ppx-ocaml
* PPX stands for “PreProcessor eXtensions” which allows the users to add entirely new syntax and features to the OCaml language.
* Writting a preprocessor that takes a program written in an extended syntax and convert it into the vanilla programming language is a tedious job. 
* PPX are implemented as OCaml programs which are plugged into the OCaml compiler.
* A ppx-rewriter is a binary which receives an AST produced by the parser, performs some transformation, and outputs a modified AST.
* A typical ppx is ppx_deriving [@@_] which automatically generated code from OCaml data structures.
* OCaml compiler does not know anything about the ppx_deriving extension, it needs to be invoked in such a way that the extension runs over the code.
* If ppx extension is not plugged into the compiler then compiler will have no clue about the extensions to the language that ppx rewriter is trying to make. 
* Compiler must be invoked in such a way as to run the ppx extension over the code.
* The documentation for an extension will typically explain how to tell the compiler how to invoke the plugin.
* For example, for using the ppx-deriving and its show component we need to add flags "-package ppx_deriving.show" when invoking ocamlfind.
## How does PPX works behind the scene?
* The OCaml compiler works in several steps. When we give any code to the compiler, it first converts the OCaml code into an internal data structure called AST.
* OCaml compiler looks for the tokens % or @@ or some similar constructs in our code in the AST. Software implementing PPX will walk through the AST to look for the attribute nodes. For example, ppx_deriving looks for the attribute node starting with @@deriving.
When the PPX finds such constructs, arbitrary actions are taken.
* A PPX converts a valid AST to a valid AST.
* As we know the AST is generated before the type-checking, optimization, code generation, all the PPX transformation are syntactic.
Some more insights [here](https://ocamlverse.github.io/content/ppx.html)
## Ppx-rewriter for Ocaml data types and Irmin types
We need to work on getting a ppx-rewriter which receives OCaml data type AST produced by the parser, performs some transformation, and output a modified Irmin supported data type AST. OCaml grammar has the support for extension nodes. These extension nodes help in extending the existing language. Extension nodes are generic placeholder in the syntax tree (syntax tree is a tree representation of the syntactic structure of source code written in any programming language).

## Writing PPXs
* A PPX is implemented as an executable that reads a binary serialized form of OCaml AST and writes a transformed binary serialized AST.
* OCaml compiler simply runs each of the ppx executables it has been asked to invoke, feeding each one of the serialized AST and getting it back again.
* OCaml AST format is not guaranteed to remain the same between versions of the compiler. Indeed, the OCaml AST changes significantly between compiler versions.
* Without the use of libraries that deal with changes in the AST format, PPXs would break with every compiler update. 

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
ocamlfind ppx_tools/dumpast -e "[%multiplybyitself 2]"
```
multiplybyitself 2 --> 2 * 2
![AST-mult](https://github.com/priyas13/ppx-ocaml/blob/master/AST-mult.png)

### Example 3
```
[let f x = x * x in f 5]
```
The following command is used to produce the AST of the above expression 
```
ocamlfind ppx_tools/dumpast -e "[let f x = x * x in f 5]"
```
![AST-let](https://github.com/priyas13/ppx-ocaml/blob/master/AST-let.png)

In the above example 1 and 2, addone and multiplybyitself are the extension nodes that are extended by the ppx-rewriter.

- PPX-rewriter is a binary that accepts an AST and transforms it into another AST. 
- If we save the above code in a .ml file and try to compile it without using the PPX, it will give error because OCaml compiler is not familiar with the addone keyword. It is not present in the language syntax. 

### AST description
[parsetree.mli](https://github.com/ocaml/ocaml/blob/trunk/parsing/parsetree.mli) 
contains the interface of the implementation of the grammar of AST generated during parsing.

### PPX for example 2:
```
open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

let expr_mapper mapper expr =
   begin match expr with
      | { pexp_desc =
          Pexp_extension ({ txt = "multiplybyitself"; loc }, pstr)} ->
        begin match pstr with
        | PStr [{ pstr_desc =
                  Pstr_eval (expression, _)}] ->
                            Exp.apply  (Exp.ident {txt = Lident "*"; loc=(!default_loc)})
                                        [(Nolabel, expression);
                                         (Nolabel, expression)]
        | _ -> raise (Location.Error (Location.error ~loc "Syntax error"))
        end
      (* Delegate to the default mapper. *)
      | x -> default_mapper.expr mapper x;
  end

let multiplybyitself_mapper argv =
  {
    default_mapper with
    expr = expr_mapper;
  }

let () = register "multiplybyitself" multiplybyitself_mapper
```
- Line 98: addone_mapper is the custom mapper which replaces the expr field in the default mapper with our own expr_mapper. The expr_mapper only deals with expressions and patterns, hence all other AST types remains untouched. 
- As in the example, we could see the expression is addone hence addone is the extension node.
- The definition of expr_mapper matches the expression against an extension node with the identifier addone. So first the expression is matched against the extension node and then pattern match against the expression on line 88. 
- multiplybyitself 2 --> 2 * 2
As we could see here addone is reduced to application of function * on the input 2.
That is applying the function * on the original expression/payload provided in the expression multiplybyitself 2.

### How to build up the rewriter?
```
ocamlbuild -package compiler-libs.common multiplybyitself.native
```
The above command build up the ppx rewriter. Dependency is compiler-libs which is the place for necessary modules. 

### Checking the rewriter:
```
ocamlfind ppx_tools/rewriter ./multiplybyitself_ppx.native multiplybyitself.ml
```
This outputs 2 * 2. This tool allows outputting rewritten source code to a file rather than stdout. 

## How to deal with recursion?
Suppose for the above example, [%multiplybyitself 2], we want to have recursive call to multiplybyitself. Something like this [%multiplybyitself [%multiplybyitself 2]]. 
[%multiplybyitself [%multiplybyitself 2]] should get reduce to (2 * 2) * (2 * 2).
The code can be found in the example section [recursive_multiplybyitself](https://github.com/priyas13/ppx-ocaml/tree/master/examples/recursive_multiplybyitself)






