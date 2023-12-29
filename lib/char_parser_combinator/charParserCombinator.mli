module Monad : ParserM.ParserMSig with type token = Char.t

module CharParserCombinatorModule :
  ParserCombinator.ParserCombinatorSig with type token = Monad.token

include ParserCombinator.ParserCombinatorSig with type token = Char.t

val in_range : char -> char -> char parser_m
(** [in_range a b] is a parser that consumes one [char] token and succeeds if
    the token is within the range of [a] and [b] *)
