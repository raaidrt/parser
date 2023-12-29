module type Distinguishable = sig
  type t

  val equal : t -> t -> bool
end

module type ParserMSig = sig
  type token
  type 'a parser_m = token list -> ('a * token list, string) result

  val ( >>= ) : 'a parser_m -> ('a -> 'b parser_m) -> 'b parser_m
  val ( let* ) : 'a parser_m -> ('a -> 'b parser_m) -> 'b parser_m
  val return : 'a -> 'a parser_m
end

module Make (Token : Distinguishable) : ParserMSig with type token = Token.t =
struct
  type token = Token.t
  type 'a parser_m = token list -> ('a * token list, string) result

  let ( >>= ) p f (cs : token list) =
    match p cs with Ok (x, y) -> f x y | Error _ as x -> x

  let ( let* ) p f = p >>= f
  let return x cs = Ok (x, cs)
end
