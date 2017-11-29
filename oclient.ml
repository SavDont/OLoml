open Lwt
open Cohttp
open Cohttp_lwt_unix

(* helpers to abstract Cohttp's data types *)
(* [make_headers bindings] a Cohttp.Header.t with the key value bindings in 
 * [bindings]
 * requies: [binding] is a string*string association list that represents a 
 * key value pair as (key, value) *)
let make_headers bindings = 
  Header.add_list (Header.init ()) bindings

(* [make_uri endpoint] is a Uri.t representing a given endpoint at the base_url 
 * requires: [endpoint] is a valid endpoint on the base_url *)
let make_uri base_url endpoint =
  base_url ^ endpoint |> Uri.of_string

(* [make_body reqBody] is the Cohttp_lwt.Body.t formed from reqBody
 * requires: [reqBody] is a valid string request body *)
let make_body reqBody = 
  Cohttp_lwt.Body.of_string reqBody

(* helpers to abstract Cohttp's asynchronous components *)
let handle_resp = fun (resp, body) ->
  body |> Cohttp_lwt.Body.to_string >|= fun body -> ();
  (resp |> Response.status, body)

(* helper to make get requests *)
let get_req ?ctx ?headers uri = 
  let lwt_resp = Client.get ?ctx ?headers uri >>= handle_resp in
  Lwt_main.run lwt_resp

(* helper to make post requests *)
let post_req ?ctx ?body ?chunked ?headers uri = 
  let lwt_resp =
    Client.post ?ctx ?body ?chunked ?headers uri >>= handle_resp in
  Lwt_main.run lwt_resp

(* helper to make delete requests *)
let delete_req ?ctx ?body ?chunked ?headers uri = 
  let lwt_resp =
    Client.delete ?ctx ?body ?chunked ?headers uri >>= handle_resp in
  Lwt_main.run lwt_resp