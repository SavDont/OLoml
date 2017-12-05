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

let check_creds net pwd =
  match credentials_post net pwd with
  | (`OK,str) -> true
  | _ -> false

  let rec get_authed () =
  print_string("\nNetid: ");
  let net = (read_line ()) |> String.trim |> String.lowercase_ascii in
  if net = "quit" then raise QuitREPL;
  print_newline ();
  print_string("Password (case-sensitive): ");
  let pwd = read_line () in
  print_newline();
  (**)
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

  prof_main_outer net pwd =
  match period_get net pwd with
  | (`OK,str) ->
    begin
      match str with
      | "null" -> print_endline ("\nNo period has been set yet. Enter 'period' to set the valid periods for the class. Enter 'reset' to reset class, or 'quit' to quit.");
        prof_set_period net pwd
      | "update" ->
        print_endline ("\nStudents are currently updating profiles. Enter 'remove' to remove a student from the class, 'reset' to reset the entire class, or 'quit' to quit.");
        prof_update net pwd
      | "match" ->
        print_endline ("\nIt's time to generate matches. Enter 'matchify' to run the matching algorithm and store matches. Enter 'reset' to reset class, or 'quit' to quit.");
        prof_match net pwd
      | _ ->
        print_endline ("\nYour class is currently running and matches cannot be generated until the match period you set. Your only option is to reset. Enter 'reset' to reset, or 'quit' to quit.");
        reset_outer net pwd
    end
  | _ ->
    print_endline("\nError: Terminating program.");

and

  prof_set_period net pwd =
  match parse_command (read_line ()) with
  | Period -> print_endline ("\nPlease type the start date of the swipe period in the form 'MM DD YYYY'");
    let swDate = read_line () |> str_to_time in
    print_endline ("\nPlease type the start date of the match period in the form 'MM DD YYYY'");
    let mtDate = read_line () |> str_to_time in
    begin
      match (swDate, mtDate) with
      | (Some d1, Some d2) -> print_endline ("\nPlease type the json file directory to import students");
        let dir = read_line () in
        let pdSuccess = set_periods d1 d2 pwd in
        let impSuccess = import_students dir pwd in
      begin
        match (pdSuccess, impSuccess) with
        | (true, true) -> print_endline ("\n Class setup completed!");
          prof_main_outer net pwd
        | _ -> print_endline ("\nError");
          prof_main_outer net pwd
      end
      | _ -> print_endline("\nUnrecognized date. Enter 'period', 'reset', or 'quit'.");
        prof_set_period net pwd
  end
  | Quit -> quit_check_outer net pwd prof_main_outer
  | Reset -> print_endline ("\nAre you sure you want to reset? Enter 'yes' or 'no'.");
    reset_inner net pwd
  | _ -> print_endline("\nUnrecognized command. Enter 'period', 'reset', or 'quit'.");
    prof_set_period net pwd
and

  prof_update net pwd =
  match parse_command (read_line ()) with
  | Remove -> failwith "unimplemented"
  | Quit -> quit_check_outer net pwd prof_main_outer
  | Reset ->
    print_endline ("\nAre you sure you want to reset? Enter 'yes' or 'no'.");
    reset_inner net pwd
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'remove','quit', or 'reset'");
    prof_update net pwd

and


  prof_match net pwd =
  match parse_command (read_line ()) with
  | Matchify ->
    print_endline ("\nRunning algorithm...this might take a bit.");
    let s_results = gen_class_results pwd in
    begin
      match matchify s_results pwd with
      | true ->
        print_endline ("\nMatches generated and stored successfully. Returning to main page.");
        prof_main_outer net pwd
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

  student_main_outer net pwd =
  match period_get net pwd with
  | (`OK,str) ->
    begin
      match str with
      | "swipe" ->
        print_endline ("\nIt's time to swipe for potential matches. ");
        print_endline ("\nenter 'swipe' to swipe, 'profile' to view your profile, or 'quit' to quit");
        swipe_period net pwd
      | "match" ->
        match_period net pwd
      | "update" ->
        print_endline ("\nSwiping has not begun. Enter 'profile' to view your profile, or 'quit' to quit");
        update_period net pwd
      | _ ->
        print_endline ("\nThe system is not currently set up. Check back later.");
    end
  | _ ->
    print_endline ("\nError: Terminating program.");

and

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

  swipe_period net pwd =
  print_string ("> ");
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
  | Goto ProfilePage -> outer_profile_loop net pwd
  | Quit -> quit_check_outer net pwd student_main_outer
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'swipe', 'profile', or 'quit'.");
    swipe_period net pwd

and

  update_period net pwd =
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Goto ProfilePage -> outer_profile_loop net pwd
  | Quit -> quit_check_outer net pwd student_main_outer
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'profile' or 'quit'.");
    update_period net pwd

and

  outer_profile_loop net pwd =
  match (get_student net pwd, snd (period_get net pwd)) with
  | (None, _) ->
    print_endline ("\nError retrieving profile. Try Again.");
    student_main_outer net pwd
  | (Some s, "update") ->
    print_endline (printable_student s);
    print_newline ();
    print_endline ("\nEnter 'update' to update your profile, or 'quit' to quit");
    inner_profile_loop net pwd
  | (Some s, _) ->
    print_endline (printable_student s);
    print_newline ();
    print_endline ("\nEnter 'update' to update your profile, 'swipe' to swipe, or 'quit' to quit");
    inner_profile_loop_non_update net pwd

and

  inner_profile_loop_non_update net pwd =
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Update -> update_loop net pwd
  | Quit -> quit_check_outer net pwd outer_profile_loop
  | Goto SwipePage -> let students = get_all_students pwd in
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
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'update', 'swipe' or 'quit'.");
    inner_profile_loop_non_update net pwd

and

  inner_profile_loop net pwd =
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Update -> update_loop net pwd
  | Quit -> quit_check_outer net pwd outer_profile_loop
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'update' or 'quit'.");
    inner_profile_loop net pwd

and

  update_loop net pwd =
  print_endline ("\nWhat would you like to update? Enter '0' for location, '1' for classes taken, '2' for schedule, '3' for hours willing to spend, or '4' for profile bio. Enter 'quit' to quit. ");
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Field 0 -> update_loc net pwd
  | Field 1 -> update_classes net pwd
  | Field 2 ->
    let time_str = ["monday mornings";"monday afternoons";"monday evenings";
                    "tuesday mornings";"tuesday afternoons";"tuesday evenings";
                    "wednesday mornings";"wednesday afternoons";"wednesday evenings";
                    "thursday mornings";"thursday afternoons";"thursday evenings";
                    "friday mornings";"friday afternoons";"friday evenings";
                    "saturday mornings";"saturday afternoons";"saturday evenings";
                    "sunday mornings";"sunday afternoons";"sunday evenings"] in
    print_endline ("Answer 'yes' or 'no' to the following questions to build your schedule. You cannot quit until you've answered all of them:\n");
    update_sched net pwd time_str []
  | Field 3 -> update_hours net pwd
  | Field 4 -> update_text net pwd
  | Quit -> quit_check_outer net pwd update_loop
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'quit' or the number of field you want to update.");
    inner_profile_loop net pwd

and

  update_feedback net pwd data =
  match update_profile net pwd data with
  | true ->
    print_endline ("\nProfile updated.");
    outer_profile_loop net pwd
  | _ ->
    print_endline ("\nError. Please try again.");
    outer_profile_loop net pwd

and

  update_loc net pwd =
  print_endline ("\nEnter '0' to set location to North Campus, '1' to set location to West Campus, or '2' to set location to Collegetown. Enter 'quit' to quit. ");
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

  update_classes net pwd =
  match get_student net pwd with
  | None ->
    print_endline ("\nError in finding profile. Please try again.");
    outer_profile_loop net pwd
  | Some s ->
    print_endline ("\nEnter the 4-digit CS class number that you want to add or remove, or 'quit' to quit. ");
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

  update_sched net pwd lst acc =
  match lst with
  | [] -> let lst_rev = List.rev acc in
    begin
      match List.filter (fun x -> x <> "yes" && x <> "no")lst_rev |> List.length with
      | i when i <> 0 ->
        print_endline ("\nError: some answers were not 'yes' or 'no'. Try again.\n");
        outer_profile_loop net pwd
      | _ ->
        let map_func = List.map (fun x -> if x = "yes" then true else false) in
        update_feedback net pwd [Schedule (map_func lst_rev)]
    end
  | h::t ->
    print_endline ("\nAre you usually free "^h^"?");
    print_string ("\n> ");
    let resp = read_line() in
    update_sched net pwd t (resp::acc)

and

  update_hours net pwd =
  print_endline ("\nEnter the integer number of hours you're willing to spend on this project, or 'quit' to quit.");
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

  update_text net pwd =
  print_endline ("\nEnter your bio: ");
  print_string ("\n");
  let txt = read_line () in
  update_feedback net pwd [Text txt]

and

  quit_check_outer net pwd r_func =
  print_endline ("\nAre you sure you want to quit? Enter 'yes' or 'no'");
  quit_check_inner net pwd r_func

and

  quit_check_inner net pwd r_func =
  print_string ("\n> ");
  match parse_command (read_line ()) with
  | Confirm Yes -> raise QuitREPL
  | Confirm No -> r_func net pwd
  | _ ->
    print_endline ("\nUnrecognized command. Enter 'yes' or 'no'.");
    quit_check_inner net pwd r_func

and

  outer_swipe_loop pl net pwd s_results =
  match StudentPool.peek pl with
  | Some s ->
    print_endline ("\n"^(snd s |> printable_student));
    print_endline ("\nenter 'L' to swipe left (dislike), 'R' to swipe right (like), or 'quit' to quit.");
    inner_swipe_loop pl net pwd s_results s
  | None ->
    print_endline ("\nYou have finished swiping. Type 'save' to save your swipes, or 'quit' to quit.");
    save_loop pl net pwd s_results

and

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

  inner_swipe_loop pl net pwd s_results compat =
  print_string("\n> ");
  match parse_command (read_line ()) with
  | Swipe Left ->
    let new_results = SwipeStudentPool.swipe s_results (snd compat) (Some(-1.0*.(fst compat))) in
    let new_pool = StudentPool.pop pl in
    outer_swipe_loop new_pool net pwd new_results
  | Swipe Right ->
    let new_results = SwipeStudentPool.swipe s_results (snd compat) (Some(fst compat)) in
    let new_pool = StudentPool.pop pl in
    outer_swipe_loop new_pool net pwd new_results
  | Quit ->
    print_endline ("\nare you sure you want to quit? You will lose all of your swipe data. Enter 'yes' or 'no'.");
    quit_loop_swipe pl net pwd s_results
  | _ ->
    print_endline ("\nUnrecognized command. Please enter 'L', 'R', or 'quit'.");
    inner_swipe_loop pl net pwd s_results compat

and

  save_loop pl net pwd s_results =
  print_string("\n> ");
  match parse_command (read_line ()) with
  | Save ->
    begin
      match write_swipes net pwd s_results with
      | true -> print_endline ("\nSwipes saved.");
      | _ ->
        print_endline ("\nSave unsuccessful. Enter 'save' to try again, or 'quit' to quit.");
        save_loop pl net pwd s_results
    end
  | Quit ->
    print_endline ("\nare you sure you want to quit? You will lose all of your swipe data. Enter 'yes' or 'no'");
    quit_loop_swipe pl net pwd s_results
  | _ ->
    print_endline ("\nUnrecognized command. Please enter 'save' or 'quit'.");
    save_loop pl net pwd s_results

let main () =
  print_endline("\nWelcome to OLoml!  Let's find you the love of your CS life. AKA your only life.");
  print_endline("\nEnter your credentials to get started, or 'quit' to quit:");
  try get_authed () with
  | QuitREPL -> print_endline ("Quitting")
  (* outer_swipe_loop test_student_pool "bb123" "yo" (SwipeStudentPool.init_swipes test_students) *)

let () = main ()
