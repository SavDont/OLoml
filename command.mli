(* Type representing the different directions a student can swipe on other
 * students. Left is a "negative" swipe, while Right is "positive".*)
type swipeDirection = Left | Right

(* Type representing a user's response when prompted for a yes or no question.*)
type confirm = Yes | No

(* Type representing different pages in a student's program that they
 * are able to navigate to. *)
type loc =
  | SwipePage
  | MatchPage
  | MainPage
  | ProfilePage

(* Type representing a time of the week in a student's schedule. The integer
 * is either a 0 for "morning", 1 for "afternoon", or 2 for "evening"*)
type wkday =
  | Monday of int
  | Tuesday of int
  | Wednesday of int
  | Thursday of int
  | Friday of int
  | Saturday of int
  | Sunday of int

(* Type representing commands users can enter into the main REPL,
 * causing navigation and actions within it. *)
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

(* [parse_command str] gives the command form of a user's input into
 * the main REPL.  If the input does not match a standard command type,
 * it returns Unknown str. *)
val parse_command : string -> command
