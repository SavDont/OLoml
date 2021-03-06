(* This mli contains all global variables, such as the server host and
 * endpoints, database table names, and any useful helper functions *)

(* api specific parameters *)
val base_url : string
val credentials_endpoint : string
val period_endpoint : string
val student_endpoint : string
val admin_endpoint : string
val swipes_endpoint : string
val matches_endpoint : string

val test_endpoint : string

(* database specific parameters *)
val stu_tbl : string
val match_tbl : string
val creds_tbl : string
val periods_tbl : string
