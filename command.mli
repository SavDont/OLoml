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

val parse_command : string -> command
