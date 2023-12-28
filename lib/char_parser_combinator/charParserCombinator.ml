module Monad = ParserM.Make(Char)
module CharParserCombinatorModule = ParserCombinator.Make (Monad)

include CharParserCombinatorModule

let explode s = 
  List.init (String.length s) (fun i -> String.get s i) 

let (%) (p : 'a parser_m) s = p (explode s)