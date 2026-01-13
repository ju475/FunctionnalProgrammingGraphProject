open Graph

type state = {
  graph : int graph;
  left_ids : int list;   (* IDs des Utilisateurs *)
  right_ids : int list;  (* IDs des Films *)
}

val extract_data: string -> (int * int * int)

val process_line: state -> string -> state

val build_coupon_graph: int graph -> int list -> int list-> int graph

val build_potential_interests: int graph -> int list -> int list -> int graph