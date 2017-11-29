open pgocaml
open Yojson.Basic

let check_cred_query dbh tbl creds =
  PGSQL(dbh) "SELECT password FROM $tbl WHERE netid = $creds"

let check_period_query dbh tbl date =
  failwith "Unimplemented"

let check_period_set dbh tbl =
  if ((PGSQL(dbh) "SELECT update FROM $tbl") != null
      ||  (PGSQL(dbh) "SELECT swipe FROM $tbl") != null
      ||  (PGSQL(dbh) "SELECT match FROM $tbl") != null) then false
  else true

let set_period_query dbh tbl periods =
  let jsn = from_string periods in
  let update_dt = jsn |> Util.member "update" |> Util.to_int in
  let swipe_dt = jsn |> Util.member "swipe" |> Util.to_int in
  let match_dt = jsn |> Util.member "match" |> Util.to_int in

  if check_period_set dbh tbl then
    PGSQL(dbh) "INSERT INTO $tbl (update, swipe, match)
                VALUES ($update_dt, $swipe_dt, $match_dt)"
  else ()
