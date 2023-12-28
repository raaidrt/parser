open CharParserCombinator

let nat_test () = 
  let alphanum = 
    sat (
      fun x -> Char.code '0' <= Char.code x && Char.code x <= Char.code '9'
    ) ~error:"character is not alphanumeric" in 

  let rec eval ?(acc = 0) (cs : token list) = 
    match cs with 
    | [] -> acc
    | c :: cs -> eval cs ~acc:(acc * 10 + (Char.code c - Char.code '0')) in 

  let nat = plus alphanum in 

  let value : int = match (nat % "56") with 
  | Ok (xs, []) -> eval xs
  | _ -> failwith "impossible" in 

  let () = assert (Int.equal value 56) in 
  ()
