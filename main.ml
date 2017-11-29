open Pool
open Student
open Swipe
open SwipeStudentPool
open StudentPool
open Command

(* continuously pops and prints from pool, asking for response from student *)
let rec outer_swipe_loop pl net pwd s_results =
  match StudentPool.peek pl with
  | Some s ->
    print_endline ("\n"^(snd s |> printable_student));
    print_endline ("\nenter 'L' to swipe left (dislike), 'R' to swipe right (like), or 'quit' to quit.");
    inner_swipe_loop pl net pwd s_results s
  | None ->
    print_endline ("\nYou have finished swiping. Type 'save' to save your swipes, or 'quit' to quit.");
    save_loop pl net pwd s_results

and

  quit_loop pl net pwd s_results =
  print_string("> ");
  match parse_command (read_line ()) with
  | Confirm Yes -> print_endline ("\nQuitting");
  | Confirm No ->
    print_endline ("\nBack to swiping...");
    outer_swipe_loop pl net pwd s_results
  | _ ->
    print_endline ("Unrecognized command. Please enter 'yes' or 'no'. ");
    quit_loop pl net pwd s_results

and

  inner_swipe_loop pl net pwd s_results s =
  print_string("> ");
  match parse_command (read_line ()) with
  | Swipe Left ->
    let new_results = SwipeStudentPool.swipe s_results (snd s) (Some(-1.0)) in
    let new_pool = StudentPool.pop pl in
    outer_swipe_loop new_pool net pwd new_results
  | Swipe Right ->
    let new_results = SwipeStudentPool.swipe s_results (snd s) (Some(fst s)) in
    let new_pool = StudentPool.pop pl in
    outer_swipe_loop new_pool net pwd new_results
  | Quit ->
    print_endline ("\nare you sure you want to quit? You will lose all of your swipe data. Enter 'yes' or 'no'.");
    quit_loop pl net pwd s_results
  | _ ->
    print_endline ("\nUnrecognized command. Please enter 'L', 'R', or 'quit'.");
    inner_swipe_loop pl net pwd s_results s

and

  (* TODO: add swipe writing *)

  save_loop pl net pwd s_results =
  print_string("> ");
  match parse_command (read_line ()) with
  | Save ->
    let swipe_succ = write_swipes net pwd s_results in
    if swipe_succ then print_endline ("\nSwipes saved.");
    if not swipe_succ
    then print_endline ("\nSave unsuccessful. Enter 'save' to try again, or 'quit' to quit.");
    save_loop pl net pwd s_results
  | Quit ->
    print_endline ("\nare you sure you want to quit? You will lose all of your swipe data. Enter 'yes' or 'no'");
    quit_loop pl net pwd s_results
  | _ ->
    print_endline ("\nUnrecognized command. Please enter 'save' or 'quit'.");
    save_loop pl net pwd s_results


let test_students =
  [
    {
      name = "Bob";
      netid = "bb123";
      year = Jun;
      courses_taken = [1110; 2110; 3110];
      skills =
        {
          excellent = [Python; OCaml];
          great = [];
          good = [C];
          some_exposure = [Ruby];
        };
      location = Collegetown;
      hours_to_spend = 40;
      schedule = [true;true;true;false;false;false;true;false;false;true;false;
                    false;true;false;true;false;true;false;true;false;true];
      profile_text = "hey I'm bob";
    };
    {
      name = "Bobette";
      netid = "bb124";
      year = Fresh;
      courses_taken = [1110];
      skills =
        {
          excellent = [];
          great = [];
          good = [];
          some_exposure = [Python];
        };
      location = North;
      hours_to_spend = 50;
      schedule = [true;true;false;false;true;false;true;true;false;true;true;
                    false;false;false;false;true;true;true;true;false;false];
      profile_text = "hey I'm bobette";
    };
    {
      name = "Bobina";
      netid = "bb125";
      year = Sen;
      courses_taken = [1110; 2110; 3110; 4410; 4110; 2800; 4820];
      skills =
        {
          excellent = [Python; OCaml; C];
          great = [Java];
          good = [];
          some_exposure = [Ruby];
        };
      location = Collegetown;
      hours_to_spend = 60;
      schedule = [true;true;true;false;false;false;true;false;false;true;false;
                    false;true;false;true;false;true;false;true;false;true];
      profile_text = "hey I'm bobina";
    };
    {
      name = "Bobby-Joe";
      netid = "bb126";
      year = Soph;
      courses_taken = [1110; 2110; 3110];
      skills =
        {
          excellent = [Python; OCaml];
          great = [];
          good = [C];
          some_exposure = [Ruby];
        };
      location = Collegetown;
      hours_to_spend = 40;
      schedule = [true;false;false;false;false;false;true;false;false;true;false;
                    false;true;false;true;false;true;false;true;false;true];
      profile_text = "hey I'm bobby-joe";
    };
  ]

let test_student =
{
  name = "Bob";
  netid = "bb123";
  year = Jun;
  courses_taken = [1110; 2110; 3110];
  skills =
    {
      excellent = [Python; OCaml];
      great = [];
      good = [C];
      some_exposure = [Ruby];
    };
  location = Collegetown;
  hours_to_spend = 40;
  schedule = [true;true;true;false;false;false;true;false;false;true;false;
                false;true;false;true;false;true;false;true;false;true];
  profile_text = "hey I'm bob";
}

let test_student_pool = StudentPool.poolify test_student test_students

let main () =
  outer_swipe_loop test_student_pool "bb123" "yo" (SwipeStudentPool.init_swipes test_students)

let () = main ()
