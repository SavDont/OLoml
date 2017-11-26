module type Swipe = sig

  type swipe_item

  type swipe_value

  type swipe_results

  val swipe : swipe_results -> swipe_item -> swipe_value option -> swipe_results

  val gen_swipe_results : swipe_results -> Yojson.Basic.json

  val init_swipes : swipe_item list -> swipe_results
end

module SwipeStudentPool : Swipe
  with type swipe_item = Student.student
  with type swipe_value = Pool.score
