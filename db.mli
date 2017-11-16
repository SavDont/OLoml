(* [make_query query] takes a string [query] that represents a SQL query
 * and returns the data produces by running the query on the database via the
 * pgocaml *)
val make_query : string -> 'a option
(* should call connect somewhere maybe *)
