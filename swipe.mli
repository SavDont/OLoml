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
end

module SwipeStudentPool : Swipe
  with type swipe_item = Student.student
  with type swipe_value = Pool.score
