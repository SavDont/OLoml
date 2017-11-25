(* [student_get netID pwd info] returns a tuple containing the response status 
 * and response body received after a GET request to the student api endpoint. 
 * requires: 
 * [netID] is a valid netid of a student in the database
 * [pwd] is the password associated with the student whose netid is netID
 * [scope] is either "all" or "match"
 * side effect: makes a GET request to the student api endpoint *)
val student_get : Student.netid -> string -> string -> HttpServer.meth*string

(* [student_post netID pwd reqBody] returns a tuple containing the response 
 * status and response body received after a POST request to the student api 
 * endpoint. 
 * requires:
 * [netID] is a valid netid of a student in the database
 * [pwd] is the password associated with the student with netid netID
 * [reqBody] is a string representation of a json containing information to be
 * updated for the student with netid netID
 * [reqBody] should be formatted as specified in the api documentation
 * side effect: makes a POST request to the student api endpoint *)
val student_post : Student.netid -> string -> string -> HttpServer.meth*string

(* [admin_get pwd info ?netID] returns a tuple containing the response status 
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
  string -> string -> ?netID:Student.netid -> HttpServer.meth*string

(* [admin_post pwd reqBody] returns a tuple containing the response 
 * status and response body received after a POST request to the admin api 
 * endpoint. 
 * requires:
 * [pwd] is the admin password
 * [reqBody] is a string representation of a json containing information to be
 * created/updated for any number of students
 * [reqBody] should be formatted as specified in the api documentation
 * side effect: makes a POST request to the admin api endpoint *)
val admin_post : string -> string -> HttpServer.meth*string

(* [admin_delete pwd scope reqBody] returns a tuple containing the response 
 * status and response body received after a DELETE request to the admin api 
 * endpoint. 
 * requires:
 * [pwd] is the admin password
 * [scope] is either "class" or "subset"
 * [reqBody] is a string representation of a json detailing which students to
 * delete
 * [reqBody] should be formatted as specified in the api documentation
 * side effect: makes a DELETE request to the admin api endpoint *)
val admin_delete : string -> string -> string -> HttpServer.meth*string