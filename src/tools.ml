open Graph

(* assert false is of type ∀α.α, so the type-checker is happy. *)
(* 
let clone_nodes _gr = assert false
let gmap _gr _f = assert false
*)



let clone_nodes (gr : 'a graph) =
  n_fold gr (fun newg id -> new_node newg id) empty_graph

let gmap gr f = 
  e_fold gr (fun newg a -> new_arc newg {src=a.src; tgt= a.tgt; lbl=f a.lbl}) (clone_nodes gr)

let add_arc g id1 id2 n =
  let a = find_arc g id1 id2 in
  match a with 
  |None -> new_arc g {src=id1;tgt=id2;lbl=n}
  |Some ar -> new_arc g {src=ar.src; tgt=ar.tgt; lbl=(ar.lbl+n) }

let string_of_tuple f (a,b)  =
    "("^ (f a) ^"/"^ (f b)^ ")"

let chemin2graph c = 
  List.map (fun arc -> (arc.src,[arc])) c