open Client
open Unix
type timePeriodDate

(* [import_students dir pwd] takes a string that represents a directory for a json
 * and imports all the individuals into the database. Returns [true] iff the
 * function successfully reads in the directory and populates the database
 * with students. Returns [false] otherwise.
 * Precondition: the .json file associated with [dir] follows the structure for
 * imports in api.ml*)
val import_students: string -> string -> bool

(* [set_period upDate swDate mtDate pwd] takes three timePeriodDate variables
 * representing the dates of each of these actions and sets those dates within
 * the database. Returns [true] iff the function successfully validates the
 * dates and writes to database. Returns [false] otherwise
 * timePeriods variable representing the time
 * side effect: writes to the DB *)
val set_periods: timePeriodDate -> timePeriodDate -> timePeriodDate -> string -> bool

(* [remove_student netID pwd] takes a student's netid and removes the associated
 * student from the database. Returns [true] if the function successfully
 * removes the student from the database. Returns [false] if the [netID] is not
 * in the database or the function fails to write to database
 * side effect: writes to the DB *)
val remove_student: Student.netid -> string -> bool

(* [add_student metaData pwd] takes a student's meta data and adds the student to
 * the database. Returns [true] if the function successfully writes the student
 * to the database or the student is already in the database. Returns [false]
 * otherwise
 * side effect: writes to the DB *)
val add_student: Student.studentData -> string -> Yojson.Basic.json


(* [get_student netID] returns Some s iff a student with netID exists in the
 * database and s is that student. Otherwise, return None *)
val get_student: Student.netid -> Student.student option

(* [get_all_student ()] reads from the database and returns a list of students.
 *)
val get_all_students: unit -> Student.student list

(* [reset_class ()] clears the database and returns [true] iff the function
 * successfully clears the database and [false] otherwise
 * side effect: writes to the DB *)
val reset_class: unit -> bool
