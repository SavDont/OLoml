open HttpServer
open Cohttp

let authenticate user pwd =
  failwith "Unimplemented"

(* let test req = 
  let headers = Header.init_with "Content-Type" "text/plain" in
  let status = `OK in
  let res_body = "Hello " ^ req.req_body ^ "!" in
  {headers; status; res_body} *)

let student_get req = 
  failwith "Unimplemented"

let student_post req =
  failwith "Unimplemented"

let admin_get req =
  failwith "Unimplemented"

let admin_post req = 
  failwith "Unimplemented"

let _ = 
  HttpServer.add_route (`GET, "/student") student_get;
  HttpServer.add_route (`POST, "/student") student_post;
  HttpServer.add_route (`GET, "/admin") admin_get;
  HttpServer.add_route (`POST, "/admin") admin_post;
  HttpServer.run ~port:8000 ()
