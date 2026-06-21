(* grid.sml
   Grid structure for 2-D pathfinding.

   Cells are addressed as (col, row) pairs, i.e. (x, y) with x in [0,w)
   and y in [0,h).  Internally the walkable flags are stored in a row-major
   bool array: index = y*w + x. *)

structure Grid =
struct

  type grid = { w: int, h: int, walkable: bool array }

  fun make (w : int) (h : int) (isWalkable : int * int -> bool) : grid =
    let
      val arr = Array.tabulate (w * h, fn idx =>
        let
          val x = idx mod w
          val y = idx div w
        in
          isWalkable (x, y)
        end)
    in
      { w = w, h = h, walkable = arr }
    end

  fun isWalkable ({ w, h=_, walkable } : grid) (x, y) =
    x >= 0 andalso y >= 0 andalso
    x < w  andalso
    (let val idx = y * w + x
     in idx < Array.length walkable andalso Array.sub (walkable, idx)
     end)

  fun neighbors4 (grid as { w=_, h=_, walkable=_ } : grid) (x, y) =
    let
      val dirs = [(0, ~1), (0, 1), (~1, 0), (1, 0)]
      fun check (dx, dy) =
        let val nx = x + dx
            val ny = y + dy
        in
          if isWalkable grid (nx, ny) then SOME ((nx, ny), 1.0)
          else NONE
        end
    in
      List.mapPartial check dirs
    end

  fun neighbors8 (grid as { w=_, h=_, walkable=_ } : grid) (x, y) =
    let
      val sqrt2 = 1.4142135623730951
      val dirs = [ (0, ~1, 1.0),   (0, 1, 1.0),
                   (~1, 0, 1.0),   (1, 0, 1.0),
                   (~1, ~1, sqrt2), (1, ~1, sqrt2),
                   (~1, 1, sqrt2),  (1, 1, sqrt2) ]
      fun check (dx, dy, cost) =
        let val nx = x + dx
            val ny = y + dy
        in
          if isWalkable grid (nx, ny) then SOME ((nx, ny), cost)
          else NONE
        end
    in
      List.mapPartial check dirs
    end

  fun manhattan (x1, y1) (x2, y2) =
    Real.fromInt (abs (x1 - x2) + abs (y1 - y2))

end
