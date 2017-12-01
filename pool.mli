open Student

type score = float

module type Pool = sig
  type key

  type value

(* [pool] represents a "pool" of key, value pairs, such that the
 * the pairs with the greatest key are the first accessed, and the
 * pairs with the least key are last accessed (like a max-heap)*)
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

(* [poolify p p_lst] is a pool of maximum 1/2 class size, from people_lst,
 * who are determined to be the most compatible matches for p,
 * based on the results of some ranking function.
 *
 * Note: p will not be included in pool
 *)
  val poolify : value -> value list -> pool

  (* [size p] gives the number of entries in p. *)
  val size : pool -> int
end

(* [TupleComparable] is the module used to determine what clients will
 * be swiping on in [Swipe], and what a pool will be composed of in [Pool]
*)
module type TupleComparable = sig

  (* [rank] is the type by which tuples are compared *)
  type rank

(* [item] is the information contained in a tuple, which is
 * compared to other tuples using a [rank] *)
  type item

(* [tuple comparison (r1, i1) (r2, i2)] is 1 if r1 is less than r2, -1
 * if r1 is greater than r2, and 0 if they are equal.
 * Note: this is backwards, as a [Pool] ranks entries from greatest to least *)
  val tuple_comparison : (rank * item) -> (rank * item) -> int

(* [tuple_gen i1 i2] produces a tuple, (r,i) with r equal to the compatibility
 * of i1 and i2, and i = i2.
 * [tuple_gen a b] and [tuple_gen b a] produce the same rank. *)
  val tuple_gen : item -> item -> (rank * item)

  (* [opt_key_to_string] gives the string representation of rank option.*)
  val opt_key_to_string : rank option -> string

  val get_id : item -> string 
end

module StudentScores : TupleComparable
  with type rank = score
  with type item = student

(* [StudentPool] is a module for pooling possible matches for a given
 * student. *)
module StudentPool : Pool
  with type key = score
  with type value = student
