(* helpers to abstract Cohttp's data types *)
(* [make_headers bindings] a Cohttp.Header.t with the key value bindings in 
 * [bindings]
 * requies: [binding] is a string*string association list that represents a 
 * key value pair as (key, value) *)
val make_headers : (string * string) list -> Cohttp.Header.t

(* [make_uri endpoint] is a Uri.t representing a given endpoint at the base_url 
 * requires: [endpoint] is a valid endpoint on the base_url *)
val make_uri : string -> string -> Uri.t

(* [make_body reqBody] is the Cohttp_lwt.Body.t formed from reqBody
 * requires: [reqBody] is a valid string request body *)
val make_body : string -> Cohttp_lwt_body.t

(* [get_req ?ctx ?headers uri] makes a get request to a given [uri] with
 * optional ctx and headers as parameters
 * [ctx] is a Cohttp_lwt_unix.Client.ctx
 * [headers] is a Cohttp.Header.t
 * [uri] is a Uri.t
 * These paremeters are as defined in cohttp-lwt-unix.get *)
val get_req : 
  ?ctx:Cohttp_lwt_unix.Client.ctx -> ?headers:Cohttp.Header.t -> Uri.t -> 
  Cohttp.Code.status_code * string

(* [post_req ?ctx ?body ?chunked ?headers uri] makes a post request to a given
 * [uri] with optional ctx, body, chunked, and headers passed as parameters
 * [ctx] is a Cohttp_lwt_unix.Client.ctx
 * [body] is a Cohttp_lwt.Body t
 * [chunked] is a boolean
 * [headers] is a Cohttp.Header.t
 * [uri] is a Uri.t
 * These paremeters are as defined in cohttp-lwt-unix.client.post *)
val post_req : 
  ?ctx:Cohttp_lwt_unix.Client.ctx -> ?body:Cohttp_lwt_body.t -> 
  ?chunked:bool -> ?headers:Cohttp.Header.t -> Uri.t ->
  Cohttp.Code.status_code * string

(* [delete_req ?ctx ?body ?chunked ?headers uri] makes a delete request to a
 * given [uri] with optional ctx, body, chunked, and headers passed as 
 * parameters
 * [ctx] is a Cohttp_lwt_unix.Client.ctx
 * [body] is a Cohttp_lwt.Body t
 * [chunked] is a boolean
 * [headers] is a Cohttp.Header.t
 * [uri] is a Uri.t
 * These paremeters are as defined in cohttp-lwt-unix.client.delete *)
val delete_req : 
  ?ctx:Cohttp_lwt_unix.Client.ctx -> ?body:Cohttp_lwt_body.t ->
  ?chunked:bool -> ?headers:Cohttp.Header.t -> Uri.t ->
  Cohttp.Code.status_code * string
