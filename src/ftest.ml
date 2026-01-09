open Gfile
open Graph
open Bipartite_graph
open Tools
open Ford_fulkerson

(* ---------- Utils de test ---------- *)

let fail msg =
  Printf.printf "❌ %s\n%!" msg;
  exit 1

let ok msg =
  Printf.printf "✔ %s\n%!" msg

(* ---------- Vérifications ---------- *)

let check_arc_constraints g =
  e_iter g (fun arc ->
    let (f, c) = arc.lbl in
    if f < 0 || f > c then
      fail (Printf.sprintf
        "Invalid flow on arc %d -> %d : f=%d c=%d"
        arc.src arc.tgt f c)
  )

let flow_balance g source sink =
  let balance = Hashtbl.create 16 in

  n_iter g (fun id -> Hashtbl.add balance id 0);

  e_iter g (fun arc ->
    let (f, _) = arc.lbl in
    Hashtbl.replace balance arc.src (Hashtbl.find balance arc.src - f);
    Hashtbl.replace balance arc.tgt (Hashtbl.find balance arc.tgt + f);
  );

  Hashtbl.iter (fun v b ->
    if v <> source && v <> sink && b <> 0 then
      fail (Printf.sprintf
        "Flow conservation violated at node %d (balance=%d)" v b)
  ) balance

let total_flow_from_source g source =
  let sum = ref 0 in
  e_iter g (fun arc ->
    if arc.src = source then
      let (f, _) = arc.lbl in sum := !sum + f
  );
  !sum

(* ---------- Test sur un fichier ---------- *)

let test_bgraph file source sink =
  Printf.printf "\n🔎 Testing bipartite graph: %s\n" file;

  let g = from_file_gb file in
  let cap_graph = gmap g int_of_string in

  if (not (is_bipartite cap_graph)) then begin
    Printf.printf "⚠ Graph is not bipartite → test skipped";
  end else begin
  ok "Bipartite property OK";

  (* Vérification du chemin *)
  let eg = flot2ecart (cap2flot cap_graph) in
  if journey eg source sink = [] then begin
    Printf.printf "⚠ No path from %d to %d → test skipped\n" source sink;
  end else begin
    try
      let flot_graph = ford_fulkerson cap_graph source sink in

      check_arc_constraints flot_graph;
      ok "Capacities respected";

      flow_balance flot_graph source sink;
      ok "Flow conservation OK";

      let f = total_flow_from_source flot_graph source in
      Printf.printf "➡ Max flow = %d\n" f

    with
    | Graph_error msg ->
        fail ("Ford-Fulkerson raised Graph_error: " ^ msg)
  end
  end

let test_graph file source sink =
  Printf.printf "\n🔎 Testing graph: %s\n" file;

  let g = from_file file in
  let cap_graph = gmap g int_of_string in

  (* Vérification du chemin *)
  let eg = flot2ecart (cap2flot cap_graph) in
  if journey eg source sink = [] then begin
    Printf.printf "⚠ No path from %d to %d → test skipped\n" source sink;
  end else begin
    try
      let flot_graph = ford_fulkerson cap_graph source sink in

      check_arc_constraints flot_graph;
      ok "Capacities respected";

      flow_balance flot_graph source sink;
      ok "Flow conservation OK";

      let f = total_flow_from_source flot_graph source in
      Printf.printf "➡ Max flow = %d\n" f

    with
    | Graph_error msg ->
        fail ("Ford-Fulkerson raised Graph_error: " ^ msg)
  end

  

(* ---------- Main ---------- *)

let () =

  (* Check the number of command-line arguments *)
  if Array.length Sys.argv <> 2 then
    begin
      Printf.printf
        "\n ✻  Usage: %s choice\n\n%s%!" Sys.argv.(0)
        ("   🟄  choice : choose between performs FF on normal graphs or bipartite graphs.\n\n") ;
      exit 0
    end ;
  let choice = Sys.argv.(1) in
  if choice <> "bipartite" && choice <> "normal" then
    begin
      Printf.printf
        "\n ✻  Usage: %s choice\n\n%s%!" Sys.argv.(0)
        ("   🟄  choice : choose between performs FF on normal graphs or bipartite graphs.\n\n") ;
      exit 0
    end ;
    
  if choice = "bipartite" then
    begin
      print_endline "===== Ford–Fulkerson automatic tests on Bipartite Graphs =====";

      test_bgraph "graphs-bipartite/ressources/graph1b.txt" 0 1; (* 0 and 1 are the source and sink nodes *)
      test_bgraph "graphs-bipartite/ressources/graph2b.txt" 0 1;
      test_bgraph "graphs-bipartite/ressources/graph3b.txt" 0 1;
      test_bgraph "graphs-bipartite/ressources/graph4b.txt" 0 1;
      test_bgraph "graphs-bipartite/ressources/graph5b.txt" 0 1;

      print_endline "\n🎉 All tests on Bipartite Graphs passed successfully!"
    end
  else begin
  print_endline "===== Ford–Fulkerson automatic tests =====";

  test_graph "graphs/ressources/graph1.txt" 0 5;
  test_graph "graphs/ressources/graph2.txt" 0 12;
  test_graph "graphs/ressources/graph3.txt" 0 1;
  test_graph "graphs/ressources/graph4.txt" 0 5;
  test_graph "graphs/ressources/graph5.txt" 0 5;
  test_graph "graphs/ressources/graph6.txt" 0 5;
  test_graph "graphs/ressources/graph7.txt" 0 9;
  test_graph "graphs/ressources/graph8.txt" 0 3;
  test_graph "graphs/ressources/graph9.txt" 0 3;
  test_graph "graphs/ressources/graph10.txt" 0 7;

  print_endline "\n🎉 All tests passed successfully!" 
end
