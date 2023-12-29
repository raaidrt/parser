open CharParserCombinator

let alphanum =
  sat
    (fun x -> Char.code '0' <= Char.code x && Char.code x <= Char.code '9')
    ~error:"character is not alphanumeric"

let rec eval ?(acc = 0) (cs : token list) =
  match cs with
  | [] -> acc
  | c :: cs -> eval cs ~acc:((acc * 10) + (Char.code c - Char.code '0'))

let nat = plus alphanum

let value : int =
  match nat (Core.String.to_list "56") with Ok (xs, []) -> eval xs | _ -> failwith "impossible"

let%expect_test "check value" =
  print_endline (Int.to_string value);
  [%expect {| 56 |}]
