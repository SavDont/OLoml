(* represents the results of swipes from all students in a class *)
type swipe_results_class

(* should query the database and generate the swipe_results_class *)
val gen_class_results : unit -> swipe_results_class

(* matching of partners *)
type matching

(* make the matching *)
val matchify : swipe_results_class -> matching


