(* represents the results of swipes from all students in a class *)
type class_results

(* should query the database and generate the class_results *)
val gen_class_results : unit -> class_results

(* matching of partners *)
type matching

(* make the matching *)
val matchify : class_results -> matching


