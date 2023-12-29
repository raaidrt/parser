# Monadic Parser Combinator

A Parser Combinator is a modular libary for building parsers that
allows us to create more complicated parsers by sequencing and choice
operators.

A Monadic Parser Combinator is a great way to model seqeuncing operations
in a clean and intuitive fashion. The paper from which the implementation is
based on has been linked [here](https://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf).

## Core Parser Combinator
The Core Parser Combinator can be found in `lib/parserm`. This consists of just the
two methods
```ocaml
val (>>=) : 'a parser_m -> ('a -> 'b parser_m) -> 'b parser_m

val return : 'a -> 'a parser_m
```

The type `'a parser_m` is `token list -> ('a * token list, string) result`, which basically
means that if the parse is successful after consuming some tokens, then we generate some
``Ok (a, cs)` where `a` is some arbitrary structure that is parametrized by the type
parameter `'a`, and `cs` is the unconsumed tokens.

The infix operator `(>>=)` is called `bind`, and has the useful syntactical sugar
`let*`. Together with `return` which basically returns a parser that does not consume any
tokens and returns `Ok (x, cs)` where `x` is the argument to `return` and `cs` is the
unconsumed tokens.

The `bind` operator together with `return` forms a monad for the parser type, and
we can perform some useful monadic comprehension like below:
```ocaml
let star p = plus p ++ return []
and plus p =
    let* x = p in
    let* xs = star p in
    return (x :: xs)
```
Where `star` applies the parser `p` zero or more times, and `plus` applies the parser `p` one or
more times.
