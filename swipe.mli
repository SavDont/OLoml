module type Swipe = sig
  (* [swipe_item] represents the type which clients are "swiping" on*)
  type swipe_item

(* [swipe_value] represents a ranking of how "good" a [swipe_item] is.
 * it is assigned to a [swipe_item] when the user "swipes" on said item. *)
  type swipe_value

(* [swipe_results] represents a collection of swipe_items which have
 * either been assigned [swipe_value] from the client "swiping" on them,
 * or have a default [swipe_value] from not being "swiped" on. *)
  type swipe_results

(* [swipe sr si sv] is the [swipe_results] that result from updating
 * sr by assigning the swipe_item, si, with the swipe_value option sv.
 * Requires: si must already be present in sr. *)
  val swipe : swipe_results -> swipe_item -> swipe_value option -> swipe_results

(* [gen_swipe_results sr] gives the json representation of sr. *)
  val gen_swipe_results : swipe_results -> Yojson.Basic.json

(* [init_swipes si_lst] generates swipe_results from a list of swipe_items,
 * such that each swipe_item is assigned a default swipe_value. *)
  val init_swipes : swipe_item list -> swipe_results

(* [write_swipes net pwd s_results] writes s_results to the database
 * for the student identified by net. If write is unsuccessful,
 * returns false, otherwise returns true.  May be unsuccessful
 * if net is not in the database, or if pwd is not correct for net.
 * Requires: s_results is the result of converting a valid swipe
 * result type into a json, then string form.
 * Side-effects: updates database *)
  val write_swipes : string -> string -> swipe_results -> bool
end

module SwipeStudentPool : Swipe
  with type swipe_item = Student.student
  with type swipe_value = Pool.score
