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

let finalize_flow_network potential_gr left_ids right_ids =
  (* 1. On part du graphe d'intérêts *)
  let g = potential_gr in
  
  (* 2. On s'assure que la source (0) et le puits (1) existent *)
  let g = if node_exists g 0 then g else new_node g 0 in
  let g = if node_exists g 1 then g else new_node g 1 in

  (* 3. On relie la Source (0) à chaque Utilisateur (left_ids) *)
  (* Capacité 1 = On ne donne qu'un seul coupon par personne *)
  let g_with_source = List.fold_left (fun acc_g u_id ->
    new_arc acc_g {src=0; tgt=u_id; lbl=1}
  ) g left_ids in

  (* 4. On relie chaque Film (right_ids) au Puits (1) *)
  (* Capacité 1 = Chaque film n'a qu'un seul coupon disponible *)
  let final_g = List.fold_left (fun acc_g m_id ->
    new_arc acc_g {src=m_id; tgt=1; lbl=1}
  ) g_with_source right_ids in

  final_g


(* Vérifie si un utilisateur a déjà vu un film spécifique *)
let has_seen gr u_id m_id =
  match find_arc gr u_id m_id with
  | Some _ -> true
  | None -> false

(* Génère le graphe des intérêts potentiels *)
let build_potential_interests gr left_ids right_ids =
  (* On repart d'un graphe vide avec tous les nœuds nécessaires *)
  let empty_gr = List.fold_left (fun g id -> new_node g id) empty_graph (left_ids @ right_ids) in 

  (* Pour chaque utilisateur, on cherche des recommandations *)
  List.fold_left (fun g_acc u1_id ->
    
    (* 1. Films vus par u1 *)
    let u1_films = out_arcs gr u1_id in
    
    (* 2. Trouver les utilisateurs similaires (ceux qui ont vu les mêmes films) *)
    let recommendations_for_u1 = List.fold_left (fun recs arc_to_film ->
      let film_id = arc_to_film.tgt in
      
      (* On cherche qui d'autre a vu ce film *)
      let co_viewers = List.filter (fun u_other -> 
        u_other <> u1_id && has_seen gr u_other film_id
      ) left_ids in
      
      (* 3. Pour chaque co-viewer, trouver ses films que u1 n'a pas vus *)
      List.fold_left (fun recs_acc u2_id ->
        let u2_films = out_arcs gr u2_id in
        List.fold_left (fun acc_final arc_u2 ->
          let potential_film = arc_u2.tgt in
          if not (has_seen gr u1_id potential_film) 
          then potential_film :: acc_final
          else acc_final
        ) recs_acc u2_films
      ) recs co_viewers
      
    ) [] u1_films in

    (* 4. Ajouter les arcs (u1 -> film_potentiel) au graphe final *)
    let unique_recs = List.sort_uniq compare recommendations_for_u1 in
    List.fold_left (fun g_final m_id ->
      new_arc g_final {src=u1_id; tgt=m_id; lbl=1}
    ) g_acc unique_recs

  ) (finalize_flow_network empty_gr left_ids right_ids) left_ids