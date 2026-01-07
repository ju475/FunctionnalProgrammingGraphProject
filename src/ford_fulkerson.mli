open Graph 

type cap_graph = int graph

type flot_graph = (int * int) graph

type ecart_graph = int graph

(* Creer le graphe de flot de type flot_graph à partir du graphe de capacite du type cap_graph*)
val cap2flot: cap_graph -> flot_graph 

 
val flot2ecart: flot_graph -> ecart_graph

val ecart2flot: cap_graph-> ecart_graph -> flot_graph

val flotmin: (int arc) list -> int 

val journey: ecart_graph -> id -> id -> (int arc) list

val ford_fulkerson: cap_graph -> id -> id -> flot_graph





 
 
