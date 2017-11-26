open Pool
open Student
open Swipe
open SwipeStudentPool
open StudentPool

(* code to test swiping *)
let gen_test_student name =
  {
    name = name;
    netid = "ec123";
    year = Soph;
    schedule =
      {
        monday = {
          morning = true;
          afternoon = true;
          evening = true
        };
        tuesday = {
          morning = true;
          afternoon = true;
          evening = true
        };
        wednesday = {
          morning = true;
          afternoon = true;
          evening = true
        };
        thursday = {
          morning = true;
          afternoon = true;
          evening = true
        };
        friday = {
          morning = true;
          afternoon = true;
          evening = true
        };
        saturday = {
          morning = true;
          afternoon = true;
          evening = true
        };
        sunday = {
          morning = true;
          afternoon = true;
          evening = true
        };
      };
    courses_taken = [CS_3110];
    skills = [OCaml(5)];
    hours_to_spend = 40
  }

let test_pool = poolify (gen_test_student "Joe")
    [gen_test_student "Mara"; gen_test_student "Lisa"; gen_test_student "Bob"; gen_test_student "Max"]

let student = match peek test_pool with
  | None -> failwith "blah"
  | Some s -> s

let swipes = [gen_test_student "Joe"; gen_test_student "Mara"; gen_test_student "Lisa"; gen_test_student "Max"]

let swipes_r = init_swipes swipes

let swipes_lst = swipe swipes_r (snd student) (Like (fst student))

let results = gen_swipe_results swipes_lst
