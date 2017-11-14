<<<<<<< HEAD
(* [class_results] represents the results of swipes from all students
 * in a class *)
type class_results

(* [gen_class_results ()] gives the swipe results from the class of
 * students, as queried from the SQL database. *)
val gen_class_results : unit -> class_results
=======
(* represents the results of swipes from all students in a class *)
type swipe_results_class

(* should query the database and generate the swipe_results_class *)
val gen_class_results : unit -> swipe_results_class
>>>>>>> 902ef6ba9af1fae463341a2466e22ae425944a96

(* [matching] represents a system's final decision of a partner group*)
type matching

<<<<<<< HEAD
(* [matchify r] is a final matching of all students in a class
 * based on r.
 * - The specifics behind this algorithm are tbd
 * - Handling unmatched students tbd *)
val matchify : class_results -> matching
=======
(* make the matching *)
val matchify : swipe_results_class -> matching


>>>>>>> 902ef6ba9af1fae463341a2466e22ae425944a96
