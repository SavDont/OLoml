(* [authenticate user pwd] returns [true] iff user and pwd are a valid username
 * password combination in the database and [false] otherwise *)
val authenticate : string -> string -> bool

(* [student_get] is the callback that handles all student related get requests.
 * requires: 
 * as part of [req.headers] we need
 *  key [netid] that specifies the netid of the student information is being
 *   requested about
 *  key [password] that specifies the password associated with netid in the 
 *   database, used to authenticate the request 
 *  key [info] that specifies the type of info requested. 
 *   The value of [info] can be student or match
 *   if [info] is student, retrieve an individual student row from the database
 *   if [info] is match, retrieve an individual students match from the database
 * returns:
 * HttpServer.response resp
 *  resp.headers should be the default plain text Cohttp Header
 *  resp.status should be `OK iff netid/password combination was authenticated
 *   and valid data was retrieved from the database
 *  resp.status should be `No_response iff netid/password authenticated but no
 *   valid data was retrieved
 *  resp.status should be `Unauthorized iff netid/password did not authenticate
 * if resp.status is `OK, resp.res_body should be a text representation of the 
 *  database data in the following form:
 *   k1 : v1
 *   k2 : v2
 *     ...
 *   kn : vn
 * if resp.status is `Unauthorized, res.res_body should be 
 *  "Incorrect netid or password"
 * if resp.status is `No_response, res.res_body should be
 *  "No valid data was retrieved. Try again later"
 *)
val student_get : HttpServer.request -> HttpServer.response

val student_post : HttpServer.request -> HttpServer.response

val admin_get : HttpServer.request -> HttpServer.response

val admin_post : HttpServer.request -> HttpServer.response