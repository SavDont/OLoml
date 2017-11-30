 (* [swipe_results_class] represents the results of swipes from all
 * students in a class *)
type swipe_results_class

(* [matching] represents a system's final decision of a partner group*)
type matching

(* [gen_class_results pwd] gives the swipe results from the class of
 * students, as queried from the SQL database. *)
val gen_class_results : string -> swipe_results_class

(* [matchify r] is a final matching of all students in a class
 * based on r.
 * - The specifics behind this algorithm are tbd
 * - Handling unmatched students tbd *)
val matchify : swipe_results_class -> matching
