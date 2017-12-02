open PGOCaml
open Camlp4
open Yojson.Basic

(*Table names*)
let stu_tbl = "Students"
let match_tbl = "Matches"
let creds_tbl = "Credentials"
let periods_tbl = "Periods"
let dbh = PGOCaml.connect ()

let check_cred_query netid pwd =
  match PGSQL(dbh) "SELECT Password FROM $creds_tbl WHERE Netid = $netid" with
  | i -> if i = pwd then true else false
  | _ -> false

let check_period_set =
  if ((PGSQL(dbh) "SELECT Update FROM $periods_tbl") != None
      ||  (PGSQL(dbh) "SELECT Swipe FROM $periods_tbl") != None
      ||  (PGSQL(dbh) "SELECT Match FROM $periods_tbl") != None) then true
  else false

let set_period_query periods =
  let jsn = from_string periods in
  let update_dt = jsn |> Util.member "update" |> Util.to_float_option in
  let swipe_dt = jsn |> Util.member "swipe" |> Util.to_float_option in
  let match_dt = jsn |> Util.member "match" |> Util.to_float_option in
  if check_period_set dbh then
    (* commenting out because you can directly store Some in DB
       begin match (update_dt, swipe_dt, match_st) with
      |Some u * Some s * Some m ->
        PGSQL(dbh) "INSERT INTO $periods_tbl (Update, Swipe, Match)
        VALUES ($u, $s, $m)"
        |_ -> *)
        PGSQL(dbh) "INSERT INTO $periods_tbl (Update, Swipe, Match)
        VALUES ($update_dt, $swipe_dt, $match_dt)"
  else ()

let get_period_query =
  match PGSQL (dbh) "SELECT Update, Swipe, Match FROM $periods_tbl" with
  |(jupdate, jmatch, jswipe) ->
    let upd = ("update", jupdate) in
    let mat = ("match", jmatch) in
    let swi = ("swipe", jswipe) in
  let jsonobj = `Assoc[upd;mat;swi] in Yojson.Basic.to_string jsonobj

let get_student_query netid =
  match PGSQL(dbh) "SELECT * FROM $stu_tbl WHERE Netid = $netid" with
  |(jnetid,jname,jyr,jsched,jcourses,jhrs,jprof,jloc) ->
    let name = ("name", jname) in
    let netid = ("netid", jnetid) in
    let year = ("year", jyr) in
    let sched = ("schedule", jsched) in
    let courses = ("courses_taken", jcourses) in
    let hrs = ("hours_to_spend", jhrs) in
    let prof = ("profile_text", jprof) in
    let loc = ("location", jloc)) in
  let jsonobj = `Assoc[name;netid;year;sched;courses;hrs;prof;loc] in
  Yojson.Basic.to_string jsonobj

let get_stu_match_query netid =
  let partner = PGSQL(dbh) "SELECT Match FROM $match_tbl WHERE Stu1 = $netid" in
  match partner with
  |Some i ->
    if i = "UNMATCHED" then
      let name = ("name", None) in
      let netid = ("netid", Some "UNMATCHED") in
      let year = ("year", None) in
      let sched = ("schedule", None) in
      let courses = ("courses_taken", None) in
      let hrs = ("hours_to_spend", None) in
      let prof = ("profile_text", None) in
      let loc = ("location", None)) in
      let jsonobj = `Assoc[name;netid;year;sched;courses;hrs;prof;loc] in
      Yojson.Basic.to_string jsonobj
    else get_student_query dbh i
  |_ -> let name = ("name", None) in
    let netid = ("netid", None) in
    let year = ("year", None) in
    let sched = ("schedule", None) in
    let courses = ("courses_taken", None) in
    let hrs = ("hours_to_spend", None) in
    let prof = ("profile_text", None) in
    let loc = ("location", None)) in
    let jsonobj = `Assoc[name;netid;year;sched;courses;hrs;prof;loc] in
    Yojson.Basic.to_string jsonobj

(*helper functions that change each specific field if the field exists in the
 * json *)
let change_sched net info =
  let jsn = from_string info in
  begin match jsn |> Util.member "schedule" |> Util.to_string_option with
    |None -> ()
    |i -> PGSQL(dbh) "INSERT INTO $stu_tbl (Schedule) VALUES ($i)
                WHERE Netid = $net"
  end

  let change_courses net info =
    let jsn = from_string info in
    begin match jsn |> Util.member "classes_taken" |> Util.to_string_option with
      |None -> ()
      |i -> PGSQL(dbh) "UPDATE $stu_tbl SET Courses = $i WHERE Netid = $net"
    end

  let change_hours net info =
    let jsn = from_string info in
    begin match jsn |> Util.member "hours_to_spend" |> Util.to_int_option with
      |None -> ()
      |i -> PGSQL(dbh) "UPDATE $stu_tbl SET Hours = $i WHERE Netid = $net"
    end

  let change_prof net info =
    let jsn = from_string info in
    begin match jsn |> Util.member "profile_text" |> Util.to_string_option with
      |None -> ()
      |i -> PGSQL(dbh) "UPDATE $stu_tbl SET Profile = $i WHERE Netid = $net"
    end

  let change_loc net info =
    let jsn = from_string info in
    begin match jsn |> Util.member "location" |> Util.to_string_option with
      |None -> ()
      |i -> PGSQL(dbh) "UPDATE $stu_tbl SET Location = $i WHERE Netid = $net"
    end

let change_stu_query net info =
  let a = change_sched dbh net info in
  let b = change_courses dbh net info in
  let c = change_hours dbh net info in
  let d = change_prof dbh net info in
  let e = change_loc dbh net info in
  match [a;b;c;d;e] with
  |_ -> ()

let admin_change_query info =
  let jsn = from_string info in
  let new_name = jsn |> Util.member "name" |> Util.to_string_option in
  let new_id = jsn |> Util.member "netid" |> Util.to_string_option in
  let new_year = jsn |> Util.member "year" |> Util.to_string_option in
  PGSQL(dbh) "INSERT INTO $stu_tbl (Netid, Name, Year) VALUES
    ($new_id, $new_name, $new_year) ON DUPLICATE KEY UPDATE
    Name = $new_name, Year = $new_year"

let reset_class =
  PGSQL(dbh) "TRUNCATE $stu_tbl, $match_tbl, $creds_tbl, $periods_tbl"
