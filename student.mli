type student
type studentData
type schedule
type classYear
type netid = string
type course
type skill

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
val update_student : netid -> studentData -> student

(* [get_match netID] returns Some s iff a student with netID exists in the
 * database and that student (Ezra) has a match. s is Ezra's match and
 * None otherwise *)
val get_match : netid -> student option
