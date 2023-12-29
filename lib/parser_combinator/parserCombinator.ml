open ParserM

module type ParserCombinatorSig = sig
  include ParserMSig

  val any : 'a parser_m list -> 'a parser_m
  val ignore_fst : _ parser_m -> 'a parser_m -> 'a parser_m
  val ignore_snd : 'a parser_m -> _ parser_m -> 'a parser_m
  val zero : error:string -> 'a parser_m
  val item : token parser_m
  val star : 'a parser_m -> 'a list parser_m
  val plus : 'a parser_m -> 'a list parser_m
  val sat : (token -> bool) -> ?error:string -> token parser_m
end

module Make (Monad : ParserMSig) :
  ParserCombinatorSig with type token = Monad.token = struct
  include Monad

  let zero ~error _ = Error error

  let rec any ps cs =
    match ps with
    | [] -> Error "no matches"
    | p :: ps ->
      match p cs with
      | Ok _ as x -> x
      | Error _ -> any ps cs

  let ignore_fst p q = bind p (fun _ -> q)

  let ignore_snd p q = bind p (fun x -> ignore_fst q (return x))

  let item = function
    | [] -> Error "expecting an item, got empty"
    | c :: cs -> Ok (c, cs)

  let rec star p = any [plus p; return []]

  and plus p =
    let* x = p in
    let* xs = star p in
    return (x :: xs)

  let sat p ?error =
    bind item (fun x ->
        if p x then return x
        else
          zero
            ~error:
              (match error with
              | None -> "predicate does not match"
              | Some error -> error))
end
