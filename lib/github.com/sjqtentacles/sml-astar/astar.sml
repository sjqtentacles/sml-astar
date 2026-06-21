(* astar.sml
   A* pathfinding algorithm.

   The open set is a sorted list of (f, g, node, path) entries, kept in
   ascending f-score order.  O(n) per insert but correct and simple for the
   small grids used in the test suite.

   The closed set is a list of already-expanded nodes so we never re-expand
   a node.  This is what guarantees termination when the goal is unreachable:
   eventually every reachable node gets expanded, the open set drains to [],
   and we return NONE. *)

structure AStar : ASTAR =
struct

  (* Insert entry into open set sorted ascending by f-score. *)
  fun insertSorted (entry as (f : real, _, _, _)) [] = [entry]
    | insertSorted (entry as (f : real, _, _, _)) ((x as (fx, _, _, _)) :: rest) =
        if f <= fx then entry :: x :: rest
        else x :: insertSorted entry rest

  fun find neighbors heuristic eq start goal =
    let
      fun member node lst = List.exists (fn n => eq n node) lst

      val startH = heuristic start goal
      val initial = [(startH, 0.0, start, [(start, 0.0)])]

      (* closed: list of nodes already expanded *)
      fun loop [] _ = NONE
        | loop ((_, g, node, path) :: rest) closed =
            if eq node goal
            then SOME path
            else if member node closed
            then loop rest closed
            else
              let
                val closed' = node :: closed
                fun expand (nbr, cost) =
                  if member nbr closed'
                  then NONE
                  else
                    let
                      val gNew = g + cost
                      val hNew = heuristic nbr goal
                      val fNew = gNew + hNew
                    in
                      SOME (fNew, gNew, nbr, path @ [(nbr, gNew)])
                    end
                val newEntries = List.mapPartial expand (neighbors node)
                val open' =
                  List.foldl (fn (e, acc) => insertSorted e acc) rest newEntries
              in
                loop open' closed'
              end
    in
      loop initial []
    end

end
