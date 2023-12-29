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

let check_char p = function CHAR c -> p c | _ -> false

let is_lowercase c =
  Char.code 'a' <= Char.code c && Char.code c <= Char.code 'z'

let lowercase : token parser_m = sat (check_char is_lowercase)

let is_uppercase c =
  Char.code 'A' <= Char.code c && Char.code c <= Char.code 'Z'

let uppercase : token parser_m = sat (check_char is_uppercase)
let is_numeric c = Char.code '0' <= Char.code c && Char.code c <= Char.code '9'
let numeric : token parser_m = sat (check_char is_numeric)
let alphanum = lowercase ++ uppercase ++ numeric

let variable_str =
  let* first = lowercase in
  let* rest = star alphanum in

  let variable_name_list = first :: rest in
  let get_chars = function
    | CHAR c -> c
    | _ -> failwith "all tokens should be CHARs"
  in

  let chars = List.map get_chars variable_name_list in
  let b = Buffer.create 0 in
  List.iter (Buffer.add_char b) chars;

  return (Buffer.contents b)

let variable =
  let* v = variable_str in
  return (Variable v)
let lambda : token parser_m = sat (Token.equal LAMBDA)
let dot : token parser_m = sat (Token.equal DOT)
let lparen : token parser_m = sat (Token.equal LPAREN)
let rparen : token parser_m = sat (Token.equal RPAREN)

let rec lambda_expr () = variable ++ lambda_fn () ++ application ()

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
