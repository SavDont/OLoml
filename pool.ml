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

module type TupleComparable = sig
  type rank
  type item
  val tuple_comparison : (rank * item) -> (rank * item) -> int
  val tuple_gen : item -> item -> (rank * item)
  val opt_key_to_string : rank option -> string
  val get_id : item -> string
end

module MakePool (T : TupleComparable) : Pool
  with type key = T.rank
  with type value = T.item = struct

  type key = T.rank
  type value = T.item
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

  (* Hard cap of 30 students to swipe through *)
  let poolify v v_lst =
    let tuple_lst = List.map (T.tuple_gen v) v_lst in
    let tuple_lst_srt = List.sort (T.tuple_comparison) tuple_lst in
    (* Remove possibility of an item swiping on itself *)
    let rem_dupe = List.filter (fun (rnk,it) -> v <> it) tuple_lst_srt in
    let rec cut_lst = function
      | [] -> []
      | h::t ->
        if List.length (h::t) <= 1 then (h::t)
        else cut_lst t in
    cut_lst rem_dupe

module StudentScores : TupleComparable
  with type rank = score
  with type item = student
= struct

  type rank = score
  type item = student

  let tuple_comparison (sc1, st1) (sc2, st2) =
    if sc1 > sc2 then -1
    else if sc1 < sc2 then 1
    else 0

  let tuple_gen s1 s2 =
    let sched_compat = 0.30 *. sched_score s1 s2  in
    let course_compat = 0.30 *. course_score s1 s2 in
    let hours_compat = 0.25 *. hour_score s1 s2 in
    let loc_compat = 0.15 *. loc_score s1 s2 in
    (sched_compat+.course_compat+.hours_compat+.loc_compat, s2)

  (* useful for code reuse in swiping *)
  let opt_key_to_string k_opt =
    match k_opt with
    | None -> "0.0"
    | Some v -> (string_of_float v)^"0"

  let get_id st =
    st.netid
end

module StudentPool = MakePool(StudentScores)
