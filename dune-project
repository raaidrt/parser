(lang dune 3.12)

(name parser)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Raaid Tanveer")

(maintainers "Raaid Tanveer")

(license LICENSE)

(package
 (name parser)
 (synopsis "A Monadic Parser Combinator")
 (description "This is a Parser Combinator using a Parser Monad that abstracts on the type of Tokens.")
 (depends ocaml dune)
 (tags
  (parser combinator "functional programming" compilers lexing lexers)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
