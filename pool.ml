type score = float

module StudentPool : Pool = struct
  type 'a pool = (score * Student.student) list

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

end

module StudentSwipe : Swipe = struct
  type decision =
    (* if student "likes" a student, we care about compatibility *)
    | Dislike
    | Like of score
    | Neutral

  (* identifying student + decision for each netid in class *)
  type swipe_results = (Student.student * (Student.student * decision) list)

(* TODO: figure out how to initialize list of just net-id's?
 * initializes swipe list for a given student
 * do we want the whole class here to make merging the swipe list easier? *)
  let init_swipelst s =
    let all_students = Professor.get_all_students () in
    let dec_tuples = List.map (fun s -> (s,Neutral)) all_students in
    (s, dec_tuples)

  (* updates decision for a single (student, decision) tuple *)
  let updated_decision s d sd_tuple =
    if fst sd_tuple = s then (fst sd_tuple, d)
    else sd_tuple

  let swipe current_swipes s d =
    List.map (updated_decision s d) current_swipes

  (* Put list into good form for inserting into database ((netid,int) list?)*)
  let normalize sd_tuple =
    failwith "unimplemented"

  let write_swipe_results s_results =
    failwith "unimplemented"
end

(* Potential compatibility attributes:
   - Schedule
   - Skill set (professor should input desired skills, students input
     proficiency when updating profile
   - Classes they've taken
   - Hours they're willing to put into assignment
   - Preferred programming style
*)
let compatability_score s1 s2 =
  failwith "unimplemented"
