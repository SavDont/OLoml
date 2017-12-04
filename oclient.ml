open Lwt
open Cohttp
open Cohttp_lwt_unix

let make_headers bindings = 
  Header.add_list (Header.init ()) bindings

let make_uri base_url endpoint =
  base_url ^ endpoint |> Uri.of_string

let make_body reqBody = 
  Cohttp_lwt.Body.of_string reqBody

(* helpers to abstract Cohttp's asynchronous components *)
let handle_resp = fun (resp, body) ->
  body |> Cohttp_lwt.Body.to_string >|= fun body -> ();
  (resp |> Response.status, body)

(* helper to make get requests *)
let get_req ?ctx ?headers uri = 
  try 
    let lwt_resp = Client.get ?ctx ?headers uri >>= handle_resp in
    Lwt_main.run lwt_resp with
  | _ -> (`No_response, "No valid response. Try again later")

(* helper to make post requests *)
let post_req ?ctx ?body ?chunked ?headers uri = 
  try
    let lwt_resp =
      Client.post ?ctx ?body ?chunked ?headers uri >>= handle_resp in
    Lwt_main.run lwt_resp with
  | _ -> (`No_response, "No valid response. Try again later")

(* helper to make delete requests *)
let delete_req ?ctx ?body ?chunked ?headers uri = 
  try
    let lwt_resp =
      Client.delete ?ctx ?body ?chunked ?headers uri >>= handle_resp in
    Lwt_main.run lwt_resp with
  | _ -> (`No_response, "No valid response. Try again later")
