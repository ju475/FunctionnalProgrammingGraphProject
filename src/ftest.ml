open Gfile
open Tools
open Ford_fulkerson
    
let () =

  (* Check the number of command-line arguments *)
  if Array.length Sys.argv <> 5 then
    begin
      Printf.printf
        "\n ✻  Usage: %s infile source sink outfile\n\n%s%!" Sys.argv.(0)
        ("    🟄  infile  : input file containing a graph\n" ^
         "    🟄  source  : identifier of the source vertex (used by the ford-fulkerson algorithm)\n" ^
         "    🟄  sink    : identifier of the sink vertex (ditto)\n" ^
         "    🟄  outfile : output file in which the result should be written.\n\n") ;
      exit 0
    end ;


  (* Arguments are : infile(1) source-id(2) sink-id(3) outfile(4) *)
  
  let infile = Sys.argv.(1)
  and outfile = Sys.argv.(4)
  
  (* These command-line arguments are not used for the moment. *)
  and _source = int_of_string Sys.argv.(2)
  and _sink = int_of_string Sys.argv.(3)
  in

  (* Open file *)
  let graph = from_file infile in
  let graph = (gmap graph int_of_string) in 
  let graph = (cap2flot graph) in
  let graph = (flot2ecart graph) in
  let graph = (chemin2graph graph) in
  let graph = (gmap graph string_of_int) in 

  (* let graph2 = (gmap graph (fun x->  
    string_of_int(int_of_string(x)+2))) in *)
  (* Rewrite the graph that has been read. *)
  let () = export outfile graph in

  ()



