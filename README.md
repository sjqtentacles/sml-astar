# sml-astar

[![CI](https://github.com/sjqtentacles/sml-astar/actions/workflows/ci.yml/badge.svg)](https://github.com/sjqtentacles/sml-astar/actions/workflows/ci.yml)

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

## Example

`make example` builds and runs [`examples/demo.sml`](examples/demo.sml), which
runs A* and Dijkstra over a 6x6 8-connected grid with a wall column, routing
around the obstacle. Real path costs are printed with a forced-decimal
formatter so the output is byte-identical on MLton and Poly/ML:

```
$ make example
A* and Dijkstra on a 6x6 8-connected grid (wall column x=3, rows 0..4):

A* path (0,0) -> (5,5):
  steps      = 7
  total cost = 8.2426
  route      = (0,0) (1,1) (2,2) (2,3) (2,4) (3,5) (4,5) (5,5)

Dijkstra from (0,0):
  reachable cells = 31
  dist to (2,2)   = 2.8284
  dist to (5,0)   = 12.0711
  dist to (5,5)   = 8.2426
```

## Testing

```
make test       # MLton
make test-poly  # Poly/ML
make example    # build + run the demo
```

## License

MIT
