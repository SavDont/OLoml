(* [class_results] represents the results of swipes from all students
 * in a class *)
type class_results

(* [gen_class_results ()] gives the swipe results from the class of
 * students, as queried from the SQL database. *)
val gen_class_results : unit -> class_results

(* [matching] represents a system's final decision of a partner group*)
type matching

(* [matchify r] is a final matching of all students in a class
 * based on r.
 * - The specifics behind this algorithm are tbd
 * - Handling unmatched students tbd *)
val matchify : class_results -> matching
