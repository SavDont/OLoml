
(* Type representing a student, with all of his/her metadata and profile
 * information*)
type student

(* Type representing possible skills a student can have, as well as
 * proficiency in those skills *)
type skill

(* Type representing a location closest to where a student lives *)
type location

(* Type representing data that can be updated by a student (non-metadata)*)
type updateData

(* [valid_course c] is true iff c is a course that a student can
 * list as having taken.
 * Requires: c must be 4 digits in length*)
val valid_course : int -> bool

(* [printable_student s] gives the printable profile representation of s.
 * requires: s's schedule list must be exactly length 21. *)
val printable_student : student -> string

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

(* [sched_score s1 s2] gives an integer score representing how compatible
 * two students' schedules are.
 * Requires: s1 and s2 cannot be the same student *)
val sched_score : student -> student -> float

val course_score : student -> student -> float

val hour_score : student -> student -> float

val loc_score : student -> student -> float
