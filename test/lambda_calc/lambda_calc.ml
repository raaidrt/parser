open Sexplib.Std

(* <variable> = 'a'-'z' ; ('a' - 'z' or 'A'-'Z' or '0' - '9')^* *)
type variable = string [@@deriving sexp]

(* <lambda-exppr> =
      <variable> | lambda <variable> <lambda_expr> | ((<lambda_expr>) (<lambda_expr>))
*)
type lambda_expr =
  | Variable of variable
  | Lambda of variable * lambda_expr
  | Application of lambda_expr * lambda_expr
[@@deriving sexp]

type tokens = LPAREN | RPAREN | LAMBDA | DOT | CHAR of char [@@deriving sexp]
type ok_result = lambda_expr * tokens list [@@deriving sexp]
type error_result = string [@@deriving sexp]

let sexp_of_result = function
  | Ok (x, y) -> sexp_of_ok_result (x, y)
  | Error err -> sexp_of_error_result err

module Token = struct
  type t = tokens

  let equal (x : t) (y : t) : bool = x = y
end

module TokenParserCombinator = ParserCombinator.Make (ParserM.Make (Token))
open TokenParserCombinator

let char_of = function
  | CHAR c -> return c
  | _ -> zero ~error:"expecting char, received invalid token"

let in_range a b =
  let* x = bind item char_of in
  if Char.(code a <= code x && code x <= code b)
  then return x
  else zero ~error:(Printf.sprintf "char %c is not in range of [%c, %c]" x a b)

let alphanum = any [in_range 'a' 'z'; in_range 'A' 'Z'; in_range '0' '9']

let variable_str =
  let* first = (in_range 'a' 'z') in
  let* rest = star alphanum in

  let variable_name_list = first :: rest in
  let b = Buffer.create 0 in
  List.iter (Buffer.add_char b) variable_name_list;

  return (Buffer.contents b)

let variable =
  let* v = variable_str in
  return (Variable v)

let lambda : token parser_m = sat (Token.equal LAMBDA)

let dot : token parser_m = sat (Token.equal DOT)

let lparen : token parser_m = sat (Token.equal LPAREN)

let rparen : token parser_m = sat (Token.equal RPAREN)

let rec lambda_expr () = any [variable; lambda_fn (); application ()]

and lambda_fn () =
  let* _ = lambda in
  let* variable_name = variable_str in
  let* _ = dot in
  let* expr = lambda_expr () in

  return (Lambda (variable_name, expr))

and application () =
  let* _ = lparen in
  let* _ = lparen in
  let* m = lambda_expr () in
  let* _ = rparen in

  let* _ = lparen in
  let* n = lambda_expr () in
  let* _ = rparen in
  let* _ = rparen in

  return (Application (m, n))

let%expect_test "variable name" =
  let expr = lambda_expr () [ CHAR 'a'; CHAR 'b' ] in
  let open Core in
  let sexp = sexp_of_result expr in
  print_endline (Sexp.to_string sexp);
  [%expect {| ((Variable ab)()) |}]

let%expect_test "lambda application" =
   let expr = lambda_expr ()
      [
        LPAREN;
        LPAREN;
        CHAR 'z';
        CHAR '1';
        CHAR '2';
        RPAREN;
        LPAREN;
        LAMBDA;
        CHAR 'x';
        DOT;
        LAMBDA;
        CHAR 'y';
        DOT;
        CHAR 'z';
        RPAREN;
        RPAREN;
      ] in
   let open Core in
   let sexp = sexp_of_result expr in
   print_endline (Sexp.to_string sexp);
   [%expect {| ((Application(Variable z12)(Lambda x(Lambda y(Variable z))))()) |}]
