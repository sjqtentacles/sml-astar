(* demo.sml - A* pathfinding and Dijkstra single-source shortest paths over an
   8-connected grid with an obstacle. Deterministic: no RNG, no clock. Real
   costs are printed with a forced-decimal formatter (fixed 4 places, leading
   '-' rather than SML's '~') so output is byte-identical on MLton and Poly/ML. *)

fun fmtReal n r =
  let val s = Real.fmt (StringCvt.FIX (SOME n)) r
  in if String.isPrefix "~" s then "-" ^ String.extract (s, 1, NONE) else s end

fun pInt i = Int.toString i
fun pNode (x, y) = "(" ^ pInt x ^ "," ^ pInt y ^ ")"
fun eqNode (x1, y1) (x2, y2) = x1 = x2 andalso y1 = y2

(* 6x6 grid, all walkable except a wall column at x=3 for rows 0..4. *)
val g = Grid.make 6 6 (fn (x, y) => not (x = 3 andalso y <= 4))

val () = print "A* and Dijkstra on a 6x6 8-connected grid (wall column x=3, rows 0..4):\n\n"

val () =
  case AStar.find (Grid.neighbors8 g) Grid.manhattan eqNode (0, 0) (5, 5) of
    NONE => print "A*: no path\n"
  | SOME path =>
      let
        val route = String.concatWith " " (List.map (fn (n, _) => pNode n) path)
        val total = case List.last path of (_, c) => c
      in
        ( print "A* path (0,0) -> (5,5):\n"
        ; print ("  steps      = " ^ pInt (List.length path - 1) ^ "\n")
        ; print ("  total cost = " ^ fmtReal 4 total ^ "\n")
        ; print ("  route      = " ^ route ^ "\n") )
      end

val dists = Dijkstra.sssp (Grid.neighbors8 g) eqNode (0, 0)
fun distTo n = case List.find (fn (m, _) => eqNode m n) dists of
                 SOME (_, d) => fmtReal 4 d | NONE => "unreachable"

val () = print "\nDijkstra from (0,0):\n"
val () = print ("  reachable cells = " ^ pInt (List.length dists) ^ "\n")
val () = print ("  dist to (2,2)   = " ^ distTo (2, 2) ^ "\n")
val () = print ("  dist to (5,0)   = " ^ distTo (5, 0) ^ "\n")
val () = print ("  dist to (5,5)   = " ^ distTo (5, 5) ^ "\n")
