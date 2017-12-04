open Oclient
open Backend_lib

let test_get () = 
  let headers = make_headers [] in
  let uri = make_uri base_url test_endpoint in
  get_req ?headers:(Some headers) uri

let test_post name =
  let headers = make_headers [] in
  let uri = make_uri base_url test_endpoint in
  let body = make_body name in
  post_req ?headers:(Some headers) ?body:(Some body) uri

(* credential client *)
let credentials_post username password =
  let headers = make_headers [("username",username); ("password",password)] in
  let uri = make_uri base_url credentials_endpoint in
  post_req ?headers:(Some headers) uri

(* period clients *)
let period_get username password =
  let headers = make_headers [("username",username); ("password",password)] in
  let uri = make_uri base_url period_endpoint in
  get_req ?headers:(Some headers) uri

let period_post password reqBody =
  let headers = make_headers [("password",password)] in
  let body = make_body reqBody in
  let uri = make_uri base_url period_endpoint in
  post_req ?headers:(Some headers) ?body:(Some body) uri

(* swipes clients *)
let swipes_get password =
  let headers = make_headers [("password",password)] in
  let uri = make_uri base_url swipes_endpoint in
  get_req ?headers:(Some headers) uri

let swipes_post netID password reqBody =
  let headers = make_headers [("password",password)] in
  let body = make_body reqBody in
  let uri = make_uri base_url swipes_endpoint in
  post_req ?headers:(Some headers) ?body:(Some body) uri

(* matches client *)
let matches_post password reqBody =
  let headers = make_headers [("password",password)] in
  let body = make_body reqBody in
  let uri = make_uri base_url matches_endpoint in
  post_req ?headers:(Some headers) ?body:(Some body) uri

(* student clients *)
let student_get netID password scope =
  let headers =
    make_headers [("netid",netID); ("password",password); ("scope", scope)] in
  let uri = make_uri base_url student_endpoint in
  get_req ?headers:(Some headers) uri

let student_post netID password reqBody =
  let headers = make_headers [("netid",netID); ("password",password)] in
  let body = make_body reqBody in
  let uri = make_uri base_url student_endpoint in
  post_req ?headers:(Some headers) ?body:(Some body) uri

(* admin clients *)
let admin_get ?netID:(n="") password scope =
  let headers =
    make_headers [("password",password); ("scope",scope); ("netid",n)] in
  let uri = make_uri base_url admin_endpoint in
  get_req ?headers:(Some headers) uri

let admin_post password reqBody =
  let headers = make_headers [("password",password)] in
  let body = make_body reqBody in
  let uri = make_uri base_url admin_endpoint in
  post_req ?headers:(Some headers) ?body:(Some body) uri

let admin_delete password scope reqBody =
  let headers = make_headers [("password",password); ("scope",scope)] in
  let body = make_body reqBody in
  let uri = make_uri base_url admin_endpoint in
  delete_req ?headers:(Some headers) ?body:(Some body) uri
