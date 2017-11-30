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
  | Unknown of string

val parse_command : string -> command
