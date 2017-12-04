open HttpServer
open Cohttp
open Db
open Backend_lib
open Yojson.Basic

(* [current_period] is a string representing the current period.
 * returns:
 *  "update" if the current period is the update period
 *  "swipe" if the current period is the swipe period
 *  "match" if the current period is the match period
 *  "null" if the periods have not been initialize yet *)
let current_period () =
  if not (check_period_set ()) then (print_endline("\nissa null"); "null")
  else
    let period_jsn = get_period_query () |> from_string in
    let upd = period_jsn |> Util.member "update" |> to_string |> float_of_string in
    let swi = period_jsn |> Util.member "swipe" |> to_string |> float_of_string in
    let mat = period_jsn |> Util.member "match" |> to_string |> float_of_string in
    let today = Unix.time () |> Unix.localtime |> Unix.mktime |> fst in
    if today < upd then "null"
    else if today > upd && today < swi then "update"
    else if today > swi && today < mat then "swipe"
    else "match"

let get_some = function
  | Some x -> x
  | _ -> failwith "Cannot get some of none"

(* helper to make http responses with default headers *)
let make_resp status res_body =
  let headers = Header.init_with "Content-Type" "text/plain" in
  {headers; status; res_body}

(* returns true if every element in the list is a member of headers *)
let rec check_headers headers keys =
  match keys with
  | [] -> true
  | h::t -> if Header.mem headers h then check_headers headers t else false

(* login helpers *)
let generic_login headers password =
  let username = Header.get headers "username" |> get_some in
  check_cred_query username password

let admin_login headers password =
  check_cred_query "admin" password

let student_login headers password =
  let netID = Header.get headers "netid" |> get_some in
  check_cred_query netID password

let login_wrapper headers username_f =
  let password = Header.get headers "password" |> get_some in
  username_f headers password

(* make a callback based on a generic template *)
let create_callback (req:HttpServer.request) header_keys login_f body =
  if check_headers req.headers header_keys then
    match login_wrapper req.headers login_f with
      | true ->
        body req
      | false ->
        make_resp `Unauthorized "Incorrect password"
  else
    make_resp `No_response "No valid response. Try again later"

(* requests *)
let test_post req =
  let status = `OK in
  let res_body = "Hello " ^ req.req_body ^ "" in
  make_resp status res_body

let test_get req =
  let status = `OK in
  let res_body = "Hello World!" in
  make_resp status res_body

let credentials_post (req:HttpServer.request) =
  let body _ = make_resp `OK "" in
  create_callback req ["username"; "password"] generic_login body

let period_get (req:HttpServer.request) =
  let body _ = make_resp `OK (current_period ()) in
  create_callback req ["username"; "password"] generic_login body

let period_post (req:HttpServer.request) =
  let body (req:HttpServer.request) =
    begin match (check_period_set()) with
      | false ->
        set_period_query req.req_body;
        make_resp `OK "Success"
      | true ->
        make_resp `Unauthorized "Period already set"
    end in
  create_callback req ["password";] admin_login body

let swipes_get (req:HttpServer.request) =
  let body (req:HttpServer.request) =
    begin match current_period () with
      | "swipe"
      | "match" ->
        make_resp `OK (get_swipes());
      | _ ->
        make_resp `Unauthorized "Incorrect period"
    end in
  create_callback req ["password";] admin_login body

let swipes_post (req:HttpServer.request) =
  let body (req:HttpServer.request) =
    begin match current_period () with
      | "swipe" ->
        set_swipes req.req_body;
        make_resp `OK "Success"
      | _ ->
        make_resp `Unauthorized "Incorrect period"
    end in
  create_callback req ["netid"; "password";] student_login body

let matches_post (req:HttpServer.request) =
  let body (req:HttpServer.request) =
    begin match current_period () with
      | "match" ->
        post_matches_query req.req_body;
        make_resp `OK "Success"
      | _ ->
        make_resp `Unauthorized "Incorrect period"
    end in
  create_callback req ["password";] admin_login body

let student_get (req:HttpServer.request) =
  let body (req:HttpServer.request) =
    begin match Header.get req.headers "scope" |> get_some with
      | "student" ->
        let res_body =
          get_student_query (Header.get req.headers "netid" |> get_some) in
        make_resp `OK res_body
      | "match" ->
        let res_body =
          get_stu_match_query (Header.get req.headers "netid" |> get_some) in
        make_resp `OK res_body
      | _ ->
        make_resp `No_response "No valid response. Try again later"
    end in
  create_callback req ["netid"; "password"; "scope";] student_login body

let student_post (req:HttpServer.request) =
  let body (req:HttpServer.request) = change_stu_query
                 (Header.get req.headers "netid" |> get_some) req.req_body;
                 make_resp `OK "Success" in
  create_callback req ["netid"; "password"] student_login body

let admin_post (req:HttpServer.request) =
  let body (req:HttpServer.request) =
    admin_change_query req.req_body; make_resp `OK "Success" in
  create_callback req ["password";] admin_login body

let admin_get (req:HttpServer.request) =
  let body (req:HttpServer.request) =
    begin match Header.get req.headers "scope" with
          | _ ->
            let resp_body = get_all_students () in
            make_resp `OK resp_body
    end in
  create_callback req ["password"; "scope";] admin_login body


let admin_delete (req:HttpServer.request) =
  let body (req:HttpServer.request) =
    begin match Header.get req.headers "scope" |> get_some with
      | "class" ->
        reset_class ();
        make_resp `OK "Success"
      | "subset" ->
        delete_students req.req_body;
        make_resp `OK "Success"
      | _ -> make_resp `No_response "No valid response. Try again later"
    end in
  create_callback req ["password"; "scope";] admin_login body
