type netid = string

type daySchedule = {morning : bool; afternoon : bool; evening : bool}

type schedule = {
  monday : daySchedule;
  tuesday : daySchedule;
  wednesday : daySchedule;
  thursday : daySchedule;
  friday : daySchedule;
  saturday : daySchedule;
  sunday : daySchedule;
}

type classYear =
  | Fresh
  | Soph
  | Jun
  | Sen

(* possible CS courses a student can have taken
 * Only went up to 4000 level--do we want to include more? *)
type course =
  | CS_1110 | CS_1112 | CS_1300 | CS_2022 | CS_2024 | CS_2043 | CS_2044
  | CS_2110 | CS_2112 | CS_2300 | CS_2800 | CS_3110 | CS_3410 | CS_3420
  | CS_4110 | CS_4120 | CS_4152 | CS_4210 | CS_4220 | CS_4300 | CS_4320
  | CS_4410 | CS_4420 | CS_4620 | CS_4670 | CS_4700 | CS_4740 | CS_4750
  | CS_4780 | CS_4820 | CS_4850

(* int from 1 to 5 dictates proficiency
 * add more skills? *)
type skill =
  | Java of int
  | Python of int
  | C of int
  | Ruby of int
  | Javascript of int
  | SQL of int
  | OCaml of int

type student = {
  name : string;
  netid : netid;
  year : classYear;
  schedule : schedule;
  courses_taken : course list;
  skills : skill list;
  hours_to_spend : int
}

(* [authenticate netID pwd] returns [true] iff pwd = the password associated
 * with netID in the database and [false] otherwise *)
val authenticate : netid -> string -> bool

(* [get_student netID] returns Some s iff a student with netID exists in the
 * database and s is that student. Otherwise, return None *)
val get_student : netid -> student option

(* [update_student netID] returns Some s iff a student with netID exists
 * in the database. s is that student updated with studentData.
 * Otherwise, return None
 * side effect: writes to the DB *)
val update_student : netid -> student -> student option

(* [get_match netID] returns Some s iff a student with netID exists in the
 * database and that student (Ezra) has a match. s is Ezra's match and
 * None otherwise *)
val get_match : netid -> student option
