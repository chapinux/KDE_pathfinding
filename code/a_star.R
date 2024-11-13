# Dimensions de la grille
grid_rows <- 10
grid_cols <- 10
total_nodes <- grid_rows * grid_cols

# Liste des obstacles (noeuds inaccessibles)
obstacles <- c(22, 23, 24, 34, 44, 92, 47, 48, 49, 57, 66, 67, 76)

# Fonction pour calculer la distance euclidienne
euclidean_distance <- function(row1, col1, row2, col2) {
  return(sqrt((row1 - row2)^2 + (col1 - col2)^2))
}

# Fonction pour obtenir les coordonnées
get_coordinates <- function(node, grid_cols) {
  row <- (node - 1) %/% grid_cols
  col <- (node - 1) %% grid_cols
  return(c(row, col))
}

# Construction de la liste d'adjacence pour la grille avec obstacles
adjacency_list <- vector("list", total_nodes)
for (node in 1:total_nodes) {
  if (node %in% obstacles) {
    adjacency_list[[node]] <- NULL  # Pas de voisins pour les noeuds obstacles
    next
  }
  
  node_coords <- get_coordinates(node, grid_cols)
  neighbors <- list()
  
  # Directions pour les voisins, avec indication du type de mouvement
  directions <- list(
    list(dir = c(-1, 0), cost = 1),       # Haut
    list(dir = c(1, 0), cost = 1),        # Bas
    list(dir = c(0, -1), cost = 1),       # Gauche
    list(dir = c(0, 1), cost = 1),        # Droite
    list(dir = c(-1, 1), cost = sqrt(2)), # Haut à droite (diagonal)
    list(dir = c(-1, -1), cost = sqrt(2)),# Haut à gauche (diagonal)
    list(dir = c(1, -1), cost = sqrt(2)), # Bas à gauche (diagonal)
    list(dir = c(1, 1), cost = sqrt(2))   # Bas à droite (diagonal)
  )
  
  # Pour chaque direction, vérification du voisin dans les limites de la grille
  for (move in directions) {
    dir <- move$dir
    move_cost <- move$cost
    neighbor_coords <- node_coords + dir
    if (neighbor_coords[1] >= 0 && neighbor_coords[1] < grid_rows &&
        neighbor_coords[2] >= 0 && neighbor_coords[2] < grid_cols) {
      neighbor_index <- neighbor_coords[1] * grid_cols + neighbor_coords[2] + 1
      # Ignorer les voisins qui sont des obstacles
      if (!(neighbor_index %in% obstacles)) {
        neighbors[[length(neighbors) + 1]] <- list(node = neighbor_index, distance = move_cost)
      }
    }
  }
  adjacency_list[[node]] <- neighbors
}

# Afficher la liste d'adjacence pour vérifier les obstacles
print(adjacency_list[1])

# Algorithme A* pour la grille avec une heuristique euclidienne
a_star <- function(graph, heuristic, start, goal, grid_cols) {
  distances <- rep(Inf, length(graph))
  distances[start] <- 0
  priorities <- rep(Inf, length(graph))
  priorities[start] <- heuristic(start, goal, grid_cols)
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
      if (visited[neighbor_node] == FALSE) {
        new_distance <- distances[current_node] + neighbor_distance
        if (new_distance < distances[neighbor_node]) {
          distances[neighbor_node] <- new_distance
          priorities[neighbor_node] <- new_distance + heuristic(neighbor_node, goal, grid_cols)
          predecessors[neighbor_node] <- current_node
        }
      }
    }
    visited[lowest_priority_index] <- TRUE
  }
}

# Heuristique basée sur la distance euclidienne entre les positions de la grille
euclidean_heuristic <- function(start, goal, grid_cols) {
  start_coords <- get_coordinates(start, grid_cols)
  goal_coords <- get_coordinates(goal, grid_cols)
  return(euclidean_distance(start_coords[1], start_coords[2], goal_coords[1], goal_coords[2]))
}

# Fonction de visualisation pour la grille avec les obstacles
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

# Définition des noeuds de départ et but
start_node <- 1
goal_node <- 100

# Exécution
result <- a_star(adjacency_list, euclidean_heuristic, start_node, goal_node, grid_cols)
cat("Chemin :", result$path, "\n")
cat("Coût :", result$cost, "\n")

# Affichage
plot_grid(grid_rows, grid_cols, adjacency_list, start_node, goal_node, result$path, obstacles)
