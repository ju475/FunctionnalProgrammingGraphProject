open Graph
open Tools

type cap_graph = int graph 

type flot_graph = (int*int) graph 

type ecart_graph = int graph 

let cap2flot (cg :cap_graph)  =
    gmap cg (fun (x:int) -> (0,x))

let flot2ecart (fg :flot_graph) =

    let add_forward newg a = new_arc newg {src=a.src; tgt= a.tgt; lbl= (match a.lbl with |(x,y)->y-x)} in
    let add_backward newg a = new_arc newg {src=a.tgt; tgt= a.src; lbl= (match a.lbl with |(x,_)->x)} in
    let add_both newg a  = (add_backward (add_forward newg a) a)
in
    e_fold fg add_both (clone_nodes fg) 
 


let ecart2flot (cg : cap_graph) (eg : ecart_graph) =
  let add_arc newg ca =
      match find_arc eg ca.src ca.tgt with
        |Some ea -> new_arc newg { src = ca.src; tgt = ca.tgt; lbl = ((ca.lbl-ea.lbl), ca.lbl) }
        |None -> newg
  in
  e_fold cg add_arc (clone_nodes cg)


let mapi f i l =
    f (List.nth l i)

let rec dfs (eg:ecart_graph) (srcNode:id) (tgtNode:id) (visiting:int) (acc:(int arc) list) =
    if srcNode == tgtNode then acc (*Si on est arrivé, on renvoie le chemin courant*)
    else
        let l_arc = out_arcs eg srcNode in (*On recup les arcs sortants*)
        if (visiting>(List.length l_arc)-1) then [] (*Si on s'apprete a visité un arc qui n'existe pas*)
        else 
            let arc2visit = (List.nth l_arc visiting) in
            if List.fold_left (fun ans arc -> match arc with 
                | {src=s;tgt=_;lbl=_} -> ans || s==arc2visit.src || arc2visit.lbl==0) false acc then (dfs eg srcNode tgtNode (visiting+1) acc)
            (*Si on observe un arc qui amème à un noeud deja visité OU le label = 0 *)            
            else
                
                if (l_arc == []) then [] (* Si on est à la fin du chemin, soit arrivé, soit backtrack *)
                else
                    let currentChemin = (mapi (fun arc ->(dfs (eg) (arc.tgt) (tgtNode) 0 (arc::acc))) visiting l_arc) in (* Si on peut aller plus loin *)   
                    match currentChemin with
                        | [] -> dfs eg srcNode tgtNode (visiting+1) acc (* Si pas de chemin possible et pas d'autre arc dispo, backtrack, sinon on tente sur l'arc d'apres*)
                        | _ ->  currentChemin


 
let journey (eg:ecart_graph) (srcNode:id) (tgtNode:id) =
    (* we need to add a accu for the visited nodes and do a dfs*)
    dfs eg srcNode tgtNode 0 []


let flotmin (jrn:(int arc) list) =
    List.fold_left (fun acc new_val -> if (new_val.lbl < acc) then new_val.lbl else acc) (int_of_float infinity) jrn 

let ford_fulkerson (cg:cap_graph) (srcNode:id) (tgtNode:id)  =
if not (node_exists cg srcNode) then raise (Graph_error "Source Node Not Exists")
    else if not (node_exists cg tgtNode) then raise (Graph_error "Target Node Not Exists")
    else let ff () = let fg0 = cap2flot cg in 
    let eg0 = flot2ecart fg0 in
    let rec loop eg =
        let () = Printf.printf "before journey \n %!" in
        let chemin = journey eg srcNode tgtNode in
        let schemin = String.concat ";" (List.map (fun arc -> string_of_int arc.tgt) chemin) in
        print_endline schemin ;
        if chemin = [] then eg
        else
            (* on calcul la capacité maximal utilisable (donc le min sur le chemin) *)
        let delta = flotmin chemin in 
            let () = Printf.printf "delta = %d \n %!" delta in 
            (* on enleve delta (la valeur du flot) sur chaque arretes ou l'on passe et on l'ajoute aux arretes retour *)
         let deal a eg = 
            let eg_arcplus = add_arc eg a.src a.tgt delta in
            add_arc eg_arcplus a.tgt a.src (-delta)
        in 
        let eg = List.fold_left (fun eg1 a -> deal a eg1) eg chemin in 
        loop eg

    in loop eg0
in ecart2flot cg (ff ())




