(* <variable> = 'a'-'z' ; ('a' - 'z' or 'A'-'Z' or '0' - '9')^* *)
type variable = string

(* <lambda-exppr> = 
      <variable> | lambda <variable> <lambda_expr> | <lambda_expr> <lambda_expr>
   *)
type lambda_expr = 
    Variable of variable 
  | Lambda of variable * lambda_expr 
  | Application of lambda_expr * lambda_expr

type tokens = LPAREN | RPAREN | LAMBDA | DOT | CHAR of char

module Token = 
struct 
  type t = tokens
  let equal (x : t) (y : t) : bool = x = y
end

module TokenParserCombinator = ParserCombinator.Make(ParserM.Make(Token))
open TokenParserCombinator

let check_char p = function 
| CHAR c -> p c
| _ -> false

let is_lowercase c = Char.code 'a' <= Char.code c && Char.code c <= Char.code 'z'
let lowercase : token parser_m = sat (check_char is_lowercase)
let is_uppercase c = Char.code 'A' <= Char.code c && Char.code c <= Char.code 'Z'
let uppercase : token parser_m = sat (check_char is_uppercase)
let is_numeric c = Char.code '0' <= Char.code c && Char.code c <= Char.code '9'
let numeric : token parser_m = sat (check_char is_numeric)

let alphanum = lowercase ++ uppercase ++ numeric

let variable = 
  let* first = lowercase in 
  let* rest = star alphanum in 

  let variable_name_list = first :: rest in 
  let get_chars = function 
  | CHAR c -> c 
  | _ -> failwith "all tokens should be CHARs" in 

  let chars = List.map get_chars variable_name_list in 
  let b = Buffer.create 0 in 
  List.iter (Buffer.add_char b) chars;

  return (Variable (Buffer.contents b))

let lambda : token parser_m = sat (Token.equal LAMBDA) 
let dot : token parser_m = sat (Token.equal DOT) 
let lparen : token parser_m = sat (Token.equal LPAREN)
let rparen : token parser_m = sat (Token.equal RPAREN)

let rec lambda_expr ()  = variable ++ lambda_fn () ++ application ()
and lambda_fn () = 
  let* _ = lambda in 
  let* variable_name = variable in 
  let* _ = dot in 
  let* expr = lambda_expr () in 
  match variable_name with 
  | Variable v -> return (Lambda (v, expr))
  | _ -> zero ~error:"this should be impossible"
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

let lambda_calc () = 
  let () = match lambda_expr () [CHAR 'a'; CHAR 'b'] with 
  | Ok (x, _) -> 
    if x = Variable "ab" then () else failwith "failed to parse variable"
  | Error _ -> failwith "failed to parse" in 
  let () = match lambda_expr () [
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
    ] with 
  | Ok (x, _) -> 
    if x = Application (
      Variable "z12", 
      Lambda ("x", 
        Lambda ("y", Variable "z")
      )
    ) then () else failwith "invalid parse"
  | Error _ -> failwith "failed to parse" in 
  ()  