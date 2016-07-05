(* problem: *)
let eval x = x
let long_default_expr = 42
let f = function
  | `A -> 1
  | `B x ->
    begin match eval x with
      | `C y -> y
      | _ -> long_default_expr
    end
  | _ -> long_default_expr

(* use exception for control flow? -> even more verbose *)
exception Default
let f x = try match x with
    | `A -> 1
    | `B x ->
      begin match eval x with
        | `C y -> y
        | _ -> raise Default
      end
    | _ -> raise Default
  with Default -> long_default_expr

(* thunks are ok *)
let f =
  let default () = long_default_expr in
  function
  | `A -> 1
  | `B x ->
    begin match eval x with
      | `C y -> y
      | _ -> default ()
    end
  | _ -> default ()

(* with ppx_pattern_guard: *)
let f = function
  | `A -> 1
  | `B x when [%guard let `C y = eval x] -> y
  | _ -> long_default_expr
