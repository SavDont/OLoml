(* [val check_cred_query dbh tbl netid pwd] gives results of performing a query
 * on the table [tbl] inside the database (represented by [dbh], the value
 * returned by pgocaml's connect function) that gets the corresponding password
 * for a user [creds] through the credentials table in the database and
 * comparing it to the password that the user enters [pwd]
 * requires: the table must exist inside the database and must contain
 * columns "NetId" and "Password"*)
val check_cred_query : 'a -> string -> string -> string -> string

(* [val check_period_query dbh tbl date] gives the result of performing a query
 * on the table [tbl] inside the database (represented by [dbh], the value
 * returned by pgocaml's connect function) that gets the current period based on
 * which starting date is greater than the current date.
 * requires: the table must exist inside the database and must contain
 * columns "Update", "Swipe" and "Match"*)
val check_period_query : 'a -> string -> string -> string

(* [check_period_set dbh tbl] returns true if the values in any of the
* columns are not null. returns false otherwise.
* Requires: the table must exist inside the database and must contain columns
* "Update", "Swipe", and "Match" *)
val check_period_set : 'a -> string -> bool

(* [set_period_query dbh tbl periods] returns unit. If check_period_set
 * returns true then this function queries the database (dbh) and updates
 * table (tbl) that represents the start dates of each period with the dates
 * given in the json representing the periods
 * requires: the table must exist inside the database and must contain
 * columns "Update", "Swipe", and "Match"
 * requires dates to be represented as integers of form YYYMMDD where for
 * example, November 29th, 2017 would be represented by 20171129
 * Requires: periods must be a valid representation of a json *)
val set_period_query : 'a -> string -> string -> unit

(* [get_student_query dbh tbl netid] returns a string representation of the
 * json produced by selecting all columns from the student table for a specifc
 * netID. requires that the netID exist in the database*)
val get_student_query : 'a -> string -> string -> string

(* [get_stu_match_query dbh tbl1 tbl2 netid] returns a string representation of
 * json produced by selecting all columns from the student table (tbl2) for the
 * match found in the match table (tbl1) for the netid specified.
 * Requires: table exist inside the database and netID exists in the table*)
val get_stu_match_query : 'a -> string -> string -> string

(* [change_stu_query dbh tbl net info] returns unit. This function updates the
 * table [tbl] in the database [dbh] that holds all the information about
 * students based on the data passed in through the string of json object
 * [info]. Only the data in mutable columns will be overwritten and all other
 * columns will be ignored.
 * Requires: the table must exist inside the database and the student must
 * exist in the table. *)
val change_stu_query : 'a -> string -> string -> string -> unit

(* [admin_change_query dbh tbl info] returns unit. This function updates the
 * table (tbl) in the database (dbh) based on the information provided by the
 * info string, which a string representaiton of a json object. The function
 * adds a new row to the table if the netid from the info is not already in
 * the table and it changes the netid, name and year fields of the existing
 * row if the netid is in the table already.
 * Requires: the json must only contain fields "name", "netid" and "year" and
 * all values must be non-null*)
val admin_change_query : 'a -> string -> string

(*[delete_class dbh tbl ]*)
