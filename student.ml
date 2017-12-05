open Yojson.Basic

(* Type representing student's current year in school
 * Fresh = freshman, Soph = sophomore, Jun = junior, Sen = senior*)
type classYear =
  | Fresh
  | Soph
  | Jun
  | Sen
  | Empty

type location =
  | North
  | West
  | Collegetown
  | Empty

(* Type representing a student's available time slots throughout a single week.
 * Each schedule must be of length exactly 21.  It is parsed as follows:
 * - every three elements represent a single day.  For example,
 *   elements 0-2 represent monday, 3-5 represent tuesday...18-20 represent
 *   sunday
 * - within each day, the first element represents morning, the second
 *   afternoon, and the third evening. i.e. 0 is monday morning, 2 is monday
 *   evening
 * - true means that a student is available during this time slot, and
 *   false means they are not. *)
type schedule = bool list

type student = {
  name : string;
  netid : string;
  year : classYear;
  schedule : schedule;
  courses_taken : int list;
  hours_to_spend : int;
  location : location;
  profile_text : string;
}

type updateData =
  | Schedule of schedule
  | Courses of int list
  | Hours of int
  | Location of location
  | Text of string

let valid_course c =
  let possible_courses = [1110; 1112; 1300; 2022; 2024; 2043; 2044; 2110;
                          2112; 2300; 2800; 3110; 3410; 3420; 4110; 4120;
                          4152; 4210; 4220; 4300; 4320; 4410; 4420; 4620;
                          4670; 4740; 4750; 4780; 4820; 4850] in
  List.mem c possible_courses


(* [year_to_str y] gives the string representation of the year variant, y. *)
let year_to_str = function
  | Fresh -> "freshman"
  | Soph -> "sophomore"
  | Jun -> "junior"
  | Sen -> "senior"
  | Empty -> ""

(* [parse_yr] gives the variant representation of the year string, yr.
 * Requires: yr must be "Freshman", "Sophomore", "Junior", or "Senior".*)
let parse_yr yr =
  if yr = "freshman" then Fresh
  else if yr = "sophomore" then Soph
  else if yr = "junior" then Jun
  else if yr = "senior" then Sen
  else Empty

(* [loc_to_str] gives the string representation of the location variant. *)
let loc_to_str = function
  | North -> "north campus"
  | West -> "west campus"
  | Collegetown -> "collegetown"
  | Empty -> ""

(* [parse_loc loc] gives the variant representation of the location string.
 * Requires: loc must be "North Campus", "West Campus", or "Collegetown"*)
let parse_loc loc =
  if loc = "north campus" then North
  else if loc = "west campus" then West
  else if loc = "collegetown" then Collegetown
  else Empty

(* [printable_lst lst] gives the string representation of lst.
 * each element is separated by a comma. *)
let rec printable_lst = function
  | [] -> ""
  | h::m::t -> h^", "^(printable_lst (m::t))
  | h::t -> h

(* [sched_to_str sched acc pos] gives the string representation of
 * a boolean list which represents a schedule.
 * Requires: sched is a valid schedule list.  That is, it is of length
 * exactly 21. *)
let rec sched_to_str sched acc pos =
  let time_of_day p =
    if p mod 3 = 0 then "mornings"
    else if p mod 3 = 1 then "afternoons"
    else "evenings" in
  let day_of_week d =
    if d < 3 then "monday "
    else if d < 6 then "tuesday "
    else if d < 9 then "wednesday "
    else if d < 12 then "thursday "
    else if d < 15 then "friday "
    else if d < 18 then "saturday "
    else "sunday " in
  match sched with
  | [] -> acc
  | h::t ->
    if h
    then sched_to_str t (acc^(day_of_week pos)^(time_of_day pos)^"\n") (pos+1)
    else sched_to_str t acc (pos+1)

(* [ext_str jsn_str] removes double quotations from the inputted string.
 * Requires: the double quotations must contain the entirety of the string
 * within [jsn_str], and they must exist. *)
let ext_str jsn_str =
  match Util.to_string_option jsn_str with
  | None -> ""
  | Some s -> s

let rem_double_quote s = String.sub s 1 (String.length s - 2)

let ext_int jsn_int =
  match Util.to_int_option jsn_int with
  | None -> -1
  | Some s -> s

let ext_lst jsn_lst =
  match Util.to_string_option jsn_lst with
  | None -> "[]"
  | Some s -> s

let parse_student st_str =
  let jsn = from_string st_str in
  let courses = jsn |> Util.member "courses_taken" |> ext_lst |> from_string in
  let sched = jsn |> Util.member "schedule" |> ext_lst |> from_string in
  {
    name = jsn |> Util.member "name" |> ext_str;
    netid = jsn |> Util.member "netid" |> ext_str;
    year = jsn |> Util.member "year" |> ext_str |> parse_yr;
    schedule = sched |> Util.to_list |> List.map Util.to_bool;
    courses_taken = courses |> Util.to_list |> List.map Util.to_int;
    hours_to_spend = jsn |> Util.member "hours_to_spend" |> ext_int;
    profile_text = jsn |> Util.member "profile_text" |> ext_str;
    location = jsn |> Util.member "location" |> ext_str |> parse_loc
  }

let printable_student st =
  let header = "Viewing profile for: "^st.name^" ("^st.netid^")" in
  let yr = "Year: "^(year_to_str st.year) in
  let loc = "Lives closest to: "^(loc_to_str st.location) in
  let course_lst = List.map string_of_int st.courses_taken in
  let course_lst_cs = List.map (fun s -> "CS "^s) course_lst in
  let courses = "Has taken: "^(printable_lst course_lst_cs) in
  let hrs =
    (* empty hours = -1 *)
    if st.hours_to_spend = -1 then "unknown"
    else string_of_int st.hours_to_spend in
  let hrs_str = "Willing to spend "^(hrs)^" hours on this project" in
  let sched = "Available:\n"^(sched_to_str st.schedule "" 0) in
  let about = "About me: "^st.profile_text in
  header^"\n\n"^yr^"\n\n"^loc^"\n\n"^courses^"\n\n"^sched^"\n"^hrs_str^"\n\n"^about

let get_student net pwd =
  match Loml_client.student_get net pwd "student" with
  | (`OK,str) -> Some (parse_student str)
  | _ -> None

let field_to_json = function
  | Schedule s -> ("schedule", `String (s |> List.map string_of_bool |> printable_lst))
  | Courses c -> ("courses_taken",`String (c |> List.map string_of_int |> printable_lst))
  | Hours h -> ("hours_to_spend",`Int h)
  | Location l -> ("location",`String (loc_to_str l))
  | Text t ->  ("profile_text",`String t)

let update_profile net pwd fields =
  let fields_mapped =
    `Assoc(List.map field_to_json fields) |> Yojson.Basic.to_string in
  match Loml_client.student_post net pwd fields_mapped with
  | (`OK,str) -> true
  | _ -> false

let get_match net pwd =
  match Loml_client.student_get net pwd "match" with
  | (`OK,str) -> Some (parse_student str)
  | _ -> None

let to_jsn_str lst map_func =
  `List (List.map map_func lst) |> to_string

(* [student_to_json st] gives the yojson form of a student. *)
let student_to_json st =
  let name = ("name", `String st.name) in
  let netid = ("netid", `String st.netid) in
  let year = ("year", `String (year_to_str st.year)) in
  let sched = ("schedule", `String (to_jsn_str st.schedule (fun x -> `Bool x)))in
  let courses = ("courses_taken", `String (to_jsn_str st.courses_taken (fun x -> `Int x))) in
  let hrs = ("hours_to_spend", `Int st.hours_to_spend) in
  let prof = ("profile_text", `String st.profile_text) in
  let loc = ("location", `String (loc_to_str st.location)) in
  `Assoc[name;netid;year;sched;courses;hrs;prof;loc]

(* For all compatibility functions below, if either student has
 * incomplete information for a given field, that field gives a
 * compatibility score of 0.0. *)

(* Requires: s1 and s2 must have valid schedules of the same length
 * (21 entries) *)
let sched_score {schedule = s1} {schedule = s2} =
  if List.length s1 = 0 || List.length s2 = 0 then 0.0
  else
    let rec counter st1 st2 acc =
    match st1, st2 with
    |[],[] -> acc
    |h1::t1, h2::t2 ->
      if h1 = h2 then counter t1 t2 (acc+.1.0)
      else counter t1 t2 acc
    |_ -> failwith "schedules must be same length" in
    (counter s1 s2 0.0) /. 21.0

(* Function of how many classes in common + difference in highest
 * course level taken *)
let course_score {courses_taken = c1} {courses_taken = c2} =
  if c1 = [] || c2 = [] then 0.0
  else
    let rec common_course_count st1 st2 acc =
      match st1 with
      | [] -> acc
      | h::t ->
        if List.mem h st2 then common_course_count t st2 (acc+.1.0)
        else common_course_count t st2 acc in
    let highest_course lst =
      (List.fold_left(fun acc elt-> if elt > acc then elt else acc) 0 lst)/1000 in
    let course_dev = abs((highest_course c1)-(highest_course c2))|>float_of_int in
    (* don't want negative scores *)
    let pre_score = max 0.0 (common_course_count c1 c2 0.0) -. course_dev in
    let avg_num_courses = (float_of_int(List.length c1 + List.length c2))/.2.0 in
    pre_score /. avg_num_courses

(* Function of deviation in hours willing to spend *)
let hour_score {hours_to_spend = h1} {hours_to_spend = h2} =
  if h1 = -1 || h2 = -1 then 0.0
  else
    let hour_dev = abs (h1-h2) in
    if hour_dev < 5 then 1.0
    else if hour_dev < 10 then 0.75
    else if hour_dev < 20 then 0.5
    else if hour_dev < 30 then 0.25
    else 0.0

let loc_score {location = l1} {location = l2} =
  if l1 = l2 && (not (l1 = Empty || l2 = Empty)) then 1.0 else 0.0
