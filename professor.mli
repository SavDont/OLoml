type timePeriods

(* [authenticate pwd] returns [true] iff pwd = the admin password in the
 * database and [false] otherwise *)
val authenticate : string -> bool

(* [import_students dir] takes a string that represents a directory for a csv
 * and imports all the individuals into the database. Returns [true] iff the
 * function successfully reads in the directory and populates the database
 * with students. Returns [false] otherwise.
 * Precondition: the .csv file associated with [dir] follows the structure for
 * studentData in Student module*)
val import_students: string -> bool

(* [set_period isSwipe] takes a timePeriods variable representing the time
 * period to update profile period, swipe period, and match period and sets that
 * in the database. Returns [true] iff the function successfully reads the
 * time periods and writes to database. Returns [false] otherwise.
 * Example: period could be update profile period, swipe period, or match
 * period.
 * side effect: writes to the DB *)
val set_periods: timePeriods -> bool

(* [remove_student netID] takes a student's netid and removes the associated
 * student from the database. Returns [true] if the function successfully
 * removes the student from the database. Returns [false] if the [netID] is not
 * in the database or the function fails to write to database
 * side effect: writes to the DB *)
val remove_student: Student.netid -> bool

(* [add_student metaData] takes a student's meta data and adds the student to
 * the database. Returns [true] if the function successfully writes the student
 * to the database or the student is already in the database. Returns [false]
 * otherwise
 * side effect: writes to the DB *)
val add_student: Student.studentData -> bool

(* [get_all_student ()] reads from the database and returns a list of students.
 *)
val get_all_students: unit -> Student.student list

(* [reset_class ()] clears the database and returns [true] iff the function
 * successfully clears the database and [false] otherwise
 * side effect: writes to the DB *)
val reset_class: unit -> bool



