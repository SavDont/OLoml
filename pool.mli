(* [score] represents how valuable or "good" a partnership might be *)
type score

(* a [Pool] is an ordered representation of entries.
 * the greatest entry is the first to be accessed, and
 * the least entry is the last to be accessed. *)
module type Pool = sig

(* [pool] is the type representing the underlying
 * datastructure of this module.  *)
  type 'a pool

(* [empty] is the empty pool *)
  val empty    : 'a pool

(* [is_empty p] is true iff p is empty. *)
  val is_empty : 'a pool -> bool

(* [push i p] is p with i inserted in its correct ordered position.
* Requires: i is not already in p *)
  val push     : 'a -> 'a pool -> 'a pool

(* [peek p] is the next greatest item in p. Unlike pop,
 * it does not remove said item. Returns None if p is empty, and Some v
 * if it is not. *)
  val peek     : 'a pool -> 'a option

(* [pop p] is p with the next greatest item removed from it.
 * If p is empty, it returns the empty pool. *)
  val pop      : 'a pool -> 'a pool
end

(* in the main, we will have a Pool that we continue to peek from. At every
 * iteration, we take the result of the peek and allow the user to swipe
 * left or right, updating the swipe_results_person as we go. at the end
 * (when we have exhausted the pool), we can take the swipe_results
 * (which should be fully populated) and write it to the DB *)

(* [Swipe] handles the act of deciding favorably or negatively
 * toward items that are popped, in order, from a pool. *)
module type Swipe = sig

(* [swipe_results] is a representation of the decisions
 * a user has made regarding a person *)
  type swipe_results

(* [decision] is a representation of a user's decision regarding
 * a person.  Said decision may be negative or positive. *)
  type decision

(* [swipe p d] is the [swipe_results] representation
 * of the user's act of making a decision, d about a person, p. *)
   val swipe : swipe_results -> Student.student -> decision -> swipe_results

(* [write_swipe_results s] adds s to the connected database.
 * side-effects: updates the connected database. *)
  val write_swipe_results : swipe_results -> unit
end

(* [compatability_score p1 p2] gives the [score] representing how
 * "good" a partnership between p1 and p2 appears.
 * [compatibility_score a b] should equal [compatability_score c d] if
 * a = b and c = d
 * [compatibility_score a b] should equal [compatability_score b a]
 *)
val compatability_score : Student.student -> Student.person -> score

(* [poolify p p_lst] is a pool of maximum 25 people, from people_lst,
 * who are determined to be the most compatible matches for p,
 * based on the results of calling [compatability_score] on each
 * person in p_lst.
 * note: the maximum number of people + the features that determine
 * this compatibility score are tbd. *)
val poolify : Student.student -> Student.student list -> pool
