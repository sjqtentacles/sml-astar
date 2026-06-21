(* test.sml
   Test suite for sml-astar.  Tests Grid, AStar, and Dijkstra. *)

structure AstarTests =
struct

  fun eqCoord ((x1,y1) : int*int) (x2,y2) = x1 = x2 andalso y1 = y2

  fun run () =
    let
      (* ------------------------------------------------------------------ *)
      (* Grid tests                                                           *)
      (* ------------------------------------------------------------------ *)
      val () = Harness.section "Grid"

      (* 5x5 all-walkable grid *)
      val g5 = Grid.make 5 5 (fn _ => true)

      val () = Harness.check "grid center has 4 neighbors"
        (length (Grid.neighbors4 g5 (2, 2)) = 4)

      val () = Harness.check "grid corner has 2 neighbors (4-way)"
        (length (Grid.neighbors4 g5 (0, 0)) = 2)

      val () = Harness.check "grid corner has 3 neighbors (8-way)"
        (length (Grid.neighbors8 g5 (0, 0)) = 3)

      val () = Harness.check "grid center has 8 neighbors (8-way)"
        (length (Grid.neighbors8 g5 (2, 2)) = 8)

      val () = Harness.check "manhattan distance"
        (Real.== (Grid.manhattan (0,0) (3,4), 7.0))

      val () = Harness.check "manhattan same point"
        (Real.== (Grid.manhattan (2,3) (2,3), 0.0))

      (* Grid with wall: col 2 is all blocked *)
      val gWall = Grid.make 5 5 (fn (x, _) => x <> 2)

      val () = Harness.check "blocked cell has 3 neighbors from left"
        (length (Grid.neighbors4 gWall (1, 2)) = 3)  (* left/up/down reachable, right is wall *)

      (* ------------------------------------------------------------------ *)
      (* AStar tests                                                          *)
      (* ------------------------------------------------------------------ *)
      val () = Harness.section "AStar"

      (* Helper: neighbours on 5x5 all-walkable grid *)
      val nbrs5 = Grid.neighbors4 g5
      val heur  = Grid.manhattan

      (* Trivial: start = goal *)
      val () =
        let
          val res = AStar.find nbrs5 heur eqCoord (0,0) (0,0)
        in
          Harness.check "start=goal returns singleton path"
            (case res of SOME [(pt, c)] => eqCoord pt (0,0) andalso Real.== (c, 0.0)
                       | _ => false)
        end

      (* Path from (0,0) to (4,4) on all-walkable 5x5 *)
      val () =
        let
          val res = AStar.find nbrs5 heur eqCoord (0,0) (4,4)
        in
          Harness.check "path exists from (0,0) to (4,4)"
            (case res of SOME _ => true | NONE => false)
        end

      (* Path ends at goal *)
      val () =
        let
          val res = AStar.find nbrs5 heur eqCoord (0,0) (4,4)
        in
          Harness.check "path ends at (4,4)"
            (case res of
               SOME path =>
                 (case List.rev path of
                    (last, _) :: _ => eqCoord last (4,4)
                  | [] => false)
             | NONE => false)
        end

      (* Path starts at start *)
      val () =
        let
          val res = AStar.find nbrs5 heur eqCoord (0,0) (4,4)
        in
          Harness.check "path starts at (0,0)"
            (case res of
               SOME ((first, _) :: _) => eqCoord first (0,0)
             | _ => false)
        end

      (* Optimal length: Manhattan distance on grid = 8 steps, 9 nodes *)
      val () =
        let
          val res = AStar.find nbrs5 heur eqCoord (0,0) (4,4)
        in
          Harness.check "optimal path has 9 nodes (distance 8)"
            (case res of SOME path => length path = 9 | NONE => false)
        end

      (* Cost at end = 8.0 *)
      val () =
        let
          val res = AStar.find nbrs5 heur eqCoord (0,0) (4,4)
        in
          Harness.check "optimal path cost = 8.0"
            (case res of
               SOME path =>
                 (case List.rev path of
                    (_, c) :: _ => Real.== (c, 8.0)
                  | [] => false)
             | NONE => false)
        end

      (* Unreachable: vertical wall at x=2, trying to reach x=4 from x=0 *)
      val nbrsWall = Grid.neighbors4 gWall
      val () =
        let
          val res = AStar.find nbrsWall heur eqCoord (0,2) (4,2)
        in
          Harness.check "unreachable goal returns NONE"
            (case res of NONE => true | SOME _ => false)
        end

      (* ------------------------------------------------------------------ *)
      (* Dijkstra tests                                                       *)
      (* ------------------------------------------------------------------ *)
      val () = Harness.section "Dijkstra"

      val allReachable = Dijkstra.sssp nbrs5 eqCoord (0,0)

      val () = Harness.check "Dijkstra finds all 25 nodes on 5x5"
        (length allReachable = 25)

      val () = Harness.check "Dijkstra source has distance 0"
        (case List.find (fn (n,_) => eqCoord n (0,0)) allReachable of
           SOME (_, d) => Real.== (d, 0.0)
         | NONE => false)

      val () = Harness.check "Dijkstra (4,4) has distance 8"
        (case List.find (fn (n,_) => eqCoord n (4,4)) allReachable of
           SOME (_, d) => Real.== (d, 8.0)
         | NONE => false)

      val () = Harness.check "Dijkstra (2,3) has distance 5"
        (case List.find (fn (n,_) => eqCoord n (2,3)) allReachable of
           SOME (_, d) => Real.== (d, 5.0)
         | NONE => false)

      (* With wall: only left side reachable *)
      val wallReachable = Dijkstra.sssp nbrsWall eqCoord (0,2)

      val () = Harness.check "Dijkstra with wall: right side unreachable"
        (not (List.exists (fn (n,_) => eqCoord n (4,2)) wallReachable))

      val () = Harness.check "Dijkstra with wall: left side reachable"
        (List.exists (fn (n,_) => eqCoord n (1,4)) wallReachable)

    in
      ()
    end

end
