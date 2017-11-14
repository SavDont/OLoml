type score

(* will be list/heap, similar in form to the pool module
 should have a pop method - pop the head of it *)
module type Pool = sig
  type 'a pool
  val empty    : 'a pool
  val is_empty : 'a pool -> bool
  val push     : 'a -> 'a pool -> 'a pool
  val peek     : 'a pool -> 'a
  val pop      : 'a pool -> 'a pool
end

(* handle swipe logic on a single person and the logic of writing swipes
 * to the database *)

(* in the main, we will have a Pool that we continue to peek from. At every
 * iteration, we take the result of the peek and allow the user to swipe
 * left or right, updating the swipe_results as we go. at the end (when we
 * have exhausted the pool), we can take the swipe_results (which should be
 * fully populated) and write it to the DB *)

(* handle swipe logic on a single person and the logic of writing swipes
 * to the database *)
module type Swipe = sig
   type swipe_results
   type decision
   val swipe : People.person -> People.person -> decision -> swipe_results

  (* once we're done iterating through the pool, call this to write everything
   * into the database *)
  val write_swipe_results : swipe_results -> unit
end

(* create the ordered pool based on characteristics to be determined later
 * where the head of the pool is the most compatible and the tail is the
 * least compatible*)
val poolify : People.person -> People.person list -> pool

(* compatibility_score [a b] should equal compatability_score [c d] if
 * a = b and c = d
 * compatibility_score [a b] should equal compatability_score [b a] *)
val compatability_score : People.person -> People.person -> score
