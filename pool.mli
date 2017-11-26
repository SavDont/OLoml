open Student
(* [score] represents how valuable or "good" a partnership might be *)
type score = float

(* a [Pool] is an ordered representation of entries.
 * the greatest entry is the first to be accessed, and
 * the least entry is the last to be accessed. *)
module type Pool = sig
  type key
  type value
(* [pool] is the type representing the underlying
 * datastructure of this module.  *)
  type pool

(* [empty] is the empty pool *)
  val empty    : pool

(* [is_empty p] is true iff p is empty. *)
  val is_empty : pool -> bool

(* [push i p] is p with i inserted in its correct ordered position.
* Requires: i is not already in p *)
  val push     : (key * value) -> pool -> pool

(* [peek p] is the next greatest item in p. Unlike pop,
 * it does not remove said item. Returns None if p is empty, and Some v
 * if it is not. *)
  val peek     : pool -> (key * value) option

(* [pop p] is p with the next greatest item removed from it.
 * If p is empty, it returns the empty pool. *)
  val pop      : pool -> pool

(* [poolify p p_lst] is a pool of maximum 25 people, from people_lst,
 * who are determined to be the most compatible matches for p,
 * based on the results of calling [compatability_score] on each
 * person in p_lst.
 * note: the maximum number of people + the features that determine
 * this compatibility score are tbd. *)
  val poolify : value -> value list -> pool

(* [compatability_score p1 p2] gives the [score] representing how
 * "good" a partnership between p1 and p2 appears.
 * [compatibility_score a b] should equal [compatability_score c d] if
 * a = b and c = d
 * [compatibility_score a b] should equal [compatability_score b a]
 *)
(* val compatability_score : Student.student -> Student.student -> score *)
  val size : pool -> int
  val to_list : pool -> (key * value) list
end

module type TupleComparable = sig
  type key
  type value
  val tuple_comparison : (key * value) -> (key * value) -> int
  val tuple_gen : value -> value -> (key * value)
end

module MakePool (T : TupleComparable): Pool

module StudentScores : TupleComparable
  with type key = score
  with type value = student

module StudentPool : Pool
  with type key = score
  with type value = student
