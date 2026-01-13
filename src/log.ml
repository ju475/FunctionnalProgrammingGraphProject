open Graph

(* On cherche : Un Nom (Majuscule + lettres) ... un autre Nom ... un Chiffre *)
let re_log = Str.regexp "\\([A-Z][a-z]+\\).+\\([A-Z][a-z]+\\).+\\([0-5]\\)"

let extract_data line =
  if Str.string_match re_log line 0 then
    let user = Str.matched_group 1 line in
    let movie = Str.matched_group 2 line in
    let rating = int_of_string (Str.matched_group 3 line) in
    Some (user, movie, rating)
  else
    None


type state = {
  graph : int graph;
  mapping : (string * int) list;
  next_id : int;
  left_ids : int list;   (* IDs des Utilisateurs *)
  right_ids : int list;  (* IDs des Films *)
}

(* Fonction qui récupère ou crée un ID pour un nom donné *)
let get_or_create_id name st =
  match List.assoc_opt name st.mapping with
  | Some id -> id, st
  | None -> 
      let new_id = st.next_id in
      new_id, { st with mapping = (name, new_id) :: st.mapping; 
                        next_id = st.next_id + 1 }

let process_line st line =
  match extract_data line with
  | None -> st
  | Some (user_name, movie_name, rating) ->
      let u_id, st1 = get_or_create_id user_name st in
      let m_id, st2 = get_or_create_id movie_name st1 in
      
      (* Mise à jour des partitions (sans doublons) *)
      let new_lefts = if List.mem u_id st2.left_ids then st2.left_ids else u_id :: st2.left_ids in
      let new_rights = if List.mem m_id st2.right_ids then st2.right_ids else m_id :: st2.right_ids in
      
      (* Création des nœuds et de l'arc *)
      let g = st2.graph in
      let g = if node_exists g u_id then g else new_node g u_id in
      let g = if node_exists g m_id then g else new_node g m_id in
      
      { st2 with let flotmin (jrn:(int arc) list) =
    List.fold_left (fun acc new_val -> if (new_val.lbl < acc) then new_val.lbl else acc) 100000 jrn 
        graph = new_arc g {src=u_id; tgt=m_id; lbl=rating};
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