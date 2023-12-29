open ParserM

module type ParserCombinatorSig = sig
  include ParserMSig

  val ( ++ ) : 'a parser_m -> 'a parser_m -> 'a parser_m
  (** [++] a function used for choice *)

  val ( >> ) : 'a parser_m -> 'a parser_m -> 'a parser_m
  (** [>>] this function ensures that [p >> q] is a parser that 
        ignores the result of parsing [p], and just parses the remaining 
        tokens with q *)

  val ( << ) : 'a parser_m -> 'a parser_m -> 'a parser_m
  (** [<<] this function ensures that [p << q] is a parser that 
        parses using p then q, but then ignores the result from q and just uses 
        the result from p *)

  val zero : error:string -> 'a parser_m
  (** [zero] is a parser that takes an error string and returns a parser that 
        always errors out*)

  val item : token parser_m
  (** [item] is a parser that parses one token [x] from [x::xs] and 
        returns [Ok (x, xs)] *)

  val star : 'a parser_m -> 'a list parser_m
  (** [star p] parses using [p] zero or more times *)

  val plus : 'a parser_m -> 'a list parser_m
  (** [plus p] parses using [p] one or more times *)

  val sat : (token -> bool) -> ?error:string -> token parser_m
  (** [sat p ?error] is a parser that results in an [Error] if 
        with error message [error] if the first token does not satisfy predicate [p],
        otherwise returns [Ok (x, xs)] where [x] is the first token parsed and 
        [xs] are the remaining tokens *)
end

module Make (Monad : ParserMSig) :
  ParserCombinatorSig with type token = Monad.token
