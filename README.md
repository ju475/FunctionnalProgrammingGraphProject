# Ford Fulkerson & Targeted ads with bi-partite graph

##  Project Overview

This project implements the **Ford-Fulkerson** algorithm in OCaml to solve max-flow problems. The primary application is a **targeted advertisement system**: using a bipartite graph, the algorithm determines the optimal distribution of free movie coupons to users based on their viewing history and preferences.


## Actual Features

* **Core Algorithm**: Full implementation of Ford-Fulkerson using residual(ecart) graphs.

* **Graph Logic**: Fully abstract graph data type with modular iterators (`n_fold`, `e_fold`).

* **Bipartite Matching**: Tools to verify if a graph is bipartite and solve matching problems.

* **Graph Visualization & Export**: Export tools to `.dot` format (compatible with Graphviz) to visualize the flow results.

* **Log Processing**: A logging system to build a bipartite graph matching users with the best available movie coupons based on their log (containing rate and movie's name).

## Requirements

This project is built with **OCaml**. 

It is recommended to use **VSCode** with the *OCaml Platform* extension.

To build and run the project you will need **Dune** and **Make**.

--- 

## Compilation & Usage

### Build
* `make build1`: Compile **fdemo.exe** (main program).
* `make build2`: Compile **ftest.exe** (test suite).
* `make clean`: Remove build artifacts.

### Execution (Demos)
Run the algorithm with automatic SVG generation (stored in `svg_output/`):
* **Standard Ford Fulkerson**: `make demoFF graph=<graph> src=<src> dst=<dst>` but you can also try it without any argument.
* **Bipartite Matching**: `make demoGB graph=<graph> ` but you can also try it without any argument.
* **Log System**: `make demoLog log=<log>`

### Validation
Run automated checks for flow conservation and capacity constraints:
* `make testFF` (Normal graphs) | `make testGB` (Bipartite graphs)

## Note
The interest graph part is not intended for submission, we tried to go further but we've encountered difficulties developping 
the functions (actuals ones are made by LLM). 