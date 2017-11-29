(* [make_query query] takes a string [query] that represents a SQL query
 * and returns the data produces by running the query on the database via the
 * pgocaml
val make_query : string -> 'a option
   should call connect somewhere maybe *)

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
 * columns "Semester", "Update", "Swipe" and "Match"*)
val check_period_query : 'a -> string -> string -> string
