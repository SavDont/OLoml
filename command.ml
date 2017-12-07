type swipeDirection = Left | Right
type confirm = Yes | No
type loc =
  | SwipePage
  | MatchPage
  | MainPage
  | ProfilePage

type wkday =
  | Monday of int
  | Tuesday of int
  | Wednesday of int
  | Thursday of int
  | Friday of int
  | Saturday of int
  | Sunday of int

type command =
  | Swipe of swipeDirection
  | Quit
  | Confirm of confirm
  | Save
  | Goto of loc
  | Update
  | Field of int
  | Reset
  | Matchify
  | Period
  | Day of wkday
  | Unknown of string

(* [parse_time str] gives the integer representation of a time of day,
 * or -1 if str is not a valid time of day. *)
let parse_time str =
  if str = "morning" then 0
  else if str = "afternoon" then 1
  else if str = "evening" then 2
  else -1

let parse_command txt =
  let txt_lower = String.lowercase_ascii txt |> String.trim in
  if txt_lower = "l" then Swipe Left
  else if txt_lower = "r" then Swipe Right
  else if txt_lower = "quit" then Quit
  else if txt_lower = "yes" then Confirm Yes
  else if txt_lower = "no" then Confirm No
  else if txt_lower = "save" then Save
  else if txt_lower = "profile" then Goto ProfilePage
  else if txt_lower = "swipe" then Goto SwipePage
  else if txt_lower = "match" then Goto MatchPage
  else if txt_lower = "back" then Goto MainPage
  else if txt_lower = "update" then Update
  else if txt_lower = "0" then Field 0
  else if txt_lower = "1" then Field 1
  else if txt_lower = "2" then Field 2
  else if txt_lower = "3" then Field 3
  else if txt_lower = "4" then Field 4
  else if txt_lower = "reset" then Reset
  else if txt_lower = "matchify" then Matchify
  else if txt_lower = "period" then Period
  else if String.contains txt ','
  then
    let dt_lst = String.split_on_char ',' txt in
    if List.length dt_lst <> 2 then Unknown txt
    else
      let time = parse_time (List.nth dt_lst 1) in
      if time < 0 then Unknown txt
      else if List.hd dt_lst = "monday" then Day (Monday(time))
      else if List.hd dt_lst = "tuesday" then Day (Tuesday(time))
      else if List.hd dt_lst = "wednesday" then Day (Wednesday(time))
      else if List.hd dt_lst = "thursday" then Day (Thursday(time))
      else if List.hd dt_lst = "friday" then Day (Friday(time))
      else if List.hd dt_lst = "saturday" then Day (Saturday(time))
      else if List.hd dt_lst = "sunday" then Day (Sunday(time))
      else Unknown txt
  else Unknown txt_lower
