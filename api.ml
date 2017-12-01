open HttpServer
open Cohttp

let test_post req = 
  let headers = Header.init_with "Content-Type" "text/plain" in
  let status = `OK in
  let res_body = "Hello " ^ req.req_body ^ "" in
  {headers; status; res_body}

let test_get req = 
  let headers = Header.init_with "Content-Type" "text/plain" in
  let status = `OK in
  let res_body = "Hello World!" in
  {headers; status; res_body}

(* [are_valid_credentials username password] returns [true] iff username and
 * password are a valid username password combination in the database and 
 * [false] otherwise *)
let are_valid_credentials user password =
  failwith "Unimplemented"

(* [current_period] is a string representing the current period.
 * returns:
 *  "update" if the current period is the update period
 *  "swipe" if the current period is the swipe period
 *  "match" if the current period is the match period
 *  "null" if the periods have not been initialize yet *)
let current_period () =
  failwith "Unimplemented"

let credentials_post req =
  failwith "Unimplemented"

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

