open Cohttp

(* [credentials_post username password] returns a tuple containing the response
 * status and response body received after a POST request to the credentials api
 * endpoint.
 * requires:
 * [username] is a valid username of a user in the database
 * [password] is the password associated with that user
 * side effect: makes a POST request to the credentials api endpoint *)
val credentials_post : string -> string -> Code.status_code*string

(* [period_post username password] returns a tuple containing the response
 * status and response body received after a GET request to the period api
 * endpoint.
 * requires:
 * [username] is a valid username of a user in the database
 * [password] is the password associated with that user
 * side effect: makes a GET request to the period api endpoint *)
val period_get : string -> string -> Code.status_code*string

(* [period_post password reqBody] returns a tuple containing the response
 * status and response body received after a POST request to the period api
 * endpoint.
 * requires:
 * [password] is the admin password
 * [reqBody] is a string json containing the dates for the update, swipe,
 * and match periods
 * [reqBody] must be formatted in accordance with the api documentation
 * side effect: makes a POST request to the period api endpoint *)
val period_post : string -> string -> Code.status_code*string

(* [matches_post password reqBody] returns a tuple containing the response
 * status and response body received after a POST request to the match api
 * endpoint.
 * requires:
 * [password] is the admin password
 * [reqBody] is a string json containing the matches for the class
 * [reqBody] must be formatted in accordance with the api documentation
 * side effect: makes a POST request to the match api endpoint *)
val matches_post : string -> string -> Code.status_code*string

(* [swipes_get password] returns a tuple containing the response status
 * and response body received after a GET request to the swipes api endpoint.
 * requires:
 * [password] is the admin password
 * side effect: makes a GET request to the swipes api endpoint *)
val swipes_get : string -> Code.status_code*string

(* [swipes_post netID password reqBody] returns a tuple containing the response
 * status and response body received after a POST request to the swipes api
 * endpoint.
 * requires:
 * [netID] is a valid netid of a student in the database
 * [password] is the password associated with the student whose netid is netID
 * [reqBody] is a string json containing information on the students swipes
 * [reqBody] must be formatted in accordance with the api documentation
 * side effect: makes a POST request to the swipes api endpoint *)
val swipes_post : string -> string -> string -> Code.status_code*string

(* [student_get netID password scope] returns a tuple containing the response
 * status
 * and response body received after a GET request to the student api endpoint.
 * requires:
 * [netID] is a valid netid of a student in the database
 * [password] is the password associated with the student whose netid is netID
 * [scope] is either "student" or "match"
 * side effect: makes a GET request to the student api endpoint *)
val student_get : string -> string -> string -> Code.status_code*string

(* [student_post netID password reqBody] returns a tuple containing the response
 * status and response body received after a POST request to the student api
 * endpoint.
 * requires:
 * [netID] is a valid netid of a student in the database
 * [password] is the password associated with the student with netid netID
 * [reqBody] is a string json containing information to be updated for the
 * student with netid netID
 * [reqBody] must be formatted in accordance with the api documentation
 * side effect: makes a POST request to the student api endpoint *)
val student_post :
  string -> string -> string -> Code.status_code*string

(* [admin_get password scope ?netID] returns a tuple containing the response
 * status
 * and response body received after a GET request to the admin api endpoint.
 * requires:
 * [password] is the admin password
 * [scope] is one of the following: "student_indiv", "swipe_indiv",
 * "match_indiv", "student_all", "swipe_all", "match_all"
 * [netID] is an optional string argument. [netID] should be a valid netid of
 * a student in the database) if [info] is student_indiv, swipe_indiv, or
 * match_indiv. Otherwise, it is set to the empty string and is unused
 * side effect: makes a GET request to the admin api endpoint *)
val admin_get :
  ?netID:string -> string -> string -> Code.status_code*string

(* [admin_post password reqBody] returns a tuple containing the response 
 * status and response body received after a POST request to the admin api
 * endpoint.
 * requires:
 * [password] is the admin password
 * [reqBody] is a string json containing information to be created/updated
 * for any number of students
 * [reqBody] must be formatted in accordance with the api documentation
 * side effect: makes a POST request to the admin api endpoint *)
val admin_post : string -> string -> Code.status_code*string

(* [admin_delete password scope reqBody] returns a tuple containing the response
 * status and response body received after a DELETE request to the admin api
 * endpoint.
 * requires:
 * [password] is the admin password
 * [scope] is either "class" or "subset"
 * [reqBody] is a string json detailing which students to delete
 * [reqBody] must be formatted in accordance with the api documentation
 * side effect: makes a DELETE request to the admin api endpoint *)
val admin_delete :
  string -> string -> string -> Code.status_code*string
