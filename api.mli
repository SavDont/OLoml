(* [authenticate user pwd] returns [true] iff user and pwd are a valid username
 * password combination in the database and [false] otherwise *)
val authenticate : string -> string -> bool

(* [student_get req] is the callback that handles all student-level GET requests
 * requires: 
 * [req.headers]
 *   key [netid] that specifies the netid of the student information is being
 *    requested about
 *   key [password] that specifies the password associated with netid in the 
 *    database
 *   key [type] that specifies the type of info we are trying to GET. 
 *    The value of [type] can only be student or match
 *    if [type] is student, retrieve an individual student row from database
 *     excluding the password field
 *    if [type] is match, retrieve an individual students match from database
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
 * requests.
 * requires: 
 * [req.headers]
 *   key [netid] that specifies the netid of the student information is being
 *    requested about
 *   key [password] that specifies the password associated with netid in the 
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

(* [admin_get req] is the callback that handles all admin level GET requests.
 * requires: 
 * [req.headers]
 *   key [password] that specifies the admin password
 *   key [type] that specifies the type of info we are trying to GET. 
 *     [type] can be student_indiv, match_indiv, swipe_indiv, student_all, 
 *     swipe_all, or match_all
 *     if [type] is student_indiv, retrieve an individual student row 
 *     from the database
 *     if [type] is match_indiv, retrieve the match for an individual student
 *     if [type] is swipe_indiv, retrieve the swipe results for an individual
 *     student
 *     if [type] is student_all, retrieve all students from the database
 *     if [type] is swipe_all, retrieve the swipe results from all students
 *     in the database
 *     if [type] is match_all, retrieve the match for all students from the
 *     database
 *   key [netid] that specifies the netid of the student we are trying to GET
 *     data about
 *     only needed iff [type] is student_indiv, match_indiv, or swipe_indiv
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
 *    if [res.status] is `Unauthorized, 
 *      [res.res_body] should be "Incorrect password"
 *    if [res.status] is `No_response
 *      [res.res_body] should be "No valid response. Try again later"
 *)
val admin_get : HttpServer.request -> HttpServer.response

(* [admin_post req] is the callback that handles all admin level POST requests.
 * requires: 
 * [req.headers]
 *  key [password] that specifies the admin password
 *  key [type] that specifies the type of action we are trying to take. 
 *   key [type] can either be add or remove
 *   if [type] is add, add any number of students to the database
 *   if [type] is remove, remove any number of students from the database
 * [req.req_body] 
 *  [req.req_body] should be a string representing a JSON
 *  if [type] is add, the body should be as follows:
 *    {s1 :
 *       {k1 : s1v1, k2 : s1v2, ... kn : s1vn},
 *     s2 :
 *       {k1 : s2v1, k2 : s2v2, ... kn : s2vn},
 *                         ...
 *     sn:
 *       {k1 : snv1, k2 : snv2, ... kn : snvn}
 *     }
 *   where si is a netid, kj is a column in the database and sivj is the
 *   value we would like to store in column kj for student si
 *   if kj is an invalid column name or a column name that is not user mutable 
 *   (i.e. a metadata column), the kj : sivj pair is ignored
 *   if a student with netid si is already in the database, its fields will be
 *   overwritten with the data specified in the request body
 *  if [type] is remove, the body shoudld be as follows:
 *   {s1 : _, s2: _, ... , sn: _}
 *   where si is a netid. We do not care about the JSON value associated with 
 *   si, hence the wildcard.
 *   if a student with netid si is not in the database, ignore the si : _ pair
 *   if a student with netid si is in the database, delete the entire row
 *   associated with that student
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