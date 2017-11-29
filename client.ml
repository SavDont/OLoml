open Lwt
open Cohttp
open Cohttp_lwt_unix

let base_url = "localhost:8000/"

let handle_resp = fun (resp, body) ->
  body |> Cohttp_lwt.Body.to_string >|= fun body -> ();
  (resp |> Response.status, body)

let get_req ?ctx ?headers uri = 
  let lwt_resp = Client.get ?ctx ?headers uri >>= handle_resp in
  Lwt_main.run lwt_resp

let post_req ?ctx ?body ?chunked ?headers uri = 
  let lwt_resp =
    Client.post ?ctx ?body ?chunked ?headers uri >>= handle_resp in
  Lwt_main.run lwt_resp

let delete_req ?ctx ?body ?chunked ?headers uri = 
  let lwt_resp =
    Client.delete ?ctx ?body ?chunked ?headers uri >>= handle_resp in
  Lwt_main.run lwt_resp

let credentials_post username pwd =
  let headers = 
    [("username",username); ("password",pwd)] |> 
    Header.add_list (Header.init ()) in
  let body = Cohttp_lwt.Body.of_string "bubba hubba" in
  let uri = base_url ^ "credentials" |> Uri.of_string in
  post_req ?headers:(Some headers) ?body:(Some body) uri

let period_get username pwd =
  failwith "Unimplemented"

let period_post pwd reqBody = 
  failwith "Unimplemented"

let student_get netID pwd scope =
  failwith "Unimplemented"

let student_post netID pwd reqBody =
  failwith "Unimplemented"

let admin_get pwd scope ?netID:(n="") =
  failwith "Unimplemented"

let admin_post pwd reqBody =
  failwith "Unimplemented"

let admin_delete pwd scope reqBody =
  failwith "Unimplemented"

