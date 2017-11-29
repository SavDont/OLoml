(* [val check_cred_query dbh tbl creds] gives the results of performing a query
 * on the table [tbl] inside the database (represented by [dbh], the value
 * returned by pgocaml's connect function) that gets the corresponding password
 * for a user [creds] through the credentials table in the database.
 * requires: the table must exist inside the database and must contain
 * columns "NetId" and "Password"*)
val check_cred_query : 'a -> string -> string -> string

(* [val check_period_query dbh tbl date] gives the result of performing a query
 * on the table [tbl] inside the database (represented by [dbh], the value
 * returned by pgocaml's connect function) that gets the current period based on
 * which starting date is greater than the current date.
 * requires: the table must exist inside the database and must contain
 * columns "Update", "Swipe" and "Match"*)
val check_period_query : 'a -> string -> string -> string

(* [check_period_set dbh tbl] returns false if the values in any of the
* columns are not null. returns true otherwise.
* requires: the table must exist inside the database and must contain columns
* "Update", "Swipe", and "Match" *)
val check_period_set : string -> string -> bool

(* [set_period_query dbh tbl periods] returns unit. If check_period_set
 * returns true then this function queries the database (dbh) and updates
 * table (tbl) that represents the start dates of each period with the dates
 * given in the json representing the periods
 * requires: the table must exist inside the database and must contain
 * columns "Update", "Swipe", and "Match"
 * requires dates to be represented as integers of form YYYMMDD where for
 * example, November 29th, 2017 would be represented by 20171129
 * retuires: periods must be a valid representation of a json *)
val set_period_query : string -> string -> string -> unit

(* [get_student_query dbh tbl netid] returns a string representation of the
 * json produced by selecting all columns from the student table for a specifc
 * netID. requires that the netID exist in the database*)
val get_student_query : string -> string -> string -> string

(* [get_stu_match_query dbh tbl1 tbl2 netid] returns a string representation of
 * json produced by selecting all columns from the student table (tbl2) for the
 * match found in the match table (tbl1) for the netid specified.
 * requires that the netID exist in the database*)
val get_stu_match_query : string -> string -> string -> string
