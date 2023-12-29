module type ParserMSig = sig
  (** [ParserM] is a signature for the parser monad
        @author Raaid Tanveer **)

  type token
  (** [parser_m] is the type for the parser monad that takes in a token list and
        produces an abstract syntax tree of parametrized type 'a **)

  type 'a parser_m = token list -> ('a * token list, string) result

  val bind : 'a parser_m -> ('a -> 'b parser_m) -> 'b parser_m
  (** [bind] binds a parser [p] with the function [f] such that
        the result of [p] is passed into [f], which returns a new parser that
        is finally returned *)

  val ( let* ) : 'a parser_m -> ('a -> 'b parser_m) -> 'b parser_m
  (** [let*] is syntactical sygar for [>>=] *)

  val return : 'a -> 'a parser_m
  (** [return x] is a parser that consumes no tokens, and returns
        [Ok (x, cs)] where [cs] is the unconsumed list of tokens *)
end

module Make (Token : Base.Equal.S) : ParserMSig with type token = Token.t
