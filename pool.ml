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
end

module StudentPool : Pool = struct
  type key = score
  type value = Student.student
  type pool = (key * value) list

(* comparator function for score,student tuples
 * Note: comparison is "backwards" to allow for max-heap *)
  let score_compare (sc1, st1) (sc2, st2) =
    if sc1 < sc2 then 1
    else if sc1 > sc2 then -1
    else 0

  (* p is sorted from greatest to least *)
  let rep_ok p =
    List.sort (score_compare) p = p

  let empty = []

  let is_empty p = (p = [])

  let push v p =
    List.sort (score_compare) (v::p)

  let peek = function
    | [] -> None
    | h::t -> Some h

  let pop = function
    | [] -> []
    | h::t -> t

  let size p = List.length p

  let poolify s s_lst =
    failwith "unimplemented"
end

module type Swipe = sig
  type decision
  type swipe_results
  val swipe : swipe_results -> Student.student -> decision -> swipe_results
  val write_swipe_results : swipe_results -> unit
end

(* Swiping on a pool -- have pool as input? *)
module StudentSwipe : Swipe = struct
  type decision =
    (* if student "likes" a student, we care about compatibility *)
    | Dislike
    | Like of score
    | Neutral

  (* identifying student + decision for each netid in class *)
  type swipe_results = (Student.student * ((Student.student * decision) list))

(* TODO: figure out how to initialize list of just net-id's?
 * initializes swipe list for a given student
 * do we want the whole class here to make merging the swipe list easier? *)
  (* let init_swipelst s =
    let all_students = Professor.get_all_students () in
    let dec_tuples = List.map (fun s -> (s,Neutral)) all_students in
    (s, dec_tuples) *)

  (* updates decision for a single (student, decision) tuple *)
  let updated_decision s d sd_tuple =
    if fst sd_tuple = s then (fst sd_tuple, d)
    else sd_tuple

  let swipe current_swipes s d =
    let lst = List.map (updated_decision s d) (snd current_swipes) in
    (fst current_swipes, lst)

  (* Put list into good form for inserting into database ((netid,int) list?)*)
  let normalize sd_tuple =
    failwith "unimplemented"

  let write_swipe_results s_results =
    failwith "unimplemented"
end
