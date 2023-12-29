module Monad = ParserM.Make (Char)
module CharParserCombinatorModule = ParserCombinator.Make (Monad)
include CharParserCombinatorModule

let ( % ) (p : 'a parser_m) s =
  let open Core in p (String.to_list s)
