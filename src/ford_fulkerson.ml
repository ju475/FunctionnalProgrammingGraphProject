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
 

let flotmin (jrn:(int arc) list) =
    List.fold_left (fun acc new_val -> if (new_val.lbl < acc) then new_val.lbl else acc) (int_of_float infinity) jrn 

(*
let rec journey (eg:ecart_graph) (srcNode:id) (tgtNode:id) =
    (* we need to add a accu for the visited nodes and do a dfs*)
*)

let ford_fulkerson (cg:cap_graph) (srcNode:id) (tgtNode:id)  =
if not (node_exists cg srcNode) then raise (Graph_error "Source Node Not Exists")
    else if not (node_exists cg tgtNode) then raise (Graph_error "Target Node Not Exists")
    else let fg0 = cap2flot cg in 
    let eg0 = flot2ecart fg0 in
    let rec loop eg =
        let chemin = journey eg srcNode tgtNode in
        if chemin = [] then eg
        else
        let delta = flotmin chemin in 

         let deal a eg = 
            let eg_arcplus = add_arc eg a.src a.tgt delta in
            add_arc eg_arcplus a.tgt a.src (-delta)
        in 
        let eg = List.fold_left (fun eg1 a -> deal a eg1) eg chemin in 
        loop eg

    in loop eg0




