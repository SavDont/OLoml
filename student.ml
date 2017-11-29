open Yojson.Basic

type netid = string

(* Length 21 bool list *)
type schedule = bool list

type classYear =
  | Fresh
  | Soph
  | Jun
  | Sen

type location =
  | North
  | West
  | Collegetown

(* possible CS courses a student can have taken
 * Only went up to 4000 level--do we want to include more? *)
type course = int

let possible_courses = [1110; 1112; 1300; 2022; 2024; 2043; 2044; 2110;
                        2112; 2300; 2800; 3110; 3410; 3420; 4110; 4120;
                        4152; 4210; 4220; 4300; 4320; 4410; 4420; 4620;
                        4670; 4740; 4750; 4780; 4820; 4850]

(* int from 1 to 5 dictates proficiency
 * add more skills? *)
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
  netid : netid;
  year : classYear;
  schedule : schedule;
  courses_taken : course list;
  skills : skill list;
  hours_to_spend : int;
  location : location;
  profile_text : string;
}

(* Only mutable fields for students (different ones for profs??) *)
type updateData =
  | Schedule of schedule
  | Courses of course list
  | Skill of skill list
  | Hours of int
  | Location of location
  | Text of string

(* variant saying what part of student you want to update
 * for partial writes *)

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

let year_to_str = function
  | Fresh -> "Freshman"
  | Soph -> "Sophomore"
  | Jun -> "Junior"
  | Sen -> "Senior"

let parse_yr yr =
  if yr = "Freshman" then Fresh
  else if yr = "Sophomore" then Soph
  else if yr = "Junior" then Jun
  else Sen

let loc_to_str = function
  | North -> "North Campus"
  | West -> "West Campus"
  | Collegetown -> "Collegetown"

let parse_loc loc =
  if loc = "North Campus" then North
  else if loc = "West Campus" then West
  else Collegetown

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

(* Removes double quotes *)
let ext_str jsn_str =
  let str = to_string jsn_str in
  String.sub str 1 (String.length str - 2)

(* takes DB string representation, makes student type *)
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

let rec printable_lst = function
  | [] -> ""
  | h::m::t -> h^","^(printable_lst (m::t))
  | h::t -> h

let lvl_to_str i =
  if i = 1 then "no exposure"
  else if i = 2 then "some exposure"
  else if i = 3 then "moderate skill"
  else if i = 4 then "strong skill"
  else "excellent skill"

let skill_to_str = function
  | Java i -> "Java: "^(lvl_to_str i)^"\n"
  | Python i -> "Python: "^(lvl_to_str i)^"\n"
  | C i -> "C: "^(lvl_to_str i)^"\n"
  | Ruby i -> "Ruby: "^(lvl_to_str i)^"\n"
  | Javascript i -> "Javascript: "^(lvl_to_str i)^"\n"
  | SQL i -> "SQL: "^(lvl_to_str i)^"\n"
  | OCaml i -> "OCaml: "^(lvl_to_str i)^"\n"

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

let skill_lst_to_json lst =
  `List (List.map skill_to_string lst)

let course_lst_to_json c_lst =
  `List ((List.map (fun i -> `Int i)) c_lst)

let sched_lst_to_json s_lst =
  `List ((List.map (fun b -> `Bool b)) s_lst)

let field_to_json = function
  | Schedule s -> ("schedule",sched_lst_to_json s)
  | Courses c -> ("courses_taken",course_lst_to_json c)
  | Skill sk -> ("skills",skill_lst_to_json sk)
  | Hours h -> ("hours_to_spend",`Int h)
  | Location l -> ("location",`String (loc_to_str l))
  | Text t ->  ("profile_text",`String t)

let update_profile net pwd fields =
  let fields_mapped = List.map field_to_json fields in
  match Client.student_post net pwd fields_mapped with
  | (`No_response,str) -> false
  | (`OK,str) -> true

let get_match net pwd =
  match Client.student_get net pwd "match" with
  | (`No_response,str) -> None
  | (`Ok,str) -> Some (parse_student str)

let skill_to_string = function
  | Java i -> `String ("Java_"^(string_of_int i))
  | Python i -> `String ("Python_"^(string_of_int i))
  | C i -> `String ("C_"^(string_of_int i))
  | Ruby i -> `String ("Ruby_"^(string_of_int i))
  | Javascript i -> `String ("Javascript_"^(string_of_int i))
  | SQL i -> `String ("SQL_"^(string_of_int i))
  | OCaml i -> `String ("OCaml_"^(string_of_int i))

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
