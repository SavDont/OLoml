open Cohttp

(* [credentials_post username pwd] returns a tuple containing the response 
 * status and response body received after a POST request to the credentials api
 * endpoint. 
 * requires: 
 * [username] is a valid username of a user in the database
 * [pwd] is the password associated with that user
 * side effect: makes a POST request to the credentials api endpoint *)
val credentials_post : string -> string -> Code.status_code*string

(* [period_post username pwd] returns a tuple containing the response 
 * status and response body received after a GET request to the period api
 * endpoint. 
 * requires: 
 * [username] is a valid username of a user in the database
 * [pwd] is the password associated with that user
 * side effect: makes a GET request to the period api endpoint *)
val period_get : string -> string -> Code.status_code*string

(* [period_post pwd reqBody] returns a tuple containing the response 
 * status and response body received after a POST request to the period api
 * endpoint. 
 * requires: 
 * [pwd] is the admin password
 * [reqBody] is a Yojson.Basic.json containing the dates for the update, swipe,
 * and match periods
 * [reqBody] must be formatted such that calling Yojson.Basic.to_string on it
 * will result in a string json as specified in the api documentation
 * side effect: makes a POST request to the period api endpoint *)
val period_post : string -> Yojson.Basic.json -> Code.status_code*string

(* [student_get netID pwd scope] returns a tuple containing the response status 
 * and response body received after a GET request to the student api endpoint. 
 * requires: 
 * [netID] is a valid netid of a student in the database
 * [pwd] is the password associated with the student whose netid is netID
 * [scope] is either "student" or "match"
 * side effect: makes a GET request to the student api endpoint *)
val student_get : Student.netid -> string -> string -> Code.status_code*string

(* [student_post netID pwd reqBody] returns a tuple containing the response 
 * status and response body received after a POST request to the student api 
 * endpoint. 
 * requires:
 * [netID] is a valid netid of a student in the database
 * [pwd] is the password associated with the student with netid netID
 * [reqBody] is a Yojson.Basic.json containing information to be updated for the
 * student with netid netID
 * [reqBody] must be formatted such that calling Yojson.Basic.to_string on it
 * will result in a string json as specified in the api documentation
 * side effect: makes a POST request to the student api endpoint *)
val student_post : 
  Student.netid -> string -> Yojson.Basic.json -> Code.status_code*string

(* [admin_get pwd scope ?netID] returns a tuple containing the response status 
 * and response body received after a GET request to the admin api endpoint. 
 * requires: 
 * [pwd] is the admin password
 * [scope] is one of the following: "student_indiv", "swipe_indiv", 
 * "match_indiv", "student_all", "swipe_all", "match_all"
 * [netID] is an optional string argument. [netID] should be a valid netid of 
 * a student in the database) if [info] is student_indiv, swipe_indiv, or
 * match_indiv. Otherwise, it is set to the empty string and is unused
 * side effect: makes a GET request to the admin api endpoint *)
val admin_get : 
  string -> string -> ?netID:Student.netid -> Code.status_code*string

(* [admin_post pwd reqBody] returns a tuple containing the response 
 * status and response body received after a POST request to the admin api 
 * endpoint. 
 * requires:
 * [pwd] is the admin password
 * [reqBody] is a Yojson.Basic.json containing information to be created/updated
 * for any number of students
 * [reqBody] must be formatted such that calling Yojson.Basic.to_string on it
 * will result in a string json as specified in the api documentation
 * side effect: makes a POST request to the admin api endpoint *)
val admin_post : string -> Yojson.Basic.json -> Code.status_code*string

(* [admin_delete pwd scope reqBody] returns a tuple containing the response 
 * status and response body received after a DELETE request to the admin api 
 * endpoint. 
 * requires:
 * [pwd] is the admin password
 * [scope] is either "class" or "subset"
 * [reqBody] is a Yojson.Basic.json detailing which students to delete
 * [reqBody] must be formatted such that calling Yojson.Basic.to_string on it
 * will result in a string json as specified in the api documentation
 * side effect: makes a DELETE request to the admin api endpoint *)
val admin_delete :
  string -> string -> Yojson.Basic.json -> Code.status_code*string
