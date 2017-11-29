open pgocaml
open Yojson.Basic

let check_cred_query dbh tbl creds =
  PGSQL(dbh) "SELECT Password FROM $tbl WHERE Netid = $creds"

let check_period_query dbh tbl date =
  failwith "Unimplemented"

let check_period_set dbh tbl =
  if ((PGSQL(dbh) "SELECT Update FROM $tbl") != null
      ||  (PGSQL(dbh) "SELECT Swipe FROM $tbl") != null
      ||  (PGSQL(dbh) "SELECT Match FROM $tbl") != null) then false
  else true

let set_period_query dbh tbl periods =
  let jsn = from_string periods in
  let update_dt = jsn |> Util.member "update" |> Util.to_int in
  let swipe_dt = jsn |> Util.member "swipe" |> Util.to_int in
  let match_dt = jsn |> Util.member "match" |> Util.to_int in

  if check_period_set dbh tbl then
    PGSQL(dbh) "INSERT INTO $tbl (Update, Swipe, Match)
                VALUES ($update_dt, $swipe_dt, $match_dt)"
  else ()

let get_student_query dbh tbl netid =
  match PGSQL(dbh) "SELECT * FROM $tbl WHERE Netid = $netid" with
  |(jnetid,jname,jyr,jsched,jcourses,jskills,jhrs,jprof,jloc) ->
    let name = ("name", jname) in
    let netid = ("netid", jnetid) in
    let year = ("year", jyr) in
    let sched = ("schedule", jsched) in
    let courses = ("courses_taken", jcourses) in
    let skills = ("skills", jskills)) in
    let hrs = ("hours_to_spend", jhrs) in
    let prof = ("profile_text", jprof) in
    let loc = ("location", jloc)) in
  let jsonobj = `Assoc[name;netid;year;sched;courses;skills;hrs;prof;loc] in
  Yojson.Basic.to_string jsonobj
