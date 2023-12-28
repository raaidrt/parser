open Nat_test
open Lambda_calc

let () = Printf.printf "Running tests\n"
let () = Printf.printf "-------------------------------\n"

let tests = [nat_test; lambda_calc]

let run_test i test = 
  let () = Printf.printf "Running test %d..." (i + 1) in 
  let () = test () in 
  let () = Printf.printf "PASSED\n" in () 

let () = List.iteri run_test tests