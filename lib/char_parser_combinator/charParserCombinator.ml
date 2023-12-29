module Monad = ParserM.Make (Char)
module CharParserCombinatorModule = ParserCombinator.Make (Monad)
include CharParserCombinatorModule

let in_range a b =
  let* x = item in
  if Char.(code a <= code x && code x <= code b)
  then return x
  else
    let error_msg : string = Printf.sprintf "%c not in range of %c and %c" x a b in
    zero ~error:error_msg
