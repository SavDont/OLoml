open Loml_client
open Unix
open Yojson.Basic
open Student

(* timePeriodDate represents a date in the following order:
 * month, day, and year
 *)
type timePeriodDate = int * int * int

(* [get_assoc_list jsn] takes a json argument and outputs the Association list
 * from it*)
let get_assoc_list jsn = match jsn with
  | `Assoc lst -> lst
  | _ -> []

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
(* [valid_student s] takes a tuple of type string*json and it outputs whether
 * the student json is valid representation of the file or not. The json must
 * not have netID, name, and yr as empt representations
 * Returns: bool*)
let valid_student s =
  try let j = snd s in
    let open Util in
    let netID = j |> member "netid" |> to_string in
    let name = j |> member "name" |> to_string in
    let yr = j |> member "year" |> to_string in
    let netIDNotEmpty = if netID <> "" then true else false in
    let nameNotEmpty = if name <> "" then true else false in
    let yrNotEmpty = if yr <> "" then true else false in
    netIDNotEmpty && nameNotEmpty && yrNotEmpty with
  | _ -> false

(* [checkDuplicates acc lst] takes a boolean accumulator [acc] and a list [lst]
 * and outputs [true] if and only if [lst] has no duplicates and [false]
 * otherwise
 * Returns: bool*)
let rec checkDuplicates acc lst = match lst with
  | h::t -> checkDuplicates (not(List.mem h t)&&acc) t
  | [] -> true


let import_students dir pwd =
  try let j =   dir |> from_file |> get_assoc_list in
    if j = [] then false
    else
      let studBool = List.map valid_student j in
      let studCheck = List.fold_right (fun acc x -> acc && x) studBool true in
      let netIDs = List.map snd j in
      let netIDDupCheck = checkDuplicates true netIDs in
      if studCheck && netIDDupCheck
      then
        let str = dir |> from_file |> to_string |> String.lowercase_ascii in
        let postResponse = Loml_client.admin_post pwd str in
        if fst postResponse = `OK
        then true
        else false
      else false with
  | _ -> false

let str_to_time str =
  let strLst = String.split_on_char ' ' str in
  if List.length strLst <> 3 then None
  else
    try let intLst = List.map int_of_string strLst in
      Some (List.hd intLst, List.hd (List.tl intLst), List.hd (List.tl (List.tl intLst))) with
    | Failure _ -> None

(* [tm_record (m, d, y)] is the record formed using the timePeriodDate tuple
 * sent into the function. This converts the timePeriodDate to a type tm from
 * the Unix library.
*)
let tm_record (m, d, y) = {
  tm_sec = 0;
  tm_min = 0;
  tm_hour = 0;
  tm_mday = d;
  tm_mon = m-1;
  tm_year = y-1900;
  tm_wday = 0;
  tm_yday = 0;
  tm_isdst = false;
}
let set_periods upDate swDate mtDate pwd =
  if valid_date upDate && valid_date swDate && valid_date mtDate
  then let uTime = upDate |> tm_record |> mktime |> fst in
    let sTime = swDate |> tm_record |> mktime |> fst in
    let mTime = mtDate |> tm_record |> mktime |> fst in
    let strJson = to_string (`Assoc[("update", `Float uTime);("swipe",`Float sTime);("match",`Float mTime)]) in
    if sTime > time () && mTime > time () && uTime < sTime && sTime < mTime then
      fst (Loml_client.period_post pwd strJson) = `OK
    else (print_endline ("\n1");false)
  else (print_endline("\n2");false)

let remove_student netID pwd =
  let strJson = "{ \"" ^ netID ^ "\": 1 }" in
  if fst (Loml_client.admin_delete pwd "subset" strJson)  = `OK
  then true
  else false

let get_student netID pwd =
  let getReq = Loml_client.admin_get pwd "student_indiv" ~netID:netID in
  if fst getReq = `OK
  then
    let jList = getReq |> snd |> from_string |> get_assoc_list in
    if jList = [] then None
    else Some (jList |> List.hd |> snd |> to_string |> parse_student)
  else None

(* [jsn_students jsnLst] takes a tuple list of type (string * json) and
 * *)
let rec jsn_students jsnLst = match jsnLst with
  | (_, j)::t -> (j |> to_string |>
                  parse_student)::(jsn_students t)
  | [] -> []

let get_all_students pwd =
  let getReq = Loml_client.admin_get pwd "student_all" ~netID:"" in
  if fst getReq = `OK
  then  let lst = getReq |> snd |> from_string |> get_assoc_list in
    jsn_students lst
  else []

let reset_class pwd =
  let emptyJson = "{}" in
  let delReq = Loml_client.admin_delete pwd "class" emptyJson in
  if fst delReq = `OK
  then true
  else false
