# sml-astar

Generic A* and Dijkstra pathfinding with 2D grid support in pure Standard ML

## Installation

```
smlpkg add github.com/sjqtentacles/sml-astar
smlpkg sync
```

## Usage

```sml
(* --- 2D grid pathfinding --- *)

(* Create a 10x10 grid; (fn _ => true) means all cells walkable *)
val g = Grid.make 10 10 (fn _ => true)

(* Build a grid with a wall at column 5 *)
val gWall = Grid.make 10 10 (fn (x, _) => x <> 5)

(* 4-way and 8-way neighbor lists *)
val nbrs4 = Grid.neighbors4 g (3, 3)   (* up/down/left/right *)
val nbrs8 = Grid.neighbors8 g (3, 3)   (* + diagonals *)

(* A* search: neighbors, heuristic, equality, start, goal *)
val path = AStar.find
  (Grid.neighbors8 g)      (* neighbor function: node -> (node * real) list *)
  Grid.euclidean            (* heuristic *)
  (fn (x1,y1) (x2,y2) => x1=x2 andalso y1=y2)
  (0, 0) (9, 9)
(* => SOME [(0,0), (1,1), ..., (9,9)] with costs, or NONE if no path *)

(* Dijkstra single-source shortest paths *)
val dists = Dijkstra.sssp
  (Grid.neighbors4 g)
  (fn (x1,y1) (x2,y2) => x1=x2 andalso y1=y2)
  (0, 0)
(* => list of ((x,y), distance) for all reachable cells *)
```

## Testing

```
make test       # MLton
make test-poly  # Poly/ML
```

## License

MIT
