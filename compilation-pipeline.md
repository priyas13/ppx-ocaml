# Compilation pipeline of OCaml
The compiler generates the intermediate files with different filename extensions to use as it advances through the compilation sages. 
* OCaml source files which mainly contain the implementation are saved with .ml extension.
* OCaml interface files which mainly contain the signature of any module are saved with .mli extension
* The file with .mll are the lexer files for tokenising .ml or .mli file
* The file with .mly are used for specifying the grammar. Generates a parser for specified grammar.

The various stages are:
![compilation-pipeline](https://github.com/priyas13/ppx-ocaml/blob/master/compilation-rename.png)
* When the source code written in OCaml is passed to the OCaml compiler, its first task is to parse the text into a   structured AST. The parsing codes are present here [parsing-directory](https://github.com/ocaml/ocaml/tree/trunk/parsing). The source code is transformed into AST which mainly consist of following:
  * constant: int, char, float, strings
  * attribute: identifiers or keywords. These are ignored by the type checker
  * extension: generic placeholder in the syntax tree
  * payload: contents of an attribute or an extension - structure, signature, type or a pattern
  
- Parser outputs AST which is passed to the next stage of the compilation. Hence if any source code does not matched the syntactic structure then parser throw an error. These error are represented as "syntax error". White space and comments are removed while parsing. The job of the parser is to recognize whether the code fits into the context-free grammar or not.
- OCaml provides the facility to extend standard-language grammar without having to modify the compiler. OCaml includes system for writing extensible parsers. OCaml are provided with libraries that are used to define grammars, as well as dynamically loadable syntax extensions of such grammars. Campl4 register new language keywords and later transforms these keywords into conventional OCaml code that can be handled by the compiler. 
* The AST produced in above stage is an untyped AST. Now AST needs to pass through the next compilation stage where it is checked against the rules of OCaml type system. Code that is syntactically correct is passed through the first stage but the code that had type errors are caught here. OCaml support the feature of type inference which is inspired by Hindley and Milner algorithm. This stage converts the untyped AST to typed AST. The typed AST tree contains the precise location of each token in the file, and decorates each token with the type information.
* Once the typed parse tree is generated, the source code is free from syntax and type errors. Now the job of the compiler is to generate the executables.
* The first stage is producing the untyped lambda form which eliminates all the static type information into simpler lambda form. It replaces high level constructs like modules, classes etc and replace them with low-level values like records, pointers etc. It maps the source code into run-time memory model. In this stage, the pattern-matching are optimized by making sure that the pattern match jumps to the right case.
* The next stage is generating the executable code. The executable code can be bytecode or native code. The bytecode files have .cmo extension. The bytecode file is then linked to other OCaml libraries to produce executable codes.
  
  
A good source of understanding OCaml internals : [ocaml-internals](https://github.com/ocamllabs/ocaml-internals/wiki)
