open Graph

(* Parse une ligne du type "TIMESTAMP | ID | NAME | ITEM_ID | ITEM_NAME | RATING" *)
let extract_data line =
  let parts = List.map String.trim (String.split_on_char '|' line) in
  match parts with
  | [_ts; uid; _uname; iid; _iname; rat] ->
      (int_of_string uid,
        int_of_string iid, 
        int_of_string rat )
  | _ -> failwith "Format de ligne invalide"


type state = {
  graph : int graph;
  left_ids : int list;   (* IDs des Utilisateurs *)
  right_ids : int list;  (* IDs des Films *)
}


let process_line st line =
  match extract_data line with
  | (u_id, m_id, rating) ->
      
      (* Mise à jour des partitions (sans doublons) *)
      let new_lefts = if List.mem u_id st.left_ids then st.left_ids else u_id :: st.left_ids in
      let new_rights = if List.mem m_id st.right_ids then st.right_ids else m_id :: st.right_ids in
      
      (* Création des nœuds et de l'arc *)
      let g = st.graph in
      let g = if node_exists g u_id then g else new_node g u_id in
      let g = if node_exists g m_id then g else new_node g m_id in
      
      { graph = new_arc g {src=u_id; tgt=m_id; lbl=rating};
        left_ids = new_lefts;
        right_ids = new_rights }



let build_coupon_graph review_graph left_ids right_ids =
  (* 1. On commence par un graphe contenant la Source (0) et le Puits (1) *)
  let base_g = new_node (new_node empty_graph 0) 1 in

  (* 2. On ajoute les arcs Source -> Utilisateurs (capacité 1) *)
  let g_with_users = List.fold_left (fun g id -> 
    new_arc (new_node g id) {src=0; tgt=id; lbl=1}
  ) base_g left_ids in

  (* 3. On ajoute les arcs Films -> Puits (capacité 1) *)
  let g_with_items = List.fold_left (fun g id -> 
    new_arc (new_node g id) {src=id; tgt=1; lbl=1}
  ) g_with_users right_ids in

  (* 4. On ajoute les intérêts (Utilisateur -> Film) uniquement si note >= 4 *)
  e_fold review_graph (fun g arc ->
    if arc.lbl >= 4 then new_arc g {arc with lbl=1} else g
  ) g_with_items