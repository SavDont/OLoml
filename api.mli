(* test callback, will not be there in final version *)
val test: HttpServer.request -> HttpServer.response

(* [are_valid_credentials user pwd] returns [true] iff user and pwd are a
 * valid username password combination in the database and [false] otherwise *)
val are_valid_credentials : string -> string -> bool

(* [check_period] is a string representing the current period.
 * returns:
 *  "update" if the current period is the update period
 *  "swipe" if the current period is the swipe period
 *  "match" if the current period is the match period
 *  "null" if the periods have not been initialize yet *)
val current_period : unit -> string

(* [check_credentials req] is the endpoint that determines whether a username
 * and password combination is valid
 * requires:
 * [req.headers]
 *   header [username] that specifies the username we are querying about
 *   header [password] specifies the password provided for that user
 * [req.params] - ignored
 * [req.req_body] - ignored
 * returns: HttpServer.response [res]
 *  [resp.headers]
 *    [resp.headers] should be the default plain text Cohttp Header
 *  [resp.status]
 *    [resp.status] should be `OK iff username/password combination was
 *     authenticated
 *    [resp.status] should be `Unauthorized iff username/password did not
 *     authenticate
 *    [res.status] should be `No_response otherwise
 *  [resp.res_body]
 *    [resp.res_body] should be an empty string *)
val credentials_post : HttpServer.request -> HttpServer.response

(* [period_get req] is the endpoint that queries the database for the current
 * period
 * requires:
 * [req.headers]
 *   header [username] that specifies a valid username in the database
 *   header [password] specifies the password associated with that user
 * [req.params] - ignored
 * [req.req_body] - ignored
 * returns: HttpServer.response [res]
 *  [resp.headers]
 *    [resp.headers] should be the default plain text Cohttp Header
 *  [resp.status]
 *    [resp.status] should be `OK iff username/password combination was
 *     authenticated and the current period was retrieved
 *    [resp.status] should be `Unauthorized iff username/password did not
 *     authenticate
 *    [res.status] should be `No_response otherwise
 *  [resp.res_body]
 *    if the username/password combination authenticated, [resp.res_body] is the
 *     result of current_period
 *    if the username/password combination did not authenticate, [resp.res_body]
 *     is the empty string *)
val period_get : HttpServer.request -> HttpServer.response

(* [period_post req] is the endpoint that initally sets the period
 * requires:
 * [req.headers]
 *   header [password] that specifies the admin password (only the admin can set
 *   the period)
 * [req.params] - ignored
 * [req.req_body] -
 *   [req.req_body] should be a string json of the following form
 * {
 *   "update" : update_date,
 *   "swipe"  : swipe_date,
 *   "match"  : match_date
 * }
 * where {period_name}_date is the start date of the {period_name} period
 * if the periods have not been set yet, the values provided in [req.req_body]
 * will be used to set the period
 * if the period has already been set, do nothing. The period cannot be changed
 * once it is set
 * returns: HttpServer.response [res]
 *  [resp.headers]
 *    [resp.headers] should be the default plain text Cohttp Header
 *  [resp.status]
 *    [resp.status] should be `OK iff the admin password was valid and the
 *     period was set
 *    [resp.status] should be `Unauthorized if admin password did not validate
 *     or the period has already been set
 *    [res.status] should be `No_response otherwise
 *  [resp.res_body]
 *    if [res.status] is `OK
 *      [res.resp_body] should be "Success"
 *    if [res.status] is `Unauthorized
 *       if the admin password did not validate
 *         [res.res_body] should be "Incorrect password"
 *       if the period has already been set
 *         [res.res_body] should be "Period already set"
 *    if [res.status] is `No_response
 *      [res.res_body] should be "No valid response. Try again later"
 * side effect: updates the database *)
val period_post : HttpServer.request -> HttpServer.response

(* [swipes_get req] is the endpoint that retrieves all swipe results from the
 * database
 * [req.headers]
 *   header [password] that specifies the admin password (only the admin can
 *    retrieve swipes)
 * [req.params] - ignored
 * [req.req_body] - ignored
 * returns: HttpServer.response [res]
 *  [resp.headers]
*    [res.headers] should be the default plain text Cohttp Header
 *  [res.status]
 *    [res.status] should be `OK iff the admin password was authenticated
 *     and valid data was retrieved from the database
 *    [res.status] should be `Unauthorized iff password did not authenticate
 *    [res.status] should be `No_response otherwise
 *  [res.res_body]
 *    if [res.status] is `OK
 *      [res.res_body] should be a text json representation
 *      of the database data in the following form:
 *   { student1:
 *       {student1: score1, student2: score2, ... , studentn: scoren},
 *    student2:
 *       {student1: score1, student2: score2, ... , studentn: scoren},
 *                                 ... ,
 *    studentn:
 *       {student1: score1, student2: score2, ... , studentn: scoren},                          
 *   }
 *    studenti is the netid of a student in the database. The netid of every
 *     student in the class will be stored as a key in the outer json. The value
 *     of studenti in the outer json is another json. The key:value pairs in
 *     this inner json represent student:score pairs. For every student studentj
 *     in the inner json, scorei is the score assigned to the pairing of
 *     studenti and studentj. The score is based on how studenti swiped on
 *     studentj and the compatability score between the two students.
 *    if [res.status] is `Unauthorized
 *      [res.res_body] should be "Incorrect password"
 *    if [res.status] is `No_response
 *      [res.res_body] should be "No valid response. Try again later" *)
val swipes_get : HttpServer.request -> HttpServer.response

(* [swipes_post req] is the endpoint that writes a students swipe results
 * to the database
 * [req.headers]
 *   header [netid] that specifies the netid of the student swipes are being
 *    written for
 *   header [password] specifies the password associated with netid in the
 *    database
 * [req.params] - ignored
 * [req.req_body] -
 *   [req.req_body] should be a string json of the following form
 *   {
 *    netid:
 *       {student1: score1, student2: score2, ... , studentn: scoren}
 *   }
 * where netID is the netid from above, studenti is the netid of another
 * student in the database and scorei is the score assigned to the pairing of 
 * student netID and student studenti.
 * this score should be calculated based on how student netID swiped on student
 * studenti and the compatability score between the two students.
 * returns: HttpServer.response [res]
 *  [resp.headers]
 *    [resp.headers] should be the default plain text Cohttp Header
 *  [res.status]
 *    [res.status] should be `OK iff netid/password combination was
 *    authenticated and a valid database update was performed
 *    [res.status] should be `Unauthorized iff netid/password did not
 *    authenticate
 *    [res.status] should be `No_response otherwise
 *  [res.res_body]
 *    if [res.status] is `OK
 *      [res.resp_body] should be "Success"
 *    if [res.status] is `Unauthorized
 *      [res.res_body] should be "Incorrect netid or password"
 *    if [res.status] is `No_response
 *      [res.res_body] should be "No valid response. Try again later" *)
val swipes_post : HttpServer.request -> HttpServer.response

(* [matches_post req] is the endpoint that writes matches from the matching
 * algorithm to the database
 * [req.headers]
 *   header [password] that specifies the admin password (only the admin can
 *    write matches)
 * [req.params] - ignored
 * [req.req_body] -
 *   [req.req_body] should be a string json of the following form
 * {
 *       netid_1 : netid_2,
 *              ...
 *    netid_n-1  : netid_n,
 * }
 * where each key:value pair in the json represents a match to be written into
 * the database. 
 * each key:value pair should only exist in one order; i.e. if the pair a:b is
 * in the json, the pair b:a should not be in the json.
 * returns: HttpServer.response [res]
 *  [resp.headers]
 *    [resp.headers] should be the default plain text Cohttp Header
 *  [resp.status]
 *    [resp.status] should be `OK iff the admin password was valid and the
 *     matches were written
 *    [resp.status] should be `Unauthorized if admin password did not validate
 *    [res.status] should be `No_response otherwise
 *  [resp.res_body]
 *    if [res.status] is `OK
 *      [res.resp_body] should be "Success"
 *    if [res.status] is `Unauthorized
 *       [res.res_body] should be "Incorrect password"
 *    if [res.status] is `No_response
 *      [res.res_body] should be "No valid response. Try again later"
 * side effect: updates the database *)
val matches_post : HttpServer.request -> HttpServer.response

(* [student_get req] is the callback that handles all student-level GET requests
 * student-level GET request can retrieve information about a specified student.
 * requires:
 * [req.headers]
 *   header [netid] that specifies the netid of the student information is being
 *    requested for
 *   header [password] specifies the password associated with netid in the
 *    database
 *   header [scope] that specifies the scope of the info we are trying to GET.
 *    The value of [scope] can only be "student" or "match"
 *    if [scope] is "student", retrieve an individual student row from database
 *     excluding the password field
 *    if [scope] is "match", retrieve an individual students match from database
 * [req.params] - ignored
 * [req.req_body] - ignored
 *
 * returns: HttpServer.response [res]
 *  [resp.headers]
 *    [resp.headers] should be the default plain text Cohttp Header
 *  [resp.status]
 *    [resp.status] should be `OK iff netid/password combination was
 *     authenticated and valid data was retrieved from the database
 *    [resp.status] should be `Unauthorized iff netid/password did not
 *     authenticate
 *    [res.status] should be `No_response otherwise
 *  [resp.res_body]
 *    if [resp.status] is `OK
 *      [resp.res_body] should be a text json representation of the database
 *      data in the following form:
 *      {netID:
 *        {k1 : v1, k2 : v2, ... kn : vn}
 *      }
 *      where netID is the netid from above, ki is a column in the database and
 *      vi is the value associated with that column for the student with a netid
 *      corresponding to netID
 *    if [res.status] is `Unauthorized
 *      [res.res_body] should be "Incorrect netid or password"
 *    if [res.status] is `No_response
 *      [res.res_body] should be "No valid response. Try again later"
 *)
val student_get : HttpServer.request -> HttpServer.response

(* [student_post req] is the callback that handles all student-level POST
 * requests. student-level POST request can update information for a specified
 * student.
 * requires:
 * [req.headers]
 *   header [netid] that specifies the netid of the student we are trying to
 *   update
 *   header [password] that specifies the password associated with netid in the
 *    database
 * [req.req_body]
 *   [req.req_body] should be a string representing a JSON as such:
 *      {netID:
 *        {k1 : v1, k2 : v2, ... kn : vn}
 *      }
 *      where netID is the netid from above, ki is a column in the database and
 *      vi is the value that we want to write for that column for the student
 *      with a netid corresponding to netID
 *   if ki is an invalid column name or a column name that is not user mutable
 *   (i.e. a metadata column), the ki : vi pair is ignored
 *   for column name ki specified in the request body where ki corresponds to a
 *   valid, user mutable column, the existing value in the database will be
 *   overwritten with vi
 *   if a valid column name kx is not included in k1 ... kn, the corresponding
 *   value for column kx for the given student will remain unchanged
 * [req.params] - ignored
 *
 * returns:
 * HttpServer.response [res]
 *  [res.headers]
 *    [res.headers] should be the default plain text Cohttp Header
 *  [res.status]
 *    [res.status] should be `OK iff netid/password combination was
 *    authenticated and a valid database update was performed
 *    [res.status] should be `Unauthorized iff netid/password did not
 *    authenticate
 *    [res.status] should be `No_response otherwise
 *  [res.res_body]
 *    if [res.status] is `OK
 *      [res.resp_body] should be "Success"
 *    if [res.status] is `Unauthorized
 *      [res.res_body] should be "Incorrect netid or password"
 *    if [res.status] is `No_response
 *      [res.res_body] should be "No valid response. Try again later"
 *
 * side effect: updates the database
 *)
val student_post : HttpServer.request -> HttpServer.response

(* [admin_get req] is the callback that handles all admin-level GET requests.
 * admin-level GET requests can retrieve information about both an individual
 * student and about the entire class
 * requires:
 * [req.headers]
 *   header [password] that specifies the admin password
 *   header [scope] that specifies the scope of info we are trying to GET.
 *     [scope] can only be "student_indiv", "swipe_indiv", "match_indiv",
 *     "student_all", "swipe_all", or "match_all"
 *     if [scope] is "student_indiv", retrieve an individual student row
 *     from the database
 *     if [scope] is "swipe_indiv", retrieve the swipe results for an individual
 *     student
 *     if [scope] is "match_indiv", retrieve the match for an individual student
 *     if [scope] is "student_all", retrieve all students from the database
 *     if [scope] is "swipe_all", retrieve the swipe results from all students
 *     in the database
 *     if [scope] is "match_all", retrieve the match for all students from the
 *     database
 *   header [netid] that specifies the netid of the student we are trying to GET
 *     data about
 *     needed iff [scope] is "student_indiv", "swipe_indiv", or "match_indiv"
 * [req.params] - ignored
 * [req.req_body] - ignored
 *
 * returns:
 * HttpServer.response [res]
 *  [res.headers]
 *    [res.headers] should be the default plain text Cohttp Header
 *  [res.status]
 *    [res.status] should be `OK iff the admin password was authenticated
 *     and valid data was retrieved from the database
 *    [res.status] should be `Unauthorized iff password did not authenticate
 *    [res.status] should be `No_response otherwise
 *  [res.res_body]
 *    if [res.status] is `OK
 *      [res.res_body] should be a text json representation
 *      of the database data in the following form:
 *      {s1 :
 *         {k1 : s1v1, k2 : s1v2, ... kn : s1vn},
 *       s2 :
 *         {k1 : s2v1, k2 : s2v2, ... kn : s2vn},
 *                           ...
 *       sn:
 *         {k1 : snv1, k2 : snv2, ... kn : snvn}
 *       }
 *      where si is a netid, kj is a column in the database and sivj is the
 *      value associated with column kj for student with netid si in the
 *      database
 *    if the request is swipes then each key is a string representing netid of
 *    the other person swiped on    
 *    if [res.status] is `Unauthorized,
 *      [res.res_body] should be "Incorrect password"
 *    if [res.status] is `No_response
 *      [res.res_body] should be "No valid response. Try again later"
 *)
val admin_get : HttpServer.request -> HttpServer.response

(* [admin_post req] is the callback that handles all admin-level POST requests.
 * admin-level POST requests can add/update info for any number of specified
 * students
 * requires:
 * [req.headers]
 *  header [password] that specifies the admin password
 * [req.req_body]
 *  [req.req_body] should be a string representing a JSON as follows
 *    {s1 :
 *       {s1k1 : s1v1, s1k2 : s1v2, ... s1kn : s1vn},
 *     s2 :
 *       {s2k1 : s2v1, s2k2 : s2v2, ... s2kn : s2vn},
 *                         ...
 *     sn:
 *       {s3k1 : snv1, s3k2 : snv2, ... s3kn : snvn}
 *     }
 *   where si is a netid, sikj is a column in the database and sivj is the
 *   value we would like to store in column kj for student with netid si
 *   if a student with netid si does not exist in the database, the student will
 *   be created with the specified information
 *   if a student with netid si is already in the database, its fields will be
 *   overwritten with the data specified in the request body
 *   if sikj is an invalid column name, the sikj : sivj pair is ignored
 *   for a valid column name kx not included in sik1 ... sikn for student with
 *   netid si, the corresponding value in column kx for that student will either
 *     remain unchanged (if the student already exists in the databse)
 *     be set to the default value (if the student is new)
 * [req.params] - ignored
 *
 * returns:
 * HttpServer.response [res]
 *  [res.headers]
 *    [res.headers] should be the default plain text Cohttp Header
 *  [res.status]
 *    [res.status] should be `OK iff the admin password was authenticated
 *     and a valid database update was performed
 *    [res.status] should be `Unauthorized iff password did not authenticate
 *    [res.status] should be `No_response otherwise
 *  [res.res_body]
 *    if [res.status] is `OK
 *      [res.resp_body] should be "Success"
 *    if [res.status] is `Unauthorized
 *      [res.res_body] should be "Incorrect password"
 *    if [res.status] is `No_response
 *      [res.res_body] should be "No valid response. Try again later"
 *
 * side effect : updates the database
 *)
val admin_post : HttpServer.request -> HttpServer.response

(* [admin_delete req] is the callback that handles all admin-level DELETE
 * requests.
 * the admin is able to delete the entire class or a selected subset of the
 * class
 * requires:
 * [req.headers]
 *   header [password] that specifies the admin password
 *   header [scope] specifies the scope of the information we want to delete
 *   header [scope] can only be "class" or "subset"
 *    should be "class" if we want to delete all students, i.e. reset the class
 *    should be "subset" if we only want to delete a subset of the students
 * [req.req_body]
 *   if header [scope] is "class", [req.req_body] is ignored.
 *   else, [req.req_body] should be a string representing a JSON as follows:
 *     {s1 : _, s2: _, ... , sn: _}
 *     where si is a netid. We do not care about the JSON value associated with
 *     si, hence the wildcard.
 *     if a student with netid si is not in the database, ignore the si : _ pair
 *     if a student with netid si is in the database, the entire row associated
 *     with that student will be deleted
 * [req.params] - ignored
 *
 * returns:
 * HttpServer.response [res]
 *  [res.headers]
 *    [res.headers] should be the default plain text Cohttp Header
 *  [res.status]
 *    [res.status] should be `OK iff the admin password was authenticated
 *     and a valid database update was performed
 *    [res.status] should be `Unauthorized iff password did not authenticate
 *    [res.status] should be `No_response otherwise
 *  [res.res_body]
 *    if [res.status] is `OK
 *      [res.resp_body] should be "Success"
 *    if [res.status] is `Unauthorized
 *      [res.res_body] should be "Incorrect password"
 *    if [res.status] is `No_response
 *      [res.res_body] should be "No valid response. Try again later"
 *
 * side effect : updates the database
 *)
val admin_delete : HttpServer.request -> HttpServer.response
