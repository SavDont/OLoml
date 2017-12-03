open HttpServer
open Cohttp
open Db
open Backend_lib

(* helper to make http responses with default headers *)
let make_resp status res_body =
  let headers = Header.init_with "Content-Type" "text/plain" in
  {headers; status; res_body}

(* returns true if every element in the list is a member of headers *)
let rec check_headers headers keys =
  match keys with
  | [] -> true
  | h::t -> if Header.mem headers h then check_headers headers t else false

let get_some = function
  | Some x -> x
  | _ -> failwith "Cannot get some of none"

let test_post req = 
  let status = `OK in
  let res_body = "Hello " ^ req.req_body ^ "" in
  make_resp status res_body

let test_get req = 
  let status = `OK in
  let res_body = "Hello World!" in
  make_resp status res_body

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

(* [current_period] is a string representing the current period.
 * returns:
 *  "update" if the current period is the update period
 *  "swipe" if the current period is the swipe period
 *  "match" if the current period is the match period
 *  "null" if the periods have not been initialize yet *)
let current_period () =
  if not check_period_set then "null"
  else get_period_query


(* requests *)
let credentials_post (req:HttpServer.request) =
  if check_headers req.headers ["username"; "password"] then
    if login_wrapper req.headers generic_login then
      make_resp `OK ""
    else
      make_resp `Unauthorized ""
  else
    make_resp `No_response "No valid response. Try again later"

let period_get (req:HttpServer.request) =
  if check_headers req.headers ["username"; "password"] then
    if login_wrapper req.headers generic_login then
      make_resp `OK get_period_query
    else
      make_resp `Unauthorized ""
  else
    make_resp `No_response "No valid response. Try again later"

let period_post (req:HttpServer.request) =
  if check_headers req.headers ["password";] then
    if login_wrapper req.headers admin_login then
      match check_period_set with
      | true -> 
        set_period_query req.req_body;
        make_resp `OK "Success"
      | false ->
        make_resp `Unauthorized "Period already set"
    else
      make_resp `Unauthorized "Incorrect password"
  else
    make_resp `No_response "No valid response. Try again later"

let swipes_get (req:HttpServer.request) =
  if check_headers req.headers ["password";] then
    if login_wrapper req.headers admin_login then
      match current_period () with
      | "swipe"
      | "match" -> 
        failwith "TACO Need get swipes query"
        (* make_resp `OK resp_body *)
      | _ ->
        make_resp `Unauthorized "Incorrect period"
    else
      make_resp `Unauthorized "Incorrect password"
  else
    make_resp `No_response "No valid response. Try again later"

let swipes_post (req:HttpServer.request) =
  if check_headers req.headers ["netid"; "password";] then
    if login_wrapper req.headers student_login then
      match current_period () with
      | "swipe" -> 
        failwith "TACO Need swipes post"
        (* make_resp `OK "Success" *)
      | _ ->
        make_resp `Unauthorized "Incorrect period"
    else
      make_resp `Unauthorized "Incorrect password"
  else
    make_resp `No_response "No valid response. Try again later"

let matches_post (req:HttpServer.request) =
  if check_headers req.headers ["password";] then
    if login_wrapper req.headers admin_login then
      match current_period () with
      | "match" -> 
        failwith "TACO Need matches post"
        (* make_resp `OK "Success" *)
      | _ ->
        make_resp `Unauthorized "Incorrect period"
    else
      make_resp `Unauthorized "Incorrect password"
  else
    make_resp `No_response "No valid response. Try again later"

let student_get (req:HttpServer.request) = 
  if check_headers req.headers ["netid"; "password"; "scope";] then
    if login_wrapper req.headers student_login then
      match Header.get req.headers "scope" |> get_some with
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
    else
      make_resp `Unauthorized "Incorrect password"
  else
    make_resp `No_response "No valid response. Try again later"

let student_post (req:HttpServer.request) =
  if check_headers req.headers ["netid"; "password";] then
    match login_wrapper req.headers student_login with
      | true ->
          change_stu_query
            (Header.get req.headers "netid" |> get_some) req.req_body;
          make_resp `OK "Success"
      | false ->
        make_resp `Unauthorized "Incorrect password"
  else
    make_resp `No_response "No valid response. Try again later"

let admin_get (req:HttpServer.request) =
  if check_headers req.headers ["password"; "scope";] then
    match login_wrapper req.headers admin_login with
      | true ->
        begin match Header.get req.headers "scope" with
          | _ ->
            failwith "TACO Need admin get endpoint"
        end
      | false ->
        make_resp `Unauthorized "Incorrect password"
  else
    make_resp `No_response "No valid response. Try again later"

let admin_post (req:HttpServer.request) = 
  if check_headers req.headers ["password";] then
    match login_wrapper req.headers admin_login with
      | true ->
        admin_change_query req.req_body;
        make_resp `OK "Success"
      | false ->
        make_resp `Unauthorized "Incorrect password"
  else
    make_resp `No_response "No valid response. Try again later"

let admin_delete (req:HttpServer.request) = 
  if check_headers req.headers ["password"; "scope";] then
    match login_wrapper req.headers admin_login with
      | true ->
        begin match Header.get req.headers "scope" |> get_some with
          | "class" ->
            reset_class;
            make_resp `OK "Success"
          | _ ->
            failwith "TACO need admin delete partial"
        end
      | false ->
        make_resp `Unauthorized "Incorrect password"
  else
    make_resp `No_response "No valid response. Try again later"

