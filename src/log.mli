open Graph

type state = {
  graph : int graph;
  mapping : (string * int) list;
  next_id : int;
  left_ids : int list;   (* IDs des Utilisateurs *)
  right_ids : int list;  (* IDs des Films *)
}


val extract_data: string -> (string * string * int) option

val process_line: state -> string -> state

val build_coupon_graph: int graph -> int list -> int list-> int graph