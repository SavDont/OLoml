open Student

type score = float

module type Pool = sig
  type key
  type value
  type pool
  val empty    : pool
  val is_empty : pool -> bool
  val push     : (key * value) -> pool -> pool
  val peek     : pool -> (key * value) option
  val pop      : pool -> pool
  val poolify  : value -> value list -> pool
  val size     : pool -> int
end

(* single_comparison: need to be able to compare two values and generate
 * a key, value tuple which can then be compared with other
 * key,value tuples using tuple_comparison *)
module type TupleComparable = sig
  type key
  type value
  val tuple_comparison : (key * value) -> (key * value) -> int
  val tuple_gen : value -> value -> (key * value)
  val opt_key_to_string : key option -> string
end

module MakePool (T : TupleComparable) : Pool
  with type key = T.key
  with type value = T.value = struct

  type key = T.key
  type value = T.value
  type pool = (key * value) list

  let rep_ok p =
    List.sort (T.tuple_comparison) p = p

  let empty = []

  let is_empty p = (p = [])

  let push v p =
    List.sort (T.tuple_comparison) (v::p)

  let peek = function
    | [] -> None
    | h::t -> Some h

  let pop = function
    | [] -> []
    | h::t -> t

  let size p = List.length p

  let poolify v v_lst =
    let tuple_lst = List.map (T.tuple_gen v) v_lst in
    let tuple_lst_srt = List.sort (T.tuple_comparison) tuple_lst in
    (* How many students do we want them swiping through? *)
    let max_len = (List.length tuple_lst_srt)/2 in
    let rec cut_lst lst len final_lst =
      if List.length final_lst = max_len then final_lst
      else cut_lst (List.tl lst) len (push (List.hd lst) final_lst) in
    cut_lst tuple_lst_srt max_len []

end

module StudentScores : TupleComparable
  with type key = score
  with type value = student
= struct

  type key = score
  type value = student

  let tuple_comparison (sc1, st1) (sc2, st2) =
    if sc1 > sc2 then -1
    else if sc1 < sc2 then 1
    else 0

  (* generates score for s1 and s2, tuple for s2 *)
  let tuple_gen s1 s2 =
    (Random.float 1000.0, s2) (* Replace with algorithm *)

  (* useful for code reuse in swiping *)
  let opt_key_to_string k_opt =
    match k_opt with
    | None -> "0.0"
    | Some v -> string_of_float v
end

module StudentPool = MakePool(StudentScores)
