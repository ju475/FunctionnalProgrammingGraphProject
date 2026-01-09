open Graph

let is_bipartite gr =
  (* tente de colorier un nœud et ses successeurs.
     Retourne (Some nouvelle_liste_couleurs) ou None en cas de conflit. *)
  let rec color_node id c colors =
    match List.assoc_opt id colors with
    | Some existing_color ->
        if existing_color = c then Some colors else None
    | None ->
        let colors = (id, c) :: colors in
        let neighbors = out_arcs gr id in
        (* On colorie tous les voisins récursivement avec la couleur opposée (1-c) *)
        color_neighbors neighbors (1 - c) colors

  and color_neighbors neighbors c colors =
    match neighbors with
    | [] -> Some colors
    | arc :: rest ->
        match color_node arc.tgt c colors with
        | None -> None
        | Some next_colors -> color_neighbors rest c next_colors
  in

  (* On parcourt tous les nœuds du graphe pour gérer les composantes disjointes *)
  let final_state = n_fold gr (fun acc_colors id ->
      match acc_colors with
      | None -> None (* Conflit déjà trouvé *)
      | Some colors ->
          if List.mem_assoc id colors then Some colors
          else color_node id 0 colors
    ) (Some []) 
  in

  (* Si on termine avec Some, le graphe est biparti *)
  final_state <> None