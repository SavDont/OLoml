open Pool
open Student
open Swipe
open SwipeStudentPool
open StudentPool
open Command
open Professor
open Loml_client
open Match

exception QuitREPL

(* [check_creds net pwd] gives true if net pwd is a valid netid, password
 * combination such that the user is not authenticated.  It returns false
 * if not. *)
let check_creds net pwd =
  match credentials_post net pwd with
  | (`OK,str) -> true
  | _ -> false

(* [get_authed] is the entry-point for the repl. It checks if a user
 * is authenticated.  If the user is admin (ie netid = admin), they
 * are sent into a separate admin loop. *)
  let rec get_authed () =
  print_string("\nNetid: ");
  let net = (read_line ()) |> String.trim |> String.lowercase_ascii in
  if net = "quit" then raise QuitREPL;
  print_newline ();
  print_string("Password (case-sensitive): ");
  let pwd = read_line () in
  print_newline();
  match check_creds net pwd with
  | true ->
    print_endline("Success. Hello "^net);
    begin match net with
      | "admin" -> prof_main_outer net pwd
      | _ -> student_main_outer net pwd
    end
  | _  ->
    print_endline ("\nIncorrect Credentials. Try again, or 'quit'.");
    get_authed ();

and

  (* [prof_main_outer] is the main page for admins. *)
  prof_main_outer net pwd =
  match period_get net pwd with
  | (`OK,str) ->
    begin
      match str with
      | "null" ->
        print_endline ("\nThe class is not ready yet. Enter 'period' to set"^
                       " the valid periods for the class and import students,"^
                       " or 'quit' to quit.");
        prof_set_period net pwd
      | "match" ->
        print_endline ("\nIt's time to generate matches. Enter 'matchify'"^
                       " to run the matching algorithm and store matches."^
                       " Enter 'reset' to reset class, or 'quit' to quit.");
        prof_match net pwd
      | _ ->
        print_endline ("\nYour class is currently running and matches "^
                       "cannot be generated until the match period you set."^
                       " Your only option is to reset. Enter 'reset' to "^
                       "reset, or 'quit' to quit.");
        reset_outer net pwd
    end
  | _ ->
    print_endline("\nError: Terminating program.");

and

  (* [prof_set_period] handles setting up the class for admin.  Admin
   * must enter  a valid date for when swiping will begin and upload
   * a json following the schema included with this project. *)
  prof_set_period net pwd =
  print_string("\n> ");
  match parse_command (read_line ()) with
  | Period -> print_endline ("\nEnter the start date of the swipe period "^
                             "in the form 'MM DD YYYY'");
    print_string("\n> ");
    let swDate = read_line () |> str_to_time in
    print_endline ("\nEnter the start date of the match period in the form"^
                   " 'MM DD YYYY'");
    print_string("\n> ");
    let mtDate = read_line () |> str_to_time in
    begin
      match (swDate, mtDate) with
      | (Some d1, Some d2) ->
        print_endline ("\nEnter the json file directory to import students");
        print_string("\n> ");
        let dir = read_line () in
        let impSuccess = import_students dir pwd in
      begin
        (* successful import of students? *)
        match impSuccess with
        | true  ->
          let pdSuccess = set_periods d1 d2 pwd in
          (* successful setting of periods? *)
          begin match pdSuccess with
            | true ->
                print_endline ("\n Class setup completed!");
                prof_main_outer net pwd
            | _ ->
              print_endline("\n Invalid dates. Try again.");
              let _ = reset_class pwd in
              prof_main_outer net pwd
          end
        | _ ->
          print_endline ("\n Error importing students. Try again.");
          let _ = reset_class in
          prof_main_outer net pwd
      end
      | _ ->
        print_endline("\nUnrecognized date. Enter 'period','reset',or 'quit'.");
        prof_set_period net pwd
  end
  | Quit -> quit_check_outer net pwd prof_main_outer
  | _ ->
    print_endline("\nUnrecognized command. Enter 'period', 'reset', or 'quit'.");
    prof_set_period net pwd
and

  (* [prof_match] gives professor the option of running the matching
   * algorithm on all students who have saved swipe results.
   * (note: algorithm will still work if not everyone has)*)
  prof_match net pwd =
  print_string("\n> ");
  match parse_command (read_line ()) with
  | Matchify ->
    print_endline ("\nRunning algorithm...this might take a bit.");
    let s_results = gen_class_results pwd in
    begin
      match matchify s_results pwd with
      | true ->
        print_endline ("\nMatches generated and stored successfully.");
        print_endline ("\nLogging out...")
      | _ ->
        failwith "add error message"
    end
  | Quit -> quit_check_outer net pwd prof_main_outer
  | Reset ->
    print_endline ("\nAre you sure you want to reset? Enter 'yes' or 'no'.");
    reset_inner net pwd
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'matchify', 'reset', or 'quit'.");
    prof_match net pwd

and

  (* [reset_outer] gives admin the option to quit or reset *)
  reset_outer net pwd =
  print_string("\n> ");
  match parse_command (read_line ()) with
  | Reset ->
    print_endline ("\nAre you sure you want to reset? Enter 'yes' or 'no'.");
    reset_inner net pwd
  | Quit -> quit_check_outer net pwd prof_main_outer
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'reset' or 'quit'.");
    reset_outer net pwd

and

  (* [reset_inner] asks for confirmation from admin to reset class.
   * this clears all data, except for admin credentials. *)
  reset_inner net pwd =
  print_string("\n> ");
  match parse_command (read_line ()) with
  | Confirm Yes ->
    begin
      match reset_class pwd with
      | true ->
        print_endline ("\nClass reset. Re-start program to continue.")
      | _ ->
        print_endline ("\nError. Try again.");
        prof_main_outer net pwd
    end
  | Confirm No ->
    print_endline ("\nClass not reset.");
    prof_main_outer net pwd
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'yes' or 'no'.");
    reset_inner net pwd

and

  (* [student_main_outer] is the main page for student users *)
  student_main_outer net pwd =
  match period_get net pwd with
  | (`OK,str) ->
    begin
      match str with
      | "swipe" ->
        print_endline ("\nIt's time to swipe for potential matches. ");
        print_endline ("\nenter 'swipe' to swipe or 'quit' to quit");
        swipe_period net pwd
      | "match" ->
        match_period net pwd
      | "update" ->
        print_endline ("\nSwiping has not begun. Enter 'profile' to view"^
                       " your profile, or 'quit' to quit");
        update_period net pwd
      | _ ->
        print_endline ("\nThe system is not currently set up. Check back later.");
    end
  | _ ->
    print_endline ("\nError: Terminating program.");

and

  (* [match_period] prints the student this user has matched with if
   * the professor has already run the algorithm.  If there are an odd
   * number of students in the class, the student is matched
   * with a netid of "UNMATCHED", in which case this should be resolved
   * by talking with the professor. *)
  match_period net pwd =
  match get_match net pwd with
  | Some s ->
    print_endline ("\nThe system is done matching partners.\n");
    print_endline ("\nHere's your match:\n\n");
    print_endline (printable_student s);
    print_endline ("\nMatching complete. Terminating program.");
  | None ->
    print_endline ("\nSorry, your match isn't ready yet. Check back later.");
    print_endline ("\nLogging out...");
and

  (* [swipe_period] gives students the option to start swiping or quit. *)
  swipe_period net pwd =
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Goto SwipePage ->
    let students = get_all_students () in
    begin
      match get_student net pwd with
      | None ->
        print_endline ("\nError retrieving swipes. Try Again.");
        student_main_outer net pwd
      | Some s ->
        let swipes = init_swipes students in
        let pl = poolify s students in
        outer_swipe_loop pl net pwd swipes
    end
  | Quit -> quit_check_outer net pwd student_main_outer
  | _ ->
    print_endline("\nUnrecognized command. Enter 'swipe', 'profile', or 'quit'.");
    swipe_period net pwd

and

  (* [update_period] gives students the option to go to their profile
   * page, where they can view and edit.  They can also quit. *)
  update_period net pwd =
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Goto ProfilePage -> outer_profile_loop net pwd
  | Quit -> quit_check_outer net pwd student_main_outer
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'profile' or 'quit'.");
    update_period net pwd

and

  (* [outer_profile_loop] allows students to view their profile,
   * and gives the option to update it. *)
  outer_profile_loop net pwd =
  match get_student net pwd with
  | None ->
    print_endline ("\nError retrieving profile. Try Again.");
    student_main_outer net pwd
  | Some s ->
    print_endline (printable_student s);
    print_newline ();
    print_endline ("\nEnter 'update' to update your profile, or 'quit' to quit");
    inner_profile_loop net pwd

and

  (*[inner_profile_loop] routes the student's choice between updating their
   * profile and quitting. *)
  inner_profile_loop net pwd =
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Update -> update_loop net pwd
  | Quit -> quit_check_outer net pwd outer_profile_loop
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'update' or 'quit'.");
    inner_profile_loop net pwd

and

  (* [update_loop] routes the type of update the student wants to perform.*)
  update_loop net pwd =
  print_endline ("\nWhat would you like to update? Enter '0' for location, "^
                 "'1' for classes taken, '2' for schedule, '3' for hours "^
                 "willing to spend, or '4' for profile bio. Enter 'quit' to "^
                 "quit. ");
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Field 0 -> update_loc net pwd
  | Field 1 -> update_classes net pwd
  | Field 2 -> update_sched net pwd
  | Field 3 -> update_hours net pwd
  | Field 4 -> update_text net pwd
  | Quit -> quit_check_outer net pwd update_loop
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'quit' or the number of "^
                  "field you want to update.");
    inner_profile_loop net pwd

and

  (* [update_feedback net pwd] attempts an update of data.
   * if it's sucessful, it prints a confirmation.  If not, it prints an error.
   * It then routes back to the profile page. *)
  update_feedback net pwd data =
  match update_profile net pwd data with
  | true ->
    print_endline ("\nProfile updated.");
    outer_profile_loop net pwd
  | _ ->
    print_endline ("\nError. Please try again.");
    outer_profile_loop net pwd

and

  (* [update_loc] handles update of a student's living location. *)
  update_loc net pwd =
  print_endline ("\nEnter '0' to set location to North Campus, '1' to set "^
                 "location to West Campus, or '2' to set location to "^
                 "Collegetown. Enter 'quit' to quit. ");
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Field 0 -> update_feedback net pwd [Location North]
  | Field 1 -> update_feedback net pwd [Location West]
  | Field 2 -> update_feedback net pwd [Location Collegetown]
  | Quit -> quit_check_outer net pwd update_loc
  | _ ->
    print_endline ("\nUnrecognized command. Enter '0','1','2',or 'quit'.");
    update_loc net pwd

and

  (* [update_classes] handles updating students' course lists.  If the
   * student enters a class that is already contained on their profile,
   * it removes it.  If the class is not already contained, it is added. *)
  update_classes net pwd =
  match get_student net pwd with
  | None ->
    print_endline ("\nError in finding profile. Please try again.");
    outer_profile_loop net pwd
  | Some s ->
    print_endline ("\nEnter the 4-digit CS class number that you want to add"^
                  " or remove, or'quit' to quit. ");
    print_string ("\n> ");
    begin
      match parse_command (read_line ()) with
      | Quit -> quit_check_outer net pwd update_classes
      | Unknown i ->
        let class_num =
          try (int_of_string i) with
          | Failure _ -> -1 in
          begin
            match class_num with
            | i when not (valid_course i) ->
              print_endline ("\nError: invalid course number. Try again.");
              update_classes net pwd
            | i ->
              let old_classes = s.courses_taken in
              (* class already on profile? *)
              let upd =
              if List.mem i old_classes
              then [Courses (List.filter (fun x -> x <> i) old_classes)]
              else [Courses (i::old_classes)] in
              update_feedback net pwd upd
          end
      | _ ->
        print_string ("\nUnrecognized command. ");
        update_classes net pwd
      end

and

  (* [update_sched] handles the update of a single day and time in
   * a student's schedule.  If schedule is null, it initializes a
   * schedule for them in which they are not free on any day. *)
  update_sched net pwd =
  match get_student net pwd with
  | None -> print_endline ("\nError in finding profile. Please try again.");
    outer_profile_loop net pwd
  | Some st ->
    (* temp array conversion to facilitate mutability *)
    let arr =
      if List.length st.schedule = 0 then Array.make 21 false (* empty init *)
      else Array.of_list st.schedule in
    print_endline ("\nEnter a time you want to either add or remove from your"^
                   " availability schedule, in the form 'day,time' where day "^
                   "is 'monday','tuesday', 'wednesday', 'thursday', 'friday',"^
                   " 'saturday', or 'sunday' and time is 'morning', "^
                   "'afternoon', or 'evening'. You may also 'quit'.");
    print_string ("\n> ");
    begin
      match parse_command (read_line ()) with
      | Day (Monday t) ->
        let () = arr.(t) <- not (arr.(t)); in
        update_feedback net pwd [Schedule (Array.to_list arr)]
      | Day (Tuesday t) ->
        let () = arr.(t + 1) <- not (arr.(t + 1)); in
        update_feedback net pwd [Schedule (Array.to_list arr)]
      | Day (Wednesday t) ->
        let () = arr.(t + 2) <- not (arr.(t + 2)); in
        update_feedback net pwd [Schedule (Array.to_list arr)]
      | Day (Thursday t) ->
        let () = arr.(t + 3) <- not (arr.(t + 3)); in
        update_feedback net pwd [Schedule (Array.to_list arr)]
      | Day (Friday t) ->
        let () = arr.(t + 4) <- not (arr.(t + 4)); in
        update_feedback net pwd [Schedule (Array.to_list arr)]
      | Day (Saturday t) ->
        let () = arr.(t + 5) <- not (arr.(t + 5)); in
        update_feedback net pwd [Schedule (Array.to_list arr)]
      | Day (Sunday t) ->
        let () = arr.(t + 6) <- not (arr.(t + 6)); in
        update_feedback net pwd [Schedule (Array.to_list arr)]
      | Quit -> quit_check_outer net pwd update_sched
      | _ ->
        print_endline
          ("Unrecognized command. Please enter a valid 'day,time' or 'quit'.");
    end


and

  (* [update_hours] allows students to update how many hours they're
   * willing to spend on a project.  The integer they enter must
   * be convertable from a string to an int. *)
  update_hours net pwd =
  print_endline ("\nEnter the integer number of hours you're willing to"^
                " spend on this project, or 'quit' to quit.");
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Quit -> quit_check_outer net pwd update_hours
  | Unknown i ->
    begin
      match try (int_of_string i) with
        | Failure _ -> -1 with
      | v when v < 0 ->
        print_endline ("\nInvalid integer. Try again.");
        outer_profile_loop net pwd
      | v -> update_feedback net pwd [Hours i]
    end
  | _ ->
    print_string ("\nUnrecognized command. ");
    update_hours net pwd

and

  (* [update_text] handles update of student bios. *)
  update_text net pwd =
  print_endline ("\nEnter your bio: ");
  print_string ("\n");
  let txt = read_line () in
  update_feedback net pwd [Text txt]

and

  (* quit_check_outer prompts a user for confirmation on quitting  *)
  quit_check_outer net pwd r_func =
  print_endline ("\nAre you sure you want to quit? Enter 'yes' or 'no'");
  quit_check_inner net pwd r_func

and

  (* [quit_check_inner net pwd r_func] quits the program if users confirm.
   * otherwise, it routes the user back to they were in the program.
   * the spot is represented by r_func. *)
  quit_check_inner net pwd r_func =
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Confirm Yes -> raise QuitREPL
  | Confirm No -> r_func net pwd
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'yes' or 'no'.");
    quit_check_inner net pwd r_func

and

  (* [outer_swipe_loop] routes a user to swiping on students if
   * their pool of students is not empty.  If it is empty, it routes
   * students to saving their swipes. *)
  outer_swipe_loop pl net pwd s_results =
  match StudentPool.peek pl with
  | Some s ->
    print_endline ("\n"^(snd s |> printable_student));
    print_endline ("\nenter 'L' to swipe left (dislike), 'R' to swipe right"^
                  " (like), or 'quit' to quit.");
    inner_swipe_loop pl net pwd s_results s
  | None ->
    print_endline ("\nYou have finished swiping. Type 'save' to save your"^
                   " swipes, or 'quit' to quit. If you have already saved"^
                  " swipes, this will overwrite them.");
    save_loop pl net pwd s_results

and

  (* [quit_loop_swipe] quits the program if the user confirms.  If not,
   * it saves the state of their swiping, and returns them to that state. *)
  quit_loop_swipe pl net pwd s_results =
  print_string("\n> ");
  match parse_command (read_line ()) with
  | Confirm Yes -> raise QuitREPL
  | Confirm No ->
    print_endline ("\nBack to swiping...");
    outer_swipe_loop pl net pwd s_results
  | _ ->
    print_endline ("\nUnrecognized command. Please enter 'yes' or 'no'. ");
    quit_loop_swipe pl net pwd s_results

and

  (* [inner_swipe_loop] handles the left and right swiping that students
   * perform on their classmates. *)
  inner_swipe_loop pl net pwd s_results compat =
  print_string("\n> ");
  match parse_command (read_line ()) with
  | Swipe Left ->
    let new_comp = Some(-1.0*.(fst compat)) in
    let new_results = SwipeStudentPool.swipe s_results (snd compat)(new_comp)in
    let new_pool = StudentPool.pop pl in
    outer_swipe_loop new_pool net pwd new_results
  | Swipe Right ->
    let new_comp = Some(fst compat) in
    let new_results = SwipeStudentPool.swipe s_results (snd compat)(new_comp)in
    let new_pool = StudentPool.pop pl in
    outer_swipe_loop new_pool net pwd new_results
  | Quit ->
    print_endline ("\nare you sure you want to quit? You will lose all of your"^
                  " swipe data. Enter 'yes' or 'no'.");
    quit_loop_swipe pl net pwd s_results
  | _ ->
    print_endline ("\nUnrecognized command. Please enter 'L', 'R', or 'quit'.");
    inner_swipe_loop pl net pwd s_results compat

and

  (* [save_loop] handles writing a user's swipes to the database. *)
  save_loop pl net pwd s_results =
  print_string("\n> ");
  match parse_command (read_line ()) with
  | Save ->
    begin
      match write_swipes net pwd s_results with
      | true ->
        print_endline ("\nSwipes saved.");
        print_endline ("\nCheck back later to see your match. Logging out...");
      | _ ->
        print_endline ("\nSave unsuccessful. Enter 'save' to try again, or"^
                      " 'quit' to quit.");
        save_loop pl net pwd s_results
    end
  | Quit ->
    print_endline ("\nare you sure you want to quit? You will lose all of your"^
                  " swipe data. Enter 'yes' or 'no'");
    quit_loop_swipe pl net pwd s_results
  | _ ->
    print_endline ("\nUnrecognized command. Please enter 'save' or 'quit'.");
    save_loop pl net pwd s_results

(* The start-point for this REPL. *)
let main () =
  print_endline("\nWelcome to OLoml!  Let's find you the love of your CS life."^
                " AKA your only life.");
  print_endline("\nEnter your credentials to get started, or 'quit' to quit:");
  try get_authed () with
  | QuitREPL -> print_endline ("Quitting")

let () = main ()
