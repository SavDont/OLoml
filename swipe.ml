open Pool
open Yojson.Basic

module type Swipe = sig
  (* exposed so people can input decisions? *)
  type decision =
    | Dislike
    | Like of score
    | Neutral

  type swipe_item

  type swipe_results = (swipe_item * decision) list

  val swipe : swipe_results -> swipe_item -> decision -> swipe_results

  val gen_swipe_results : swipe_results -> json

end

module MakeSwipe (T : TupleComparable) : Swipe
  with type swipe_item = T.value = struct
  type swipe_item = T.value
  type decision =
    | Dislike
    | Like of score
    | Neutral

  (* identifying student + decision for each netid in class *)
  type swipe_results = (swipe_item * decision) list

  (* updates decision for a single (swipe_item, decision) tuple *)
  let updated_decision si d sid_tuple =
    if fst sid_tuple = si then (fst sid_tuple, d)
    else sid_tuple

  let swipe current_swipes si d =
    List.map (updated_decision si d) current_swipes

  let convert_result (si,d) =
    match d with
    | Dislike -> -1.0
    | Like v -> v
    | Neutral -> 0.0

  let rec lst_to_string = function
    | [] -> ""
    | h::m::t -> (string_of_float h)^","^(lst_to_string (m::t))
    | h::t -> (string_of_float h)^(lst_to_string (t))

  let gen_swipe_results s_results =
    let lst = List.map (convert_result) s_results in
    let str_lst = "["^(lst_to_string lst)^"]" in
    from_string str_lst

end

module SwipeStudentPool = MakeSwipe(StudentScores)
