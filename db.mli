(* [val check_cred_query netid pwd] gives results of performing a query
 * on the Credentials table inside the database
 * that gets the corresponding password for a user [creds] through the
 * credentials table in the database and comparing it to the password that the
 * user enters [pwd]. returns true if pwd matches the database value
 * requires: the table must exist inside the database and must contain
 * columns "NetId" and "Password"*)
val check_cred_query : string -> string -> bool


(* [check_period_set] returns true if the values in any of the
* columns in the Periods table are not null. returns false otherwise.
* Requires: the table must exist inside the database and must contain columns
* "Update", "Swipe", and "Match" *)
val check_period_set : bool

(* [set_period_query periods] returns unit. If check_period_set
 * returns true then this function queries the database and updates
 * Periods table that represents the start dates of each period with the dates
 * given in the json representing the periods
 * requires: the table must exist inside the database and must contain
 * columns "Update", "Swipe", and "Match"
 * requires dates to be represented as floats
 * Requires: periods must be a valid representation of a json *)
val set_period_query : string -> unit

(*[get_period_query] returns a string representation of the json produced
 * by performing a query on the Periods table in the database that selects all
 * the start dates in the period table. The string representation of the json
 * has fields "update", "match" and "swipe" each with float options containing
 * the start dates of each of these periods
*)
val get_period_query : string

(* [get_student_query netid] returns a string representation of the
 * json produced by selecting all columns from the Students table for a specifc
 * netID. requires that the netID exist in the database*)
val get_student_query : string -> string

(* [get_stu_match_query netid] returns a string representation of
 * json produced by selecting all columns from the Students table for the
 * match found in the Matches table for the netid specified.
 * Requires: table exist inside the database and netID exists in the table*)
val get_stu_match_query : string -> string

(*[post_matches_query matches] returns unit. It updates the matches table in
 * the databse so to include the netid, netid pairs of student matches*)
val post_matches_query : string -> unit

(* [change_stu_query net info] returns unit. This function updates the
 * Students table in the database that holds all the information about
 * students based on the data passed in through the string of json object
 * [info]. Only the data in mutable columns will be overwritten and all other
 * columns will be ignored.
 * Requires: the table must exist inside the database and the student must
 * exist in the table. *)
val change_stu_query : string -> string -> unit

(* [admin_change_query info] returns unit. This function updates the
 * Students table in the database based on the information provided by the
 * info string, which a string representaiton of a json object. The function
 * adds a new row to the table if the netid from the info is not already in
 * the table and it changes the netid, name and year fields of the existing
 * row if the netid is in the table already.
 * Requires: the json must only contain fields "name", "netid" and "year" and
 * all values must be non-null*)
val admin_change_query : string -> unit

(*[delete_students students] returns unit. This function updates the database
 *by deleting the students who have netids matching the ones in the string of
 *json representation passed into the function through (students)*)
val delete_students : string -> unit

(*[set_swipesswipes] returns unit. This function updates the database by storing
  swipe results for each student passed in through the string representation of
  a json (swipes) *)
val set_swipes : string -> unit

(*[get_swipes] returns a string representation of json for
 * the swipes in the swipes table*)
val get_swipes : string

(*[reset_class] returns unit. This function updates the database by
 *deleting all the information in all the tables in the database*)
val reset_class : unit
