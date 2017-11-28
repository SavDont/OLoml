open HttpServer
open Cohttp

(* let test req = 
  let headers = Header.init_with "Content-Type" "text/plain" in
  let status = `OK in
  let res_body = "Hello " ^ req.req_body ^ "!" in
  {headers; status; res_body} *)

let are_valid_credentials user pwd =
  failwith "Unimplemented"

let current_period () =
  failwith "Unimplemented"

let credentials_post req =
  failwith "Unimplemented"

let period_get req =
  failwith "Unimplemented"

let period_post req =
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

