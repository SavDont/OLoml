
(* Type representing a student, with all of his/her metadata and profile
 * information*)
(* type student *)

(* Type representing possible skills a student can have, as well as
 * proficiency in those skills *)
(* type skills *)

(* Type representing a location closest to where a student lives *)
(* type location *)

(* Type representing data that can be updated by a student (non-metadata)*)
(* type updateData *)

(* REMOVE LATER ~~~~~~~~~~~~~~~*)
(* Type representing student's current year in school
 * Fresh = freshman, Soph = sophomore, Jun = junior, Sen = senior*)
type classYear =
  | Fresh
  | Soph
  | Jun
  | Sen
  | Empty

type location =
  | North
  | West
  | Collegetown
  | Empty

(* Type representing a student's available time slots throughout a single week.
 * Each schedule must be of length exactly 21.  It is parsed as follows:
 * - every three elements represent a single day.  For example,
 *   elements 0-2 represent monday, 3-5 represent tuesday...18-20 represent
 *   sunday
 * - within each day, the first element represents morning, the second
 *   afternoon, and the third evening. i.e. 0 is monday morning, 2 is monday
 *   evening
 * - true means that a student is available during this time slot, and
 *   false means they are not. *)
type schedule = bool list

type student = {
  name : string;
  netid : string;
  year : classYear;
  schedule : schedule;
  courses_taken : int list;
  hours_to_spend : int;
  location : location;
  profile_text : string;
}

type updateData =
  | Schedule of schedule
  | Courses of int list
  | Hours of string
  | Location of location
  | Text of string
(* REMOVE LATER ~~~~~~~~~~~~~~~~~~~ *)

(* [valid_course c] is true iff c is a course that a student can
 * list as having taken.
 * Requires: c must be 4 digits in length*)
val valid_course : int -> bool

(* [printable_student s] gives the printable profile representation of s.
 * requires: s's schedule list must be exactly length 21. *)
val printable_student : student -> string

(* [parse_student st_str] gives the student representation of the
 * inputted string representation of json.
 * Requries: st_str must be a valid representation of a json.  That is,
 * Yojson.Basic.from_string must not throw any errors when called in st_str.
 * st_str must have the following fields as members: "courses_taken",
 * "skills", "schedule", "name", "netid", "year", "hours_to_spend",
 * "profile_text", "location"*)
val parse_student : string -> student
(* [get_student net pwd] gives the student option corresponding to
 * netid of net if (a) a student with this netid exists in the database
 * and (b), that pwd is the correct password for this netid.
 * If either is not true, None is returned. *)
val get_student : string -> string -> student option

(* [update_profile net pwd attr_lst] updates the database entry corresponding
 * to netid, net and password, pwd with every attribute that is included
 * in attr_lst.  Any attribute that is not in the list remains unchanged
 * in the database.  The update is successful if (a) a student corresponding
 * to net exists in the database, and (b) if pwd is the correct password
 * stored. It returns true if the update is successful, and false if not.
 * Side-Effects: Updates Database *)
val update_profile : string -> string -> updateData list -> bool

(* [get_match net pwd] gives the student option that the student corresponding
 * to net has been matched to.  If a student corresponding to netid, net doesn't
 * exist in the database, or pwd is not the correct password for net,
 * None is returned. *)
val get_match : string -> string -> student option

(* [sched_score s1 s2] gives a float score representing how compatible
 * two students' schedules are.
 * Requires: s1 and s2 cannot be the same student *)
val sched_score : student -> student -> float

(* [sched_score s1 s2] gives a float score representing how compatible
 * two students' course lists are.
 * Requires: s1 and s2 cannot be the same student *)
val course_score : student -> student -> float

(* [sched_score s1 s2] gives a float score representing how compatible
 * two students' hours willing to spend on project are.
 * Requires: s1 and s2 cannot be the same student *)
val hour_score : student -> student -> float

(* [sched_score s1 s2] gives a float score representing how compatible
 * two students' living locations are.
 * Requires: s1 and s2 cannot be the same student *)
val loc_score : student -> student -> float
