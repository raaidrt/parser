open! ParserM

module type ParserCombinatorSig = sig 
  include ParserMSig
  val (++) : 'a parser_m -> 'a parser_m -> 'a parser_m
  val (>>) : 'a parser_m -> 'a parser_m -> 'a parser_m
  val (<<) : 'a parser_m -> 'a parser_m -> 'a parser_m
  val zero : error:string -> 'a parser_m
  val item : token parser_m
  val star : 'a parser_m -> 'a list parser_m
  val plus : 'a parser_m -> 'a list parser_m
  val sat : (token -> bool) -> ?error:string -> token parser_m
end

module Make (Monad : ParserMSig) : ParserCombinatorSig with type token = Monad.token = 
struct
  include Monad

  let (++) p q = fun cs -> 
    match p cs with 
    | Ok _ as x -> x 
    | Error _ -> q cs

  let (>>) p q = 
    let* _ = p in q 
  let (<<) p q = 
    let* x = p in q >> return x

  let zero ~error _ = 
    Error error

  let item = function 
  | [] -> Error "expecting an item, got empty"
  | c :: cs -> Ok (c, cs)

  let rec star p = 
    (let* x = p in 
    let* xs = star p in 
    (return (x :: xs))) ++ (return [])

  let plus p = 
    let* x = p in 
    let* xs = star p in 
    return (x :: xs)

  let sat p ?error = item >>= function 
  | x -> if p x then return x else zero ~error:(
    match error with 
    | None -> "predicate does not match"
    | Some error -> error
  )
end