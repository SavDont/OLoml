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
 * - algorithm will first order the pairs in [r] from highest compatibility
 *   to lowest compatibility score. It will then pair individuals in the order
 *   from highest compatibility score to lowest. Any unmatched students will
 *   be matched with "UNMATCHED"
 * requires: [r] must contain no duplicate netID pairs*)
val matchify : swipe_results_class -> matching
