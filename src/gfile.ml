open Graph
open Log
open Printf
    
type path = string

(* Format of text files:
   % This is a comment

   % A node with its coordinates (which are not used), and its id.
   n 88.8 209.7 0
   n 408.9 183.0 1

   % Edges: e source dest label id  (the edge id is not used).
   e 3 1 11 0 
   e 0 2 8 1

*)

(* Compute arbitrary position for a node. Center is 300,300 *)
let iof = int_of_float
let foi = float_of_int

let index_i id = iof (sqrt (foi id *. 1.1))

let compute_x id = 20 + 180 * index_i id

let compute_y id =
  let i0 = index_i id in
  let delta = id - (i0 * i0 * 10 / 11) in
  let sgn = if delta mod 2 = 0 then -1 else 1 in

  300 + sgn * (delta / 2) * 100
  

let write_file path graph =

  (* Open a write-file. *)
  let ff = open_out path in

  (* Write in this file. *)
  fprintf ff "%% This is a graph.\n\n" ;

  (* Write all nodes (with fake coordinates) *)
  n_iter_sorted graph (fun id -> fprintf ff "n %d %d %d\n" (compute_x id) (compute_y id) id) ;
  fprintf ff "\n" ;

  (* Write all arcs *)
  let _ = e_fold graph (fun count arc -> fprintf ff "e %d %d %d %s\n" arc.src arc.tgt count arc.lbl ; count + 1) 0 in
  
  fprintf ff "\n%% End of graph\n" ;
  
  close_out ff ;
  ()

(* Reads a line with a node. *)
let read_node graph line =
  try Scanf.sscanf line "n %f %f %d" (fun _ _ id -> new_node graph id)
  with e ->
    Printf.printf "Cannot read node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "from_file"

(* Ensure that the given node exists in the graph. If not, create it. 
 * (Necessary because the website we use to create online graphs does not generate correct files when some nodes have been deleted.) *)
let ensure graph id = if node_exists graph id then graph else new_node graph id

(* Reads a line with an arc. *)
let read_arc graph line =
  try Scanf.sscanf line "e %d %d %_d %s@%%"
        (fun src tgt lbl -> let lbl = String.trim lbl in new_arc (ensure (ensure graph src) tgt) { src ; tgt ; lbl } )
  with e ->
    Printf.printf "Cannot read arc in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "from_file"

(* Reads a comment or fail. *)
let read_comment graph line =
  try Scanf.sscanf line " %%" graph
  with _ ->
    Printf.printf "Unknown line:\n%s\n%!" line ;
    failwith "from_file"

let from_file path =

  let infile = open_in path in

  (* Read all lines until end of file. *)
  let rec loop graph =
    try
      let line = input_line infile in

      (* Remove leading and trailing spaces. *)
      let line = String.trim line in

      let graph2 =
        (* Ignore empty lines *)
        if line = "" then graph

        (* The first character of a line determines its content : n or e. *)
        else match line.[0] with
          | 'n' -> read_node graph line
          | 'e' -> read_arc graph line

          (* It should be a comment, otherwise we complain. *)
          | _ -> read_comment graph line
      in      
      loop graph2

    with End_of_file -> graph (* Done *)
  in

  let final_graph = loop empty_graph in
  
  close_in infile ;
  final_graph

let export path graph =

  (* Open a write-file. *)
  let ff = open_out path in

  (* Write in this file. *)
  fprintf ff "digraph G { \n" ;

  (* Write all arcs *)
  let _ = e_fold graph (fun count arc -> fprintf ff "%d -> %d [label=\"%s\"];\n" arc.src arc.tgt arc.lbl ; count + 1) 0 in
  
  fprintf ff "}\n" ;
  
  close_out ff ;
  ()

(* Bipartite Graphs Section *)

let read_source_gb graph line =
  try Scanf.sscanf line "s %d %d %d" (fun _ _ id -> new_node graph id)
  with e ->
    Printf.printf "Cannot read source node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "from_file_gb"

let read_sink_gb graph line =
  try Scanf.sscanf line "k %d %d %d" (fun _ _ id -> new_node graph id)
  with e ->
    Printf.printf "Cannot read arc in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "from_file_gb"

let read_left_node_gb graph line =
  try Scanf.sscanf line "l %f %f %d" (fun _ _ id -> new_node graph id)
  with e ->
    Printf.printf "Cannot read left node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "from_file_gb"

let read_right_node_gb graph line =
  try Scanf.sscanf line "r %f %f %d" (fun _ _ id -> new_node graph id)
  with e ->
    Printf.printf "Cannot read right node in line - %s:\n%s\n%!" (Printexc.to_string e) line ;
    failwith "from_file_gb"

let read_comment_gb graph line =
  try Scanf.sscanf line " %%" graph
  with _ ->
    Printf.printf "Unknown line:\n%s\n%!" line ;
    failwith "from_file_gb"

let from_file_gb path =

  let infile = open_in path in

  (* Read all lines until end of file. *)
  let rec loop graph =
    try
      let line = input_line infile in

      (* Remove leading and trailing spaces. *)
      let line = String.trim line in

      let graph2 =
        (* Ignore empty lines *)
        if line = "" then graph

        (* The first character of a line determines its content : n or e. *)
        else match line.[0] with
          | 's' -> read_source_gb graph line
          | 'k' -> read_sink_gb graph line
          | 'l' -> read_left_node_gb graph line
          | 'r' -> read_right_node_gb graph line
          | 'e' -> read_arc graph line

          (* It should be a comment, otherwise we complain. *)
          | _ -> read_comment_gb graph line
      in      
      loop graph2

    with End_of_file -> graph (* Done *)
  in

  let final_graph = loop empty_graph in
  
  close_in infile ;
  final_graph


(* Log Section *)

let initial_state = {
  graph = empty_graph;
  left_ids = [];
  right_ids = [];
}


let from_log path =
  let infile = open_in path in

  (* L'accumulateur est maintenant de type 'state' au lieu de 'graph' *)
  let rec loop st =
    try
      let line = input_line infile in

      (* Remove leading and trailing spaces. *)
      let line = String.trim line in
      
      let st2 =
        if line = "" || line.[0] = '%' then 
          st (* Ignore les lignes vides ou les commentaires commençant par % *)
        else 
          process_line st line (* La fonction de parsing de phrases vue précédemment *)
      in      
      loop st2

    with End_of_file -> st (* On retourne l'état final *)
  in

  (* On commence avec l'état initial défini plus haut *)
  let final_state = loop initial_state in
  close_in infile ;
  final_state