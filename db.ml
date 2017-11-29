open Pgocaml
open Camlp4
open Sql
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

let get_stu_match_query dbh tbl1 tbl2 netid =
  let partner =  PGSQL(dbh) "SELECT Match FROM $tbl WHERE Stu1 = $netid" in
  get_student_query dbh tbl2 partner

(*helper functions that change each specific field if the field exists in the
 * json *)
let change_sched dbh tbl net info =
  let jsn = from_string info in
  begin match jsn |> Util.member "schedule" |> Util.to_int with
    |None -> ()
    |i -> PGSQL(dbh) "INSERT INTO $tbl (Schedule) VALUES ($i)
                WHERE Netid = $net"
  end

  let change_courses dbh tbl net info =
    let jsn = from_string info in
    begin match jsn |> Util.member "classes_taken" |> Util.to_string with
      |None -> ()
      |i -> PGSQL(dbh) "UPDATE $tbl SET Courses = $i WHERE Netid = $net"
    end

  let change_skills dbh tbl net info =
    let jsn = from_string info in
    begin match jsn |> Util.member "skills" |> Util.to_string with
      |None -> ()
      |i -> PGSQL(dbh) "UPDATE $tbl SET Skills = $i WHERE Netid = $net"
    end

  let change_hours dbh tbl net info =
    let jsn = from_string info in
    begin match jsn |> Util.member "hours_to_spend" |> Util.to_int with
      |None -> ()
      |i -> PGSQL(dbh) "UPDATE $tbl SET Hours = $i WHERE Netid = $net"
    end

  let change_prof dbh tbl net info =
    let jsn = from_string info in
    begin match jsn |> Util.member "profile_text" |> Util.to_string with
      |None -> ()
      |i -> PGSQL(dbh) "UPDATE $tbl SET Profile = $i WHERE Netid = $net"
    end

  let change_loc dbh tbl net info =
    let jsn = from_string info in
    begin match jsn |> Util.member "location" |> Util.to_string with
      |None -> ()
      |i -> PGSQL(dbh) "UPDATE $tbl SET Location = $i WHERE Netid = $net"
    end

let change_stu_query dbh tbl net info =
  let a = change_sched dbh tbl net info in
  let b = change_courses dbh tbl net info in
  let c = change_skills dbh tbl net info in
  let d = change_hours dbh tbl net info in
  let e = change_prof dbh tbl net info in
  let f = change_loc dbh tbl net info in
  match (a,b,c,d,e,f) with
  |_ -> ()

let admin_change_query dbh tbl info =
  let jsn = from_string info in
  let new_name = jsn |> Util.member "name" |> Util.to_string in
  let new_id = jsn |> Util.member "netid" |> Util.to_string in
  let new_year = jsn |> Util.member "match" |> Util.to_int in
  PGSQL(dbh) "INSERT INTO table (Netid, Name, Year) VALUES
    ($new_id, $new_name, $new_year) ON DUPLICATE KEY UPDATE
    Name = $new_name, Year = $new_year"
(
