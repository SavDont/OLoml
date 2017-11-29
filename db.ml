open pgocaml
open Yojson.Basic

let check_cred_query dbh tbl creds =
  PGSQL(dbh) "SELECT password FROM $tbl WHERE netid = $creds"

let check_period_query dbh tbl date =
  failwith "Unimplemented"
