(* astar.sig
   Signatures for A* pathfinding, Dijkstra SSSP, and a graph abstraction. *)

signature GRAPH =
sig
  type node
  val neighbors : node -> (node * real) list
  val heuristic : node -> node -> real
  val eq        : node -> node -> bool
  val hash      : node -> int
end

signature ASTAR =
sig
  val find : ('n -> ('n * real) list)
             -> ('n -> 'n -> real)
             -> ('n -> 'n -> bool)
             -> 'n -> 'n
             -> ('n * real) list option
end

signature DIJKSTRA =
sig
  val sssp : ('n -> ('n * real) list)
             -> ('n -> 'n -> bool)
             -> 'n
             -> ('n * real) list
end
