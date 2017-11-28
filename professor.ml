open Client
open Unix

(* timePeriodDate represents a date in the following order:
 * month, day, and year
 *)
type timePeriodDate = int * int * int

(* [valid_date y m d] Takes a tuple with integer [y],integer [m], and
 * integer [d] as inputs
 * Postcondition: Returns a boolean indicating whether the date is valid by
 * checking that
 * 1) [y] is strictly positive
 * 2) [m] is a integer from 1 to 12 inclusive
 * 3) [d] is an integer between 1 and the number of days in that month taking
 * leap years into account
 *)
let valid_date (m, d, y) =
  if y >= 1 && List.mem m [1;3;5;7;8;10;12] then d<= 31 && d>=1
                else if List.mem m [4;5;9;11] then d<=30 && d>=1
                else if m=2 && (mod) y 400 = 0 then d<=29 && d>=1
                else if m=2 && (mod) y 100 = 0 then d<=28 && d>=1
                else if m=2 && (mod) y 4 = 0 then d<=29 && d>=1
                else d<=28 && d>=1

let import_students dir pwd =
  match dir |> Yojson.Basic.from_file with
  | Sys_error s -> false
  | j -> let postResponse = Client.admin_post pwd j in
    if fst postResponse = `Ok
    then true
    else false

(* [tm_record (m, d, y)] is the record formed using the timePeriodDate tuple
 * sent into the function. This converts the timePeriodDate to a type tm from
 * the Unix library.
*)
let tm_record (m, d, y) = {
  tm_sec : 0;
  tm_min : 0;
  tm_hour : 0;
  tm_mday : d;
  tm_mon : m-1;
  tm_year : y-1900;
  tm_wday : 0;
  tm_yday : 0;
  tm_isdst : false;
}
let set_periods upDate swDate mtDate pwd =
  if valid_date upDate && valid_date swDate && valid_date mtDate
  then let uRecord = tm_record upDate in
    let sRecord = tm_record swDate in
    let mRecord = tm_record mtDate in
    let strJson = "{
                    \"update\" : " ^ uRecord |> mktime |> fst |> string_of_float ^ ",
                    \"swipe\" : " ^ sRecord |> mktime |> fst |> string_of_float ^ ",
                    \"match\" : " ^ mRecord |> mktime |> fst |> string_of_float ^
                                                                "}" in
    let yoJsonF = Yojson.Basic.from_string strJson in
    if Client.period_post pwd yoJsonF = `Ok
    then true
    else false
  else false

let remove_student netID pwd =
  let strJson = "{ \"" ^ netID ^ "\": 1 }" in
  let yoJsonF = Yojson.Basic.from_string strJson in
  if Client.admin_delete pwd "subset" yoJsonF  = `Ok
  then true
  else false

let add_student metaData pwd =
  failwith "Unimplemented"

let get_student netID pwd =
  failwith "Unimplemented"

let get_all_students () =
  failwith "Unimplemented"

let reset_class () =
  failwith "Unimplemented"
