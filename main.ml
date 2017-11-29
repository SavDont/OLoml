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
    print_endline ("\nenter L to swipe left (dislike), R to swipe right (like), or quit to quit.");
    inner_swipe_loop pl net pwd s_results s
  | None ->
    print_endline ("You have finished swiping. Type save to save your swipes, or quit to quit.");
    save_loop pl net pwd s_results

and

quit_loop pl net pwd s_results =
  match parse_command (read_line ()) with
  | Confirm Yes -> print_endline ("\nQuitting");
  | Confirm No ->
    print_endline ("\nBack to swiping...");
    outer_swipe_loop pl net pwd s_results
  | _ ->
    print_endline ("Unrecognized command. Please enter yes or no. ");
    quit_loop pl net pwd s_results

and

  inner_swipe_loop pl net pwd s_results s =
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
    print_endline ("\nare you sure you want to quit? You will lose all of your swipe data. Enter yes or no.");
    quit_loop pl net pwd s_results
  | _ ->
    print_endline ("\nUnrecognized command. Please enter L, R, or quit.");
    inner_swipe_loop pl net pwd s_results s

and

  (* TODO: add swipe writing *)

  save_loop pl net pwd s_results =
  match parse_command (read_line ()) with
  | Save -> print_endline ("TODO: call swipe write function");
  | Quit ->
    print_endline ("\nare you sure you want to quit? You will lose all of your swipe data. Enter yes or no");
    quit_loop pl net pwd s_results
  | _ ->
    print_endline ("\nUnrecognized command. Please enter save or quit.");
    save_loop pl net pwd s_results
