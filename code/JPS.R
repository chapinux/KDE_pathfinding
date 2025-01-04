# Helper Functions for Pathfinding
start_time <- Sys.time()
# Function to calculate Euclidean distance between two nodes
euclidean_distance <- function(row1, col1, row2, col2) {
  return(sqrt((row1 - row2)^2 + (col1 - col2)^2))
}

# Heuristique basée sur la distance euclidienne entre les positions de la grille
euclidean_heuristic <- function(start, goal, grid_cols, grid_rows) {
  start_coords <- get_coordinates(start, grid_cols, grid_rows)
  goal_coords <- get_coordinates(goal, grid_cols, grid_rows)
  return(euclidean_distance(start_coords[1], start_coords[2], goal_coords[1], goal_coords[2]))
}

a_star <- function(graph, heuristic, start, goal, grid_cols, grid_rows, avoid_node = NULL) {
  validate_node(start, grid_cols, grid_rows)
  validate_node(goal, grid_cols, grid_rows)
  
  distances <- rep(Inf, length(graph))
  distances[start] <- 0
  priorities <- rep(Inf, length(graph))
  priorities[start] <- heuristic(start, goal, grid_cols, grid_rows)
  visited <- rep(FALSE, length(graph))
  predecessors <- rep(NA, length(graph))
  
  repeat {
    lowest_priority <- Inf
    lowest_priority_index <- -1
    
    for (i in seq_along(priorities)) {
      if (priorities[i] < lowest_priority && visited[i] == FALSE) {
        lowest_priority <- priorities[i]
        lowest_priority_index <- i
      }
    }
    
    if (lowest_priority_index == -1) {
      return(list(path = NULL, cost = -1))  # Aucun chemin trouvé
    }
    
    if (lowest_priority_index == goal) {
      path <- c()
      current <- goal
      while (!is.na(current)) {
        path <- c(current, path)
        current <- predecessors[current]
      }
      return(list(path = path, cost = distances[goal]))
    }
    
    current_node <- lowest_priority_index
    for (neighbor in graph[[current_node]]) {
      neighbor_node <- neighbor$node
      neighbor_distance <- neighbor$distance
      
      # Ignore le `avoid_node` s'il est défini
      
      if (visited[neighbor_node] == FALSE) {
        new_distance <- distances[current_node] + neighbor_distance
        if (new_distance < distances[neighbor_node]) {
          distances[neighbor_node] <- new_distance
          priorities[neighbor_node] <- new_distance + heuristic(neighbor_node, goal, grid_cols, grid_rows)
          predecessors[neighbor_node] <- current_node
        }
      }
    }
    visited[lowest_priority_index] <- TRUE
  }
}


# Get coordinates of a node in a 2D grid
get_coordinates <- function(node, grid_cols, grid_rows) {
  validate_node(node, grid_cols, grid_rows)
  row <- (node - 1) %/% grid_cols
  col <- (node - 1) %% grid_cols
  return(c(row, col))
}

# Get direction from node x to node n
get_direction <- function(x, n, grid_cols, grid_rows) {
  coords_x <- get_coordinates(x, grid_cols, grid_rows)
  coords_n <- get_coordinates(n, grid_cols, grid_rows)
  direction <- coords_n - coords_x
  return(direction)
}

# Validate node index
validate_node <- function(node, grid_cols, grid_rows) {
  total_nodes <- grid_cols * grid_rows
  if (node < 1 || node > total_nodes) {
    return(NULL)
  }
}

# Step function to move in a given direction
step <- function(x, direction, grid_cols, grid_rows) {
  n <- x + direction[1] * grid_cols + direction[2]
  validate_node(n, grid_cols, grid_rows)
  return(n)
}

# Function to prune unnecessary neighbors (based on JPS pruning rules)
prune_neighbors <- function(p_x, x, neighbors, adjacency_list, grid_cols, grid_rows) {
  pruned_neighbors <- list()
  for (n in neighbors) {
    if (n == x) next
    dist_p_x_x <- a_star(adjacency_list, euclidean_heuristic, p_x, x, grid_cols, grid_rows)$cost
    dist_x_n <- a_star(adjacency_list, euclidean_heuristic, x, n, grid_cols, grid_rows, avoid_node = x)$cost
    dist_p_x_n <- a_star(adjacency_list, euclidean_heuristic, p_x, n, grid_cols, grid_rows, avoid_node = x)$cost
    if (dist_p_x_n > dist_p_x_x + dist_x_n) {
      pruned_neighbors <- append(pruned_neighbors, list(n))
    }
  }
  return(pruned_neighbors)
}

# Function to identify forced neighbors (important for JPS)
is_forced_neighbor <- function(p_x, x, n, adjacency_list, grid_cols, grid_rows) {
  dist_p_x_n <- a_star(adjacency_list, euclidean_heuristic, p_x, n, grid_cols, grid_rows, avoid_node = x)$cost
  dist_p_x_x <- a_star(adjacency_list, euclidean_heuristic, p_x, x, grid_cols, grid_rows)$cost
  dist_x_n <- a_star(adjacency_list, euclidean_heuristic, x, n, grid_cols, grid_rows, avoid_node = x)$cost
  return(dist_p_x_n > dist_p_x_x + dist_x_n)
}



# Recursive Jump function for JPS
jump <- function(x, direction, grid_cols, grid_rows, goal, adjacency_list) {
  cat("Jump called: x =", x, "direction =", direction, "\n")
  n <- step(x, direction, grid_cols, grid_rows)
  
  if (is.null(n) || n %in% obstacles || n <= 0) {
    cat("Jump terminated: Out of bounds or obstacle at n =", n, "\n")
    return(NULL)
  }
  
  # Check if goal is reached
  if (n == goal) {
    cat("Jump found goal at n =", n, "\n")
    return(n)
  }
  
  neighbors <- unlist(lapply(adjacency_list[[n]], function(neighbor) neighbor$node))
  for (neighbor in neighbors) {
    if (is_forced_neighbor(x, n, neighbor, adjacency_list, grid_cols, grid_rows)) {
      cat("Jump found forced neighbor at n =", n, "\n")
      return(n)
    }
  }
  
  # If moving diagonally, check orthogonal directions
  if (abs(direction[1]) == 1 && abs(direction[2]) == 1) {
    orthogonal1 <- jump(n, c(direction[1], 0), grid_cols, grid_rows, goal, adjacency_list)
    orthogonal2 <- jump(n, c(0, direction[2]), grid_cols, grid_rows, goal, adjacency_list)
    if (!is.null(orthogonal1) || !is.null(orthogonal2)) {
      cat("Jump found diagonal forced neighbor at n =", n, "\n")
      return(n)
    }
  }
  
  return(jump(n, direction, grid_cols, grid_rows, goal, adjacency_list))
}

# Identify successors using JPS
identify_successors <- function(x, start, goal, adjacency_list, grid_cols, grid_rows) {
  successors <- list()
  neighbors_of_x <- unlist(lapply(adjacency_list[[x]], function(neighbor) neighbor$node))
  neighbors <- prune_neighbors(start, x, neighbors_of_x, adjacency_list, grid_cols, grid_rows)
  for (n in neighbors) {
    direction <- get_direction(x, n, grid_cols, grid_rows)
    jump_point <- jump(x, direction, grid_cols, grid_rows, goal, adjacency_list)
    if (!is.null(jump_point)) {
      successors <- append(successors, list(jump_point))
    }
  }
  return(successors)
}



# A* Algorithm with JPS
a_star_jps <- function(graph, heuristic, start, goal, grid_cols, grid_rows, obstacles = NULL) {
  validate_node(start, grid_cols, grid_rows)
  validate_node(goal, grid_cols, grid_rows)
  
  distances <- rep(Inf, length(graph))
  distances[start] <- 0
  priorities <- rep(Inf, length(graph))
  priorities[start] <- heuristic(start, goal, grid_cols, grid_rows)
  visited <- rep(FALSE, length(graph))
  predecessors <- rep(NA, length(graph))
  open_list <- list(start)
  
  while (length(open_list) > 0) {
    # Get the node with the lowest priority
    current <- open_list[[1]]
    current_priority <- priorities[current]
    for (node in open_list) {
      if (priorities[node] < current_priority) {
        current <- node
        current_priority <- priorities[node]
      }
    }
    open_list <- open_list[open_list != current]
    
    if (current == goal) {
      path <- c()
      while (!is.na(current)) {
        path <- c(current, path)
        current <- predecessors[current]
      }
      return(list(path = path, cost = distances[goal]))
    }
    print(current)
    print(start)
    
    visited[current] <- TRUE
    successors <- unlist(lapply(adjacency_list[[current]], function(neighbor) neighbor$node))
    
    for (successor in successors) {
      if (visited[successor]) next
      direction <- get_direction(current, successor, grid_cols, grid_rows)
      move_cost <- sqrt(sum(direction^2))
      tentative_distance <- distances[current] + move_cost
      if (tentative_distance < distances[successor]) {
        distances[successor] <- tentative_distance
        priorities[successor] <- tentative_distance + heuristic(successor, goal, grid_cols, grid_rows)
        predecessors[successor] <- current
        if (!(successor %in% open_list)) {
          open_list <- append(open_list, successor)
        }
      }
    }
  }
  
  return(list(path = NULL, cost = -1))
}


plot_grid <- function(grid_rows, grid_cols, adjacency_list, start, goal, path = NULL, obstacles = NULL) {
  plot(1, type = "n", xlim = c(0, grid_cols - 1), ylim = c(0, grid_rows - 1),
       xlab = "Colonne", ylab = "Ligne", main = "Représentation de la grille avec départ, but et obstacles",
       xaxt = "n", yaxt = "n")
  
  for (node in 1:length(adjacency_list)) {
    coords <- c((node - 1) %/% grid_cols, (node - 1) %% grid_cols)
    color <- ifelse(node == start, "green", ifelse(node == goal, "red", ifelse(node %in% obstacles, "grey", "black")))
    points(coords[2], grid_rows - 1 - coords[1], pch = 19, col = color)
    
    if (!is.null(adjacency_list[[node]]) && !(node %in% obstacles)) {
      for (neighbor in adjacency_list[[node]]) {
        neighbor_coords <- c((neighbor$node - 1) %/% grid_cols, (neighbor$node - 1) %% grid_cols)
        segments(coords[2], grid_rows - 1 - coords[1], neighbor_coords[2], grid_rows - 1 - neighbor_coords[1], col = "grey")
      }
    }
  }
  
  text((start - 1) %% grid_cols, grid_rows - 1 - (start - 1) %/% grid_cols, labels = "D", pos = 3, col = "green", font = 2)
  text((goal - 1) %% grid_cols, grid_rows - 1 - (goal - 1) %/% grid_cols, labels = "B", pos = 3, col = "red", font = 2)
  
  if (!is.null(path)) {
    for (i in 1:(length(path) - 1)) {
      from <- path[i]
      to <- path[i + 1]
      from_coords <- c((from - 1) %/% grid_cols, (from - 1) %% grid_cols)
      to_coords <- c((to - 1) %/% grid_cols, (to - 1) %% grid_cols)
      segments(from_coords[2], grid_rows - 1 - from_coords[1], to_coords[2], grid_rows - 1 - to_coords[1], col = "blue", lwd = 2)
    }
  }
}

# Test the algorithm
grid_rows <- 6
grid_cols <- 6
obstacles <- c(2, 4, 6, 9, 11, 30, 22, 25, 18, 17, 16, 28, 27)
start <- 1
goal <- 36

# Generate adjacency list
adjacency_list <- vector("list", grid_rows * grid_cols)
for (node in 1:(grid_rows * grid_cols)) {
  if (node %in% obstacles) {
    adjacency_list[[node]] <- NULL
    next
  }
  node_coords <- get_coordinates(node, grid_cols, grid_rows)
  neighbors <- list()
  
  directions <- list(
    list(dir = c(-1, 0), cost = 1),       # Up
    list(dir = c(1, 0), cost = 1),        # Down
    list(dir = c(0, -1), cost = 1),       # Left
    list(dir = c(0, 1), cost = 1),        # Right
    list(dir = c(-1, 1), cost = sqrt(2)), # Diagonal Up-Right
    list(dir = c(-1, -1), cost = sqrt(2)),# Diagonal Up-Left
    list(dir = c(1, -1), cost = sqrt(2)), # Diagonal Down-Left
    list(dir = c(1, 1), cost = sqrt(2))   # Diagonal Down-Right
  )
  
  for (move in directions) {
    dir <- move$dir
    move_cost <- move$cost
    neighbor_coords <- node_coords + dir
    if (neighbor_coords[1] >= 0 && neighbor_coords[1] < grid_rows &&
        neighbor_coords[2] >= 0 && neighbor_coords[2] < grid_cols) {
      neighbor_index <- neighbor_coords[1] * grid_cols + neighbor_coords[2] + 1
      if (!(neighbor_index %in% obstacles)) {
        neighbors[[length(neighbors) + 1]] <- list(node = neighbor_index, distance = move_cost)
      }
    }
  }
  adjacency_list[[node]] <- neighbors
}

# Run the A* with JPS algorithm
result <- a_star(adjacency_list, euclidean_heuristic, start, goal, grid_cols, grid_rows, obstacles)
print(result$path)
print(result$cost)

# Plot the result
plot_grid(grid_rows, grid_cols, adjacency_list, start, goal, result$path, obstacles)

end_time <- Sys.time()
execution_time <- end_time - start_time  
print(paste("Temps d'exécution total :", execution_time))




