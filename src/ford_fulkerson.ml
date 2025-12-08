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



let ford_fulkerson (cg:cap_graph) (srcNode:id) (tgtNode:id)  =
if not (node_exists cg srcNode) then raise (Graph_error "Source Node Not Exists")
    else if not (node_exists cg tgtNode) then raise (Graph_error "Target Node Not Exists")
    else let fg = cap2flot cg in 
    let rec loop () =
        let eg = flot2ecart fg in
        let chemin = journey eg srcNode tgtNode in
        let delta = flotmin chemin in  
        let deal_delta fg a = if a.lbl > 0 then new_arc fg {src=a.src; tgt=a.tgt; lbl=a.lbl+delta} 
            else new_arc fg {src=a.tgt; tgt= a.src; lbl= a.lbl-delta} in 

            let update_flot = e_fold eg deal_delta fg
    in loop ()


let rec journey (eg:ecart_graph) (srcNode:id) (tgtNode:id) =
    (* we need to add a accu for the visited nodes and do a dfs*)



let flotmin (jrn:(int arc) list) =
    List.fold_left (fun acc new_val -> if (new_val.lbl < acc) then new_val.lbl else acc) (int_of_float infinity) jrn 
