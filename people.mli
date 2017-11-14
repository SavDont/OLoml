(* [person] is the type representing the complete data and metadata of a
 * user of this application *)
type person

(* [personData] is the type representing incomplete data about a person
 * that users are able to update in the SQL database *)
type personData

(* [netid] is the type representing a key used to identify users
 * in the SQL database. *)
type netid = string

(* [get_person id] is the complete profile of the user identified by id *)
val get_person: netid -> person

(* [get_all_persons ()] is the list of all profiles of users who are
 * registered to use this application*)
val get_all_persons: unit -> person list

(* [update_person id d] updates the data corresponding to d in the
 * SQL database that is in the profile of the user identified by id.
 * Side-effect: updates the SQL database *)
val update_person: netid -> personData -> person

(* [add_person p] adds the p to the SQL database
 * Side-effect: Updates the SQL database*)
val add_person: person -> unit
