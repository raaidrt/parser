module Monad : ParserM.ParserMSig with type token = Char.t

module CharParserCombinatorModule :
  ParserCombinator.ParserCombinatorSig with type token = Monad.token

include ParserCombinator.ParserCombinatorSig with type token = Char.t

val ( % ) : 'a parser_m -> string -> ('a * token list, string) result
(** [%] a function used for parsing a string *)
