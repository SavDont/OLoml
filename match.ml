open Loml_client
open Yojson.Basic

type swipe_results_class = (string * string * float) list

type matching = (string * string) list


(* [create_swipes netID lst] takes a tuple list of type string * `Float f and
 * and a [netID] and creates a swipe_results_class tuple with the netID
 * and each tuple in the list [lst]
 * Requires: lst's second value in the tuple must be of the form `Int i
 * Returns: swipe_results_class*)
let rec create_swipes netID lst = match lst with
  | (str, `Float f)::t -> if compare netID str = -1
    then (netID, str, f)::(create_swipes netID t)
    else if compare netID str = 1
    then (str, netID, f)::(create_swipes netID t)
    else
      create_swipes netID t
  | [] -> []
  | _ -> failwith "impossible"

(* [get_all_results swLst] takes a tuple list of (string * (string * `Float f) list) list and
 * creates a variable of type swipe_results_class to represent all of the
 * the swipes
 * Returns: swipe_results_class*)
let rec get_all_results swLst = match swLst with
  | (netID, l)::t -> (create_swipes netID l) @
                     get_all_results t
  | [] -> []

(* [find_compat_score lst netID1 netID2] takes a swipe_results_class and
 * two strings representing netids and finds their associated compatibility
 * score (the third item in tuple). If no such element is found, a 0 is
 * returned
 * requires: compare [netID1] [netID2] = -1
 * and for every tuple in swipe_results_class the first two strings are
 * alphabetically ordered
 * returns: int*)
let rec find_compat_score lst netID1 netID2 = match lst with
  | (n1, n2, f)::t -> if n1 = netID2 && n2 = netID1 then f
    else find_compat_score t netID1 netID2
  | [] -> 0.0

(* [rem_swipe lst netID1 netID2] takes a swipe_results_class and two strings
 * representing netids and removes the tuple with matching netids from the
 * swipe_results_class variable
 * requires: compare [netID1] [netID2] = -1
 * and for every tuple in swipe_results_class the first two strings are
 * alphabetically ordered
 * returns: swipe_results_class*)
let rec rem_swipe lst netID1 netID2 = match lst with
  | (n1, n2, f)::t -> if n1 = netID2 && n2 = netID1
    then rem_swipe t netID1 netID2
    else (n1, n2, f)::(rem_swipe t netID1 netID2)
  | [] -> []

(* [resolve_duplicates swResults] takes a swipe_results_class and resolves
 * duplicate netID pairs by adding their compatibility scores together and
 * removing the duplicate list element.
 * requires: every tuple in [swResults] has its first two items in the tuple
 * in alphabetical order in relation to one another
 * returns: swipe_results_class without duplicate netID pairs*)
let rec resolve_duplicates swResults = match swResults with
  | (n1, n2, f)::t -> let newScore = find_compat_score t n1 n2 in
    let newTl = rem_swipe t n1 n2 in
    (n1, n2, f+.newScore)::(resolve_duplicates newTl)
  | [] -> []

(* [get_unique_ids_sw swLst acc] takes a swipe_results_class and creates a list
 * of unique netIDs forming the entire class. This represents all the students
 * that need to be matched
 * returns: string list*)
let rec get_unique_ids_sw swLst acc = match swLst with
  | (n1, n2, _)::t -> if not (List.mem n1 acc) && not (List.mem n2 acc)
    then get_unique_ids_sw t (n1::n2::acc)
    else if not (List.mem n1 acc) && List.mem n2 acc
    then get_unique_ids_sw t (n1::acc)
    else if List.mem n1 acc && not (List.mem n2 acc)
    then get_unique_ids_sw t (n2::acc)
    else get_unique_ids_sw t acc
  | [] -> acc

(* [swipe_list_conversion lst] takes a (string*`String str) list and converts it into a
 * (string * (string * `Float f) list) list
 * requires: the string in snd lst  must be a json formattable type
 * returns: (string * (string * `Float f) list) list*)
let rec swipe_list_conversion lst = match lst with
  | h::t -> let netid = fst h in
    let yoj = h |> snd |> Yojson.Basic.Util.to_string |> Yojson.Basic.from_string in
    let asLst = yoj |> Yojson.Basic.Util.to_list |> Yojson.Basic.Util.filter_assoc |> List.flatten in
    (netid, asLst)::(swipe_list_conversion t)
  | [] -> []


let gen_class_results pwd =
  let swReq = Loml_client.swipes_get pwd in
  if fst swReq = `OK
  then
    let lst = swReq |> snd |> from_string |>
              Util.to_list |> Util.filter_assoc |> List.flatten |> swipe_list_conversion in
    let allSwipes = get_all_results lst in
    resolve_duplicates allSwipes
  else []

(* [remove_netIDs swLst n1 n2] takes a swipe_results_class and removes
 * all tuples in the list where the first or second element are identical to
 * two other netIDs [n1] and [n2]
 * Returns: a swipe_results_class*)
let rec remove_netIDs swLst n1 n2 = match swLst with
  | (netID1, netID2, i)::t -> if netID1 = n1 || netID1 = n2 ||
                              netID2 = n1 || netID2 = n2
    then remove_netIDs t n1 n2
    else (netID1, netID2, i)::(remove_netIDs t n1 n2)
  | [] -> []

(* [list_rem lst n] takes a list [lst] and removes element [n] from the list
 * If no such element is found, the original list is returned*)
let rec list_rem lst n = match lst with
  | h::t ->if h = n then list_rem t n
    else h::(list_rem t n)
  | [] -> []

(* [find_unmatched mList unm] takes a matching list and a string list of netIDs
 * and attempts to find the unmatched individuals by recursing through the
 * netIDs of [mList] and removing the netIDs from the original unmatched list
 * [unm]
 * Returns: string list*)
let rec find_unmatched  mList unm = match mList with
  | (n1, n2)::t -> let firstUnm = list_rem unm n1 in
    find_unmatched t (list_rem firstUnm n2)
  | [] -> unm

(* [get_matches lst] returns a variable of type matching which represents
 * the best possible pairings for individuals
 * Requires: lst must be ordered highest compatibility score to lowest
 * Returns: matching*)
let rec get_matches lst = match lst with
  | (netID1, netID2, _)::t -> (netID1, netID2)::
                              (get_matches(remove_netIDs t netID1 netID2))
  | [] -> []

(* [duplicate_tuples lst] returns a list of tuples where for every element
 * (n1, n2) in the list, (n2, n1) is also added to the list
 * Requires: for every tuple in the list the two tuples are not equal to one
 * another
 * Returns: tuple list*)
let rec duplicate_tuples lst = match lst with
  | (n1, n2)::t -> (n1, n2)::(n2, n1)::(duplicate_tuples t)
  | [] -> []

let matchify r pwd =
  let unmatchedInit = get_unique_ids_sw r [] in
  let orderedSw = List.rev (List.sort
                              (fun (_,_,i1) (_,_,i2) -> if i1 > i2 then 1
                              else if i1 = i2 then 0
                              else -1) r) in
  let matches  = orderedSw |> get_matches |> duplicate_tuples in
  let unmatched = find_unmatched matches unmatchedInit in
  let leftovers = List.map (fun s -> (s, "UNMATCHED")) unmatched in
  let all_matches = matches @ leftovers in
  let rec jsonify lst acc = match lst with
    | (n1, n2)::[] -> acc ^ "\"" ^ n1 ^ "\":\"" ^ n2 ^ "\""
    | (n1, n2)::t -> jsonify t (acc ^ "\"" ^ n1 ^ "\":\"" ^ n2 ^ "\",")
    | [] -> acc in
  let jStr = (jsonify all_matches "{") ^ "}" in
  let mtchReq = Loml_client.matches_post pwd jStr in
  if fst mtchReq = `OK
  then true
  else false
