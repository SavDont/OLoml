type swipeDirection = Left | Right
type confirm = Yes | No
type loc =
  | SwipePage
  | MatchPage
  | MainPage
  | ProfilePage

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
  | Remove
  | Unknown of string

let parse_command txt =
  let txt_lower = String.lowercase_ascii txt in
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
  else if txt_lower = "reset" then Reset
  else if txt_lower = "matchify" then Matchify
<<<<<<< HEAD
  else if txt_lower = "period" then Period
=======
  else if txt_lower = "remove" then Remove
>>>>>>> 232f9230049e293c88020c38d0107a18b0961026
  else Unknown txt_lower
