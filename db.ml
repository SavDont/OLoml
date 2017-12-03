open Yojson.Basic
open Mysql
module P = Mysql.Prepared
open Printf

let db = quick_connect ~host:("localhost") ~port:(3306) ~database:("test") ~user:("root") ~password:("admin123") ()

(*Table names
let stu_tbl = "students"
let match_tbl = "matches"
let creds_tbl = "credentials"
let periods_tbl = "periods"
*)

let check_cred_query netid pwd =
  let select = P.create db ("SELECT password FROM credentials WHERE netid = ?") in
  let t1 = P.execute_null select [|Some netid|] in
    match P.fetch t1 with
    | Some arr ->
      begin match Array.get arr 0 with
        |Some n -> n = pwd
        |None -> false
      end
    | None -> false

let check_period_set =
  let select = P.create db ("SELECT * FROM periods") in
  let t1 = P.execute_null select [||] in
  match (P.fetch t1) with
  | Some arr ->
    if Array.mem None arr then false else true
  | None -> false
  (*
  if ((PGSQL(dbh) "SELECT Update FROM $periods_tbl") != None
      ||  (PGSQL(dbh) "SELECT Swipe FROM $periods_tbl") != None
      ||  (PGSQL(dbh) "SELECT Match FROM $periods_tbl") != None) then true
  else false
*)

let set_period_query periods =
  let jsn = from_string periods in
  let update_dt = jsn |> Util.member "update" |> Util.to_float_option in
  let swipe_dt = jsn |> Util.member "swipe" |> Util.to_float_option in
  let match_dt = jsn |> Util.member "match" |> Util.to_float_option in
  match (update_dt, swipe_dt, match_dt) with
  |(Some u , Some s , Some m) ->
    if check_period_set = false then
      let insert = P.create db ( "INSERT INTO periods VALUES (?,?,?)") in
        ignore (P.execute insert [|ml2float u;ml2float s;ml2float m|])
    else ()
  |_ -> ()

  (*
      PGSQL(dbh) "INSERT INTO $periods_tbl (Update, Swipe, Match)
      VALUES ($update_dt, $swipe_dt, $match_dt)" *)

let get_period_query =
  let select = P.create db ("SELECT * FROM periods") in
  let t1 = P.execute_null select [||] in
    match P.fetch t1 with
    | Some arr ->
      begin match (Array.get arr 0, Array.get arr 1, Array.get arr 2) with
        |(Some u, Some s, Some m) ->
          let upd = ("update", `String u) in
          let mat = ("match", `String m) in
          let swi = ("swipe", `String s) in
          let jsonobj = `Assoc[upd;swi;mat] in Yojson.Basic.to_string jsonobj
        |_ ->
          let upd = ("update", `Null) in
          let mat = ("match", `Null) in
          let swi = ("swipe", `Null) in
          let jsonobj = `Assoc[upd;swi;mat] in Yojson.Basic.to_string jsonobj
      end
    | None ->
      let upd = ("update", `Null) in
      let mat = ("match", `Null) in
      let swi = ("swipe", `Null) in
      let jsonobj = `Assoc[upd;swi;mat] in Yojson.Basic.to_string jsonobj

let get_student_query netid =
  let select = P.create db ("SELECT * FROM students WHERE netid = ?") in
  let t1 = P.execute_null select [|Some netid|] in
    match P.fetch t1 with
    | Some arr ->
      begin match (Array.get arr 0, Array.get arr 1, Array.get arr 2,
                   Array.get arr 3, Array.get arr 4, Array.get arr 5,
                   Array.get arr 6,Array.get arr 7) with
      |(Some jnetid,Some jname,Some jyr,Some jsched,Some jcourses,
        Some jhrs,Some jprof,Some jloc) ->
          let name = ("name", `String jname) in
          let netid = ("netid", `String jnetid) in
          let year = ("year", `String jyr) in
          let sched = ("schedule", `String jsched) in
          let courses = ("courses_taken", `String jcourses) in
          let hrs = ("hours_to_spend", `String jhrs) in
          let prof = ("profile_text", `String jprof) in
          let loc = ("location", `String jloc) in
          let jsonobj = `Assoc[name;netid;year;sched;courses;hrs;prof;loc] in
          Yojson.Basic.to_string jsonobj
        |_ ->
          let name = ("name", `Null) in
          let netid = ("netid", `Null) in
          let year = ("year", `Null) in
          let sched = ("schedule", `Null) in
          let courses = ("courses_taken", `Null) in
          let hrs = ("hours_to_spend", `Null) in
          let prof = ("profile_text", `Null) in
          let loc = ("location", `Null) in
          let jsonobj = `Assoc[name;netid;year;sched;courses;hrs;prof;loc] in
          Yojson.Basic.to_string jsonobj
      end
  | None ->
    let name = ("name", `Null) in
    let netid = ("netid", `Null) in
    let year = ("year", `Null) in
    let sched = ("schedule", `Null) in
    let courses = ("courses_taken", `Null) in
    let hrs = ("hours_to_spend", `Null) in
    let prof = ("profile_text", `Null) in
    let loc = ("location", `Null) in
    let jsonobj = `Assoc[name;netid;year;sched;courses;hrs;prof;loc] in
    Yojson.Basic.to_string jsonobj

let get_stu_match_query netid =
  let select = P.create db ("SELECT stu2 FROM matches WHERE netid = ?") in
  let t1 = P.execute_null select [|Some netid|] in
    match P.fetch t1 with
    | Some arr ->
      begin match Array.get arr 0 with
        |Some n ->
          if n = "UNMATCHED" then
            let name = ("name", `Null) in
            let netid = ("netid", `String "UNMATCHED") in
            let year = ("year", `Null) in
            let sched = ("schedule", `Null) in
            let courses = ("courses_taken", `Null) in
            let hrs = ("hours_to_spend", `Null) in
            let prof = ("profile_text", `Null) in
            let loc = ("location", `Null) in
            let jsonobj = `Assoc[name;netid;year;sched;courses;hrs;prof;loc] in
            Yojson.Basic.to_string jsonobj
          else get_student_query n
        |None ->
          let name = ("name", `Null) in
          let netid = ("netid", `Null) in
          let year = ("year", `Null) in
          let sched = ("schedule", `Null) in
          let courses = ("courses_taken", `Null) in
          let hrs = ("hours_to_spend", `Null) in
          let prof = ("profile_text", `Null) in
          let loc = ("location", `Null) in
          let jsonobj = `Assoc[name;netid;year;sched;courses;hrs;prof;loc] in
          Yojson.Basic.to_string jsonobj
      end
    | None ->
      let name = ("name", `Null) in
      let netid = ("netid", `Null) in
      let year = ("year", `Null) in
      let sched = ("schedule", `Null) in
      let courses = ("courses_taken", `Null) in
      let hrs = ("hours_to_spend", `Null) in
      let prof = ("profile_text", `Null) in
      let loc = ("location", `Null) in
      let jsonobj = `Assoc[name;netid;year;sched;courses;hrs;prof;loc] in
      Yojson.Basic.to_string jsonobj

let ext_str jsn_str =
  match Util.to_string_option jsn_str with
  | None -> ""
  | Some s -> s

let ext_int jsn_int =
  match Util.to_int_option jsn_int with
  | None -> -1
  | Some s -> s

let ext_lst jsn_lst =
  match Util.to_string_option jsn_lst with
  | None -> "[]"
  | Some s -> s

let rec get_pair ones twos j=
  match ones with
  |h::t -> (get_pair t ((j |> Util.member h |>ext_str):: twos) j)
  |[] -> twos

let rec post_match_helper un firsts seconds =
  match firsts with
  |h1::t1 ->
    begin match seconds with
    |h2::t2 ->
      let insert = P.create db ("INSERT INTO matches (stu1, stu2) VALUES
      (?, ?)") in
      let res = begin match ignore (P.execute insert [|h1;h2|]) with
        |_-> ()
      end in
      post_match_helper res t1 t2
    |[] -> ()
    end
  |[] -> ()


let post_matches_query matches =
  let jsn = from_string matches in
  let firsts = jsn |> Util.keys in (*string list of netids for first students*)
  let seconds = get_pair firsts [] jsn in
  post_match_helper () firsts seconds


(*helper functions that change each specific field if the field exists in the
 * json *)
let change_sched net info =
  let jsn = from_string info in
  match jsn |> Util.member "schedule" |> Util.to_string_option with
  |Some i ->
      let insert = P.create db ("UPDATE students SET schedule = ?
                  WHERE Netid = ?") in
      ignore (P.execute insert [|info; net|])
  |_ -> ()

let change_courses net info =
  let jsn = from_string info in
  match jsn |> Util.member "classes_taken" |> Util.to_string_option with
  |Some i ->
    let insert = P.create db ("UPDATE students SET courses=?
                WHERE Netid = ?") in
    ignore (P.execute insert [|info; net|])
  |_ -> ()


let change_hours net info =
  let jsn = from_string info in
  match jsn |> Util.member "classes_taken" |> Util.to_int_option with
  |Some i ->
    let insert = P.create db ("UPDATE students SET hours=?
                  WHERE Netid = ?") in
    ignore (P.execute insert [|info; net|])
  |_ -> ()

let change_prof net info =
  let jsn = from_string info in
  match jsn |> Util.member "profile_text" |> Util.to_string_option with
  |Some i ->
    let insert = P.create db ("UPDATE students SET profile=?
                    WHERE Netid = ?") in
    ignore (P.execute insert [|info; net|])
  |_ -> ()

let change_loc net info =
  let jsn = from_string info in
  match jsn |> Util.member "location" |> Util.to_string_option with
  |Some i ->
    let insert = P.create db ("UPDATE students SET location=?
                      WHERE Netid = ?") in
    ignore (P.execute insert [|info; net|])
  |_ -> ()

let change_stu_query net info =
  let a = change_sched net info in
  let b = change_courses net info in
  let c = change_hours net info in
  let d = change_prof net info in
  let e = change_loc net info in
  match [a;b;c;d;e] with
  |_ -> ()

let admin_change_query info =
  let jsn = from_string info in
  let new_name = jsn |> Util.member "name" |> Util.to_string_option in
  let new_id = jsn |> Util.member "netid" |> Util.to_string_option in
  let new_year = jsn |> Util.member "year" |> Util.to_string_option in
  match (new_name, new_id, new_year) with
  |(Some name, Some id, Some yr) ->
    let insert = P.create db ("INSERT INTO students (netid, name, year) VALUES
      (?, ?, ?) ON DUPLICATE KEY UPDATE Name = ?, Year = ?") in
    ignore (P.execute insert [|id; name; yr; name; yr|])
  |_ -> ()

let reset_students =
  let reset = P.create db ("TRUNCATE students") in
  match P.execute_null reset [||] with |_ -> ()

let reset_swipes =
  let reset = P.create db ("TRUNCATE swipes") in
  match P.execute_null reset [||] with |_ -> ()

let reset_matches =
  let reset = P.create db ("TRUNCATE matches") in
  match P.execute_null reset [||] with |_ -> ()

let reset_credentials =
  let reset = P.create db ("TRUNCATE credentials") in
  match P.execute_null reset [||] with |_ -> ()

let reset_periods =
  let reset = P.create db ("TRUNCATE periods") in
  match P.execute_null reset [||] with |_ -> ()


let rec delete_students_helper un nets =
  match nets with
  |h1::t1 ->
      let insert = P.create db ("DELETE FROM students WHERE netid = ?") in
        let res = begin match ignore (P.execute insert [|h1|]) with
          |_-> ()
        end in
        delete_students_helper res t1
  |[] -> ()

let delete_students students =
  let jsn = from_string students in
  let netids = jsn |> Util.keys in (*string list of netids for first students*)
  delete_students_helper () netids

let reset_class =
  reset_students; reset_swipes; reset_matches; reset_credentials; reset_periods;
