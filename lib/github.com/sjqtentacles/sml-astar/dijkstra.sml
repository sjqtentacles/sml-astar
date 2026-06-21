(* dijkstra.sml
   Dijkstra single-source shortest paths.

   Returns a list of (node, distance) pairs for all nodes reachable from the
   source.  The open set is a sorted list (ascending distance), exactly like
   the A* implementation. *)

structure Dijkstra : DIJKSTRA =
struct

  fun insertSorted (entry as (d : real, _)) [] = [entry]
    | insertSorted (entry as (d : real, _)) ((x as (dx, _)) :: rest) =
        if d <= dx then entry :: x :: rest
        else x :: insertSorted entry rest

  fun sssp neighbors eq start =
    let
      fun memberVisited node visited =
        List.exists (fn (n, _) => eq n node) visited

      fun loop [] visited = visited
        | loop ((_, node) :: rest) visited =
            if memberVisited node visited
            then loop rest visited
            else
              let
                val dist =
                  case List.find (fn (n, _) => eq n node) (map (fn (d, n) => (n, d)) rest) of
                    NONE =>
                      (* look up from our current front – it's the d we popped *)
                      (* Actually we need to track distance differently *)
                      0.0
                  | SOME (_, d) => d
              in
                loop rest visited
              end

      (* Better: store (dist, node) and track dist explicitly *)
      fun loop2 [] visited = visited
        | loop2 ((dist, node) :: rest) visited =
            if memberVisited node visited
            then loop2 rest visited
            else
              let
                val visited' = (node, dist) :: visited
                val nbrs = neighbors node
                fun expand (nbr, cost) =
                  if memberVisited nbr visited'
                  then NONE
                  else SOME (dist + cost, nbr)
                val newEntries = List.mapPartial expand nbrs
                val open' =
                  List.foldl (fn (e, acc) => insertSorted e acc) rest newEntries
              in
                loop2 open' visited'
              end
    in
      loop2 [(0.0, start)] []
    end

end
