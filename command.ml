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
  | Reset
  | Matchify
  | Period
  | CLocation
  | CClasses
  | CSchedule
  | CBio
  | CHours
  | North
  | West
  | CTown
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
  else if txt_lower = "location" then CLocation
  else if txt_lower = "classes" then CClasses
  else if txt_lower = "schedule" then CSchedule
  else if txt_lower = "north" then North
  else if txt_lower = "west" then West
  else if txt_lower = "collegetown" then CTown
  else if txt_lower = "bio" then CBio
  else if txt_lower = "hours" then CHours
  else if txt_lower = "reset" then Reset
  else if txt_lower = "matchify" then Matchify
  else if txt_lower = "period" then Period
  else if String.contains txt ' '
  then
    let dt_lst = String.split_on_char ' ' txt in
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
