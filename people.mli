type person
type personData
type netid = string

val get_person: netid -> person

(* make a sql query to get all people *)
val get_all_persons: unit -> person list

(* Side-effect: Updates the SQL database*)
val update_person: netid -> personData -> person

(* Side-effect: Updates the SQL database*)
val add_person: person -> unit

