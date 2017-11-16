type student
type studentData
type netid = string

val get_student: netid -> student

(* Side-effect: Updates the SQL database*)
val update_student: netid -> studentData -> student
