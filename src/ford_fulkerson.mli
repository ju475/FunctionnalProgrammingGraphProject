open Graph 

type cap_graph = int graph

type flot_graph = (int * int) graph

type ecart_graph = int graph

val cap2flot: cap_graph -> flot_graph 

 
val flot2ecart: flot_graph -> ecart_graph

val flotmin: (int arc) list -> int 

val journey: ecart_graph -> id -> id -> (int arc) list

val ford_fulkerson: cap_graph -> id -> id -> ecart_graph





 

