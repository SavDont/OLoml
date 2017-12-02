open HttpServer
open Cohttp
open Db
open Backend_lib

(* helper to make http responses with default headers *)
let make_resp status res_body =
  let headers = Header.init_with "Content-Type" "text/plain" in
  {headers; status; res_body}

(* returns true if every element in the list is a member of headers *)
let rec check_headers_mem headers keys =
  match keys with
  | [] -> true
  | h::t -> if Header.mem headers h then check_headers_mem headers t else false

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

(* [are_valid_credentials username password] returns [true] iff username and
 * password are a valid username password combination in the database and 
 * [false] otherwise *)
let are_valid_credentials user password =
  failwith "Unimplemented"
  (* check_cred_query creds_tbl user password *)

(* [current_period] is a string representing the current period.
 * returns:
 *  "update" if the current period is the update period
 *  "swipe" if the current period is the swipe period
 *  "match" if the current period is the match period
 *  "null" if the periods have not been initialize yet *)
let current_period () =
(*   if not (check_period_set periods_tbl) then "null"
  else get_period_query periods_tbl *)
  failwith "Unimplemented"

let credentials_post (req:HttpServer.request) =
  failwith "Unimplemented"
(*   if check_headers_mem req.headers ["username"; "password"] then
    let username = Header.get req.headers "username" |> get_some in
    let password = Header.get req.headers "password" |> get_some in
    let res_body =
      (check_cred_query creds_tbl username password) |> string_of_bool in
    make_resp `OK res_body
  else
    make_resp `Unauthorized "" *)


let period_get req =
  failwith "Unimplemented"

let period_post req =
  failwith "Unimplemented"

let swipes_get req =
  failwith "Unimplemented"

let swipes_post req =
  failwith "Unimplemeted"

let matches_post req =
  failwith "Unimplemented"

let student_get req = 
  failwith "Unimplemented"

let student_post req =
  failwith "Unimplemented"

let admin_get req =
  failwith "Unimplemented"

let admin_post req = 
  failwith "Unimplemented"

let admin_delete req = 
  failwith "Unimplemented"

