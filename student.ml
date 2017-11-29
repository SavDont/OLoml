open Yojson.Basic

(* Type representing student's current year in school
 * Fresh = freshman, Soph = sophomore, Jun = junior, Sen = senior*)
type classYear =
  | Fresh
  | Soph
  | Jun
  | Sen

type location =
  | North
  | West
  | Collegetown

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

(* Skills ranked on scale of 1 (never seen it) to 5 (extremely proficient)*)
type skill =
  | Java of int
  | Python of int
  | C of int
  | Ruby of int
  | Javascript of int
  | SQL of int
  | OCaml of int

type student = {
  name : string;
  netid : string;
  year : classYear;
  schedule : schedule;
  courses_taken : int list;
  skills : skill list;
  hours_to_spend : int;
  location : location;
  profile_text : string;
}

type updateData =
  | Schedule of schedule
  | Courses of int list
  | Skill of skill list
  | Hours of int
  | Location of location
  | Text of string

let valid_course c =
  let possible_courses = [1110; 1112; 1300; 2022; 2024; 2043; 2044; 2110;
                          2112; 2300; 2800; 3110; 3410; 3420; 4110; 4120;
                          4152; 4210; 4220; 4300; 4320; 4410; 4420; 4620;
                          4670; 4740; 4750; 4780; 4820; 4850] in
  List.mem c possible_courses

(* [extract_skill sk] gives the tuple (s,l) where s is the string
 * representation of the skill, and i is the integer representing
 * level of proficiency. *)
let extract_skill = function
  | Java i -> ("Java", i)
  | Python i -> ("Python", i)
  | C i -> ("C", i)
  | Ruby i -> ("Ruby", i)
  | Javascript i -> ("Javascript", i)
  | SQL i -> ("SQL",i)
  | OCaml i -> ("OCaml",i)

(* [parse_skill_str str] gives the skill variant representation of
 * str, essentially undoing [extract_skill] *)
let parse_skill_str str =
  let splt = String.split_on_char '_' str in
  let hd = List.hd splt in
  let tl_int = List.nth splt 1 |> int_of_string in
  if hd = "Java" then Java tl_int
  else if hd = "Python" then Python tl_int
  else if hd = "C" then C tl_int
  else if hd = "Ruby" then Ruby tl_int
  else if hd = "Javascript" then Javascript tl_int
  else if hd = "SQL" then SQL tl_int
  else OCaml tl_int

(* [year_to_str y] gives the string representation of the year variant, y. *)
let year_to_str = function
  | Fresh -> "Freshman"
  | Soph -> "Sophomore"
  | Jun -> "Junior"
  | Sen -> "Senior"

(* [parse_yr] gives the variant representation of the year string, yr.
 * Requires: yr must be "Freshman", "Sophomore", "Junior", or "Senior".*)
let parse_yr yr =
  if yr = "Freshman" then Fresh
  else if yr = "Sophomore" then Soph
  else if yr = "Junior" then Jun
  else Sen

(* [loc_to_str] gives the string representation of the location variant. *)
let loc_to_str = function
  | North -> "North Campus"
  | West -> "West Campus"
  | Collegetown -> "Collegetown"

(* [parse_loc loc] gives the variant representation of the location string.
 * Requires: loc must be "North Campus", "West Campus", or "Collegetown"*)
let parse_loc loc =
  if loc = "North Campus" then North
  else if loc = "West Campus" then West
  else Collegetown

(* [sched_to_str sched acc pos] gives the string representation of
 * a boolean list which represents a schedule.
 * Requires: sched is a valid schedule list.  That is, it is of length
 * exactly 21. *)
let rec sched_to_str sched acc pos =
  if List.length sched <> 21 then failwith "Incorrect Schedule Length"
  else
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
    then sched_to_str t (acc^(day_of_week pos)^(time_of_day pos)^"\n\n") (pos+1)
    else sched_to_str t acc (pos+1)

(* [ext_str jsn_str] removes double quotations from the inputted string.
 * Requires: the double quotations must contain the entirety of the string
 * within [jsn_str], and they must exist. *)
let ext_str jsn_str =
  let str = to_string jsn_str in
  String.sub str 1 (String.length str - 2)

let parse_student st_str =
  let jsn = from_string st_str in
  let courses = jsn |> Util.member "courses_taken" |> Util.to_list in
  let skills = jsn |> Util.member "skills" |> Util.to_list in
  let sched = jsn |> Util.member "schedule" |> Util.to_list in
  {
    name = jsn |> Util.member "name" |> ext_str;
    netid = jsn |> Util.member "netid" |> ext_str;
    year = jsn |> Util.member "year" |> ext_str |> parse_yr;
    schedule = sched |> List.map Util.to_bool;
    courses_taken = courses |> List.map Util.to_int;
    skills = skills |> List.map ext_str |> List.map parse_skill_str;
    hours_to_spend = jsn |> Util.member "hours_to_spend" |> Util.to_int;
    profile_text = jsn |> Util.member "profile_text" |> ext_str;
    location = jsn |> Util.member "location" |> ext_str |> parse_loc
  }

(* [printable_lst lst] gives the string representation of lst.
 * each element is separated by a comma. *)
let rec printable_lst = function
  | [] -> ""
  | h::m::t -> h^","^(printable_lst (m::t))
  | h::t -> h

(* [lvl_to_str i] gives the string representation of an integer skill level.
 * Requires: 1 <= i <= 5 *)
let lvl_to_str i =
  if i = 1 then "no exposure"
  else if i = 2 then "some exposure"
  else if i = 3 then "moderate skill"
  else if i = 4 then "strong skill"
  else "excellent skill"

(* [skill_to_str sk] gives the string representation of sk, in the format,
 * "skill name: skill level (string representation)"
 * Requires: the integer component of sk must be between 1 and 5 (inclusive)*)
let skill_to_str sk =
  let tup = extract_skill sk in
  (fst tup)^": "^(lvl_to_str (snd tup))

(* [skill_lst_to_str sk_lst] gives the string representation of skills within
 * sk_lst.*)
let skill_lst_to_str sk_lst =
  let sk_lst = List.map skill_to_str sk_lst in
  List.fold_right (fun acc i -> i^acc) sk_lst ""

let printable_student st =
  let header = "Viewing profile for: "^st.name^" ("^st.netid^")" in
  let yr = "Year: "^(year_to_str st.year) in
  let loc = "Lives closest to: "^(loc_to_str st.location) in
  let course_lst = List.map string_of_int st.courses_taken in
  let course_lst_cs = List.map (fun s -> "CS "^s) course_lst in
  let courses = "Has taken: "^(printable_lst course_lst_cs) in
  let skills = "Skills:\n"^(skill_lst_to_str st.skills) in
  let hrs = "Willing to spend "^(string_of_int st.hours_to_spend)^" hours on this project" in
  let sched = "Available:\n"^(sched_to_str st.schedule "" 0) in
  let about = "About me: "^st.profile_text in
  header^"\n\n"^yr^"\n\n"^loc^"\n\n"^courses^"\n\n"^skills^"\n"^sched^hrs^"\n\n"^about

let get_student net pwd =
  match Client.student_get net pwd "student" with
  | (`No_response,str) -> None
  | (`OK,str) -> Some (parse_student str)
  | _ -> failwith "impossible"

(* [skill_to_string sk] gives the yojson `String representation of sk *)
let skill_to_string sk =
  let tup = extract_skill sk in
  `String ((fst tup)^"_"^(string_of_int (snd tup)))

(* [skill_lst_to_json lst] gives the yojson List format to lst, such that
 * it can be included in a yojson association list. *)
let skill_lst_to_json lst =
  `List (List.map skill_to_string lst)

(* [course_lst_to_json lst] gives the yojson List format to lst, such that
 * it can be included in a yojson association list. *)
let course_lst_to_json c_lst =
  `List ((List.map (fun i -> `Int i)) c_lst)

(* [sched_lst_to_json lst] gives the yojson List format to lst, such that
 * it can be included in a yojson association list. *)
let sched_lst_to_json s_lst =
  `List ((List.map (fun b -> `Bool b)) s_lst)

(* [field_to_json fld] gives the yojson association tuple corresponding
 * to the update field. *)
let field_to_json = function
  | Schedule s -> ("schedule",sched_lst_to_json s)
  | Courses c -> ("courses_taken",course_lst_to_json c)
  | Skill sk -> ("skills",skill_lst_to_json sk)
  | Hours h -> ("hours_to_spend",`Int h)
  | Location l -> ("location",`String (loc_to_str l))
  | Text t ->  ("profile_text",`String t)

let update_profile net pwd fields =
  let fields_mapped = List.map field_to_json fields in
  match Client.student_post net pwd (`Assoc(fields_mapped)) with
  | (`No_response,str) -> false
  | (`OK,str) -> true
  | _ -> failwith "impossible"

let get_match net pwd =
  match Client.student_get net pwd "match" with
  | (`No_response,str) -> None
  | (`OK,str) -> Some (parse_student str)
  | _ -> failwith "impossible"

(* [student_to_json st] gives the yojson form of a student. *)
let student_to_json st =
  let name = ("name", `String st.name) in
  let netid = ("netid", `String st.netid) in
  let year = ("year", `String (year_to_str st.year)) in
  let sched = ("schedule", sched_lst_to_json st.schedule) in
  let courses = ("courses_taken", (course_lst_to_json st.courses_taken)) in
  let skills = ("skills", (skill_lst_to_json st.skills)) in
  let hrs = ("hours_to_spend", `Int st.hours_to_spend) in
  let prof = ("profile_text", `String st.profile_text) in
  let loc = ("location", `String (loc_to_str st.location)) in
  `Assoc[name;netid;year;sched;courses;skills;hrs;prof;loc]

(* Requires: s1 and s2 must have valid schedules of the same length
 * (21 entries) *)
let sched_score {schedule = s1} {schedule = s2} =
  let rec counter st1 st2 acc =
  match s1, s2 with
  |[],[] -> acc
  |h1::t1, h2::t2 ->
    if h1 = h2 then counter t1 t2 (acc+.1.0)
    else counter t1 t2 acc
  |_ -> failwith "schedules must be same length" in
  (counter s1 s2 0.0) /. 21.0

(* Function of how many classes in common + difference in highest
 * course level taken *)
let course_score {courses_taken = c1} {courses_taken = c2} =
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
  pre_score /. 10.0 (* considering this a "perfect" score *)


(* Function of deviation in hours willing to spend *)
let hour_score {hours_to_spend = h1} {hours_to_spend = h2} =
  let hour_dev = abs (h1-h2) in
  if hour_dev < 5 then 1.0
  else if hour_dev < 10 then 0.75
  else if hour_dev < 20 then 0.5
  else if hour_dev < 30 then 0.25
  else 0.0

(* Function of how many skills you share, how skill level compares in skills
 * you share, and to smaller extent, how similar number of skills are*)
let skill_score {skills = s1} {skills = s2} =
  failwith "Unimplemented"

let loc_score {location = l1} {location = l2} =
  if l1 = l2 then 1.0 else 0.0
