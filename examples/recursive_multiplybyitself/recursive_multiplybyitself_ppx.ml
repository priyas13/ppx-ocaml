open Ast_mapper
open Ast_helper
open Asttypes
open Parsetree
open Longident

let rec expr_mapper mapper expr =
   begin match expr with
      | { pexp_desc =
          Pexp_extension ({ txt = "recursive_multiplybyitself"; loc }, pstr)} ->
        begin match pstr with
        | PStr [{ pstr_desc =
                  Pstr_eval (expression, _)}] ->
                            Exp.apply  (Exp.ident {txt = Lident "*"; loc=(!default_loc)})
                                        [(Nolabel, expr_mapper mapper expression);
                                         (Nolabel, expr_mapper mapper expression)]
        | _ -> raise (Location.Error (Location.error ~loc "Syntax error"))
        end
      (* Delegate to the default mapper. *)
      | x -> default_mapper.expr mapper x;
  end

let recursive_multiplybyitself_mapper argv =
  {
    default_mapper with
    expr = expr_mapper;
  }

let () = register "recursive_multiplybyitself" recursive_multiplybyitself_mapper
