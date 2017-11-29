type swipeDirection = Left | Right
type confirm = Yes | No
type credentials =
  {
    netid : string;
    password : string
  }

type command =
  | Swipe of swipeDirection
  | Quit
  | Login of credentials
  | Confirm of confirm
  | Save
  | Unknown

let parse_command txt =
  let txt_lower = String.lowercase_ascii txt in
  if txt_lower = "l" then Swipe Left
  else if txt_lower = "r" then Swipe Right
  else if txt_lower = "quit" then Quit
  else if txt_lower = "yes" then Confirm Yes
  else if txt_lower = "no" then Confirm No
  else if txt_lower = "save" then Save
  else Unknown
