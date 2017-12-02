 (* api specific parameters parameters *)
let base_url = "http://en-cs-3110project2.coecis.cornell.edu:8000/"
let credentials_endpoint = "credentials/"
let period_endpoint = "period/"
let student_endpoint = "student/"
let admin_endpoint = "admin/"
let swipes_endpoint = "swipes/"
let matches_endpoint = "matches/"

(* remove for prod *)
let test_endpoint = "test/"

(* database parameters *)
let stu_tbl = "Students"
let match_tbl = "Matches"
let creds_tbl = "Credentials"
let periods_tbl = "Periods"