(* in the main, we will have a Pool that we continue to peek from. At every
 * iteration, we take the result of the peek and allow the user to swipe
 * left or right, updating the swipe_results_person as we go. at the end
 * (when we have exhausted the pool), we can take the swipe_results
 * (which should be fully populated) and write it to the DB *)

(* [Swipe] handles the act of deciding favorably or negatively
 * toward items that are popped, in order, from a pool. *)
module type Swipe = sig

  type swipe_item

  (* [decision] is a representation of a user's decision regarding
   * a person.  Said decision may be negative or positive. *)
  type decision =
    | Dislike
    | Like of Pool.score
    | Neutral

  (* [swipe_results] is a representation of the decisions
   * a user has made regarding a person *)
  type swipe_results


  (* [swipe p d] is the [swipe_results] representation
   * of the user's act of making a decision, d about a person, p. *)
  val swipe : swipe_results -> swipe_item -> decision -> swipe_results

  (* [write_swipe_results s] adds s to the connected database.
   * side-effects: updates the connected database. *)
  val gen_swipe_results : swipe_results -> Yojson.Basic.json

  val init_swipes : swipe_item list -> swipe_results
end

module SwipeStudentPool : Swipe
  with type swipe_item = Student.student
