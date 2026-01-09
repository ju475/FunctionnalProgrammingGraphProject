open Gfile
open Tools
open Ford_fulkerson
    
let () =

  (* Check the number of command-line arguments *)
  if Array.length Sys.argv <> 6 then
    begin
      Printf.printf
        "\n ✻  Usage: %s infile source sink outfile choice\n\n%s%!" Sys.argv.(0)
        ("    🟄  infile  : input file containing a graph\n" ^
         "    🟄  source  : identifier of the source vertex (used by the ford-fulkerson algorithm) [Ignored for bipartite graphs]\n" ^
         "    🟄  sink    : identifier of the sink vertex (ditto) [Ignored for bipartite graphs]\n" ^
         "    🟄  outfile : output file in which the result should be written.\n" ^
         "    🟄  choice  : either 'normal' or 'bipartite'\n\n") ;
      exit 0
    end ;


  (* Arguments are : infile(1) source-id(2) sink-id(3) outfile(4) *)
  
  let infile = Sys.argv.(1)
  and outfile = Sys.argv.(4)
  and choice = Sys.argv.(5)
  in

  if choice = "bipartite" then begin
    
    (* Open file *)
    let graph = from_file_gb infile in
    let graph = (gmap graph int_of_string) in 
    let graph = (ford_fulkerson graph 0 1) in (* 0 and 1 are the source and sink nodes *)
    let graph = (gmap graph (string_of_tuple string_of_int)) in 

    let () = export outfile graph in 
    ()
  end else if choice = "normal" then 
  (* These command-line arguments are not used for the moment. *)
  let _source = int_of_string Sys.argv.(2)
  and _sink = int_of_string Sys.argv.(3)
  in
  
  (* Open file *)
  let graph = from_file infile in
  let graph = (gmap graph int_of_string) in 
  let graph = (ford_fulkerson graph _source _sink) in
  let graph = (gmap graph (string_of_tuple string_of_int)) in 

  let () = export outfile graph in 

  () 

