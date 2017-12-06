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

val parse_command : string -> command
