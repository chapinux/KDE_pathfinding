# Dimensions de la grille
grid_rows <- 3
grid_cols <- 3
total_nodes <- grid_rows * grid_cols

# Liste des obstacles (noeuds inaccessibles)
obstacles <- c(2)  # Définir les obstacles ici, si nécessaire

# Fonction pour calculer la distance euclidienne
euclidean_distance <- function(row1, col1, row2, col2) {
  return(sqrt((row1 - row2)^2 + (col1 - col2)^2))
}

# Fonction pour obtenir les coordonnées d’un noeud dans la grille
get_coordinates <- function(node, grid_cols, grid_rows) {
  validate_node(node, grid_cols, grid_rows)  # Vérifie l’index avant d’accéder aux coordonnées
  row <- (node - 1) %/% grid_cols
  col <- (node - 1) %% grid_cols
  return(c(row, col))
}

# Vérifie que l’index du noeud est dans les limites de la grille
validate_node <- function(node, grid_cols, grid_rows) {
  total_nodes <- grid_cols * grid_rows
  if (node < 1 || node > total_nodes) {
    stop(paste("Index de noeud invalide :", node, "doit être entre 1 et", total_nodes))
  }
}

# Construction de la liste d'adjacence pour la grille en prenant en compte les obstacles
adjacency_list <- vector("list", total_nodes)
for (node in 1:total_nodes) {
  if (node %in% obstacles) {
    adjacency_list[[node]] <- NULL  # Pas de voisins pour les noeuds obstacles
    next
  }
  
  node_coords <- get_coordinates(node, grid_cols, grid_rows)
  neighbors <- list()
  
  # Directions pour les voisins avec le coût du déplacement
  directions <- list(
    list(dir = c(-1, 0), cost = 1),       # Haut
    list(dir = c(1, 0), cost = 1),        # Bas
    list(dir = c(0, -1), cost = 1),       # Gauche
    list(dir = c(0, 1), cost = 1),        # Droite
    list(dir = c(-1, 1), cost = sqrt(2)), # Diagonale haut-droite
    list(dir = c(-1, -1), cost = sqrt(2)),# Diagonale haut-gauche
    list(dir = c(1, -1), cost = sqrt(2)), # Diagonale bas-gauche
    list(dir = c(1, 1), cost = sqrt(2))   # Diagonale bas-droite
  )
  
  # Pour chaque direction, vérifie les voisins dans les limites de la grille
  for (move in directions) {
    dir <- move$dir
    move_cost <- move$cost
    neighbor_coords <- node_coords + dir
    if (neighbor_coords[1] >= 0 && neighbor_coords[1] < grid_rows &&
        neighbor_coords[2] >= 0 && neighbor_coords[2] < grid_cols) {
      neighbor_index <- neighbor_coords[1] * grid_cols + neighbor_coords[2] + 1
      # Ignore les voisins qui sont des obstacles
      if (!(neighbor_index %in% obstacles)) {
        neighbors[[length(neighbors) + 1]] <- list(node = neighbor_index, distance = move_cost)
      }
    }
  }
  adjacency_list[[node]] <- neighbors
}

# Algorithme A* pour la grille avec une heuristique euclidienne
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
      if (!is.null(avoid_node) && neighbor_node == avoid_node) next
      
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

# Heuristique basée sur la distance euclidienne entre les positions de la grille
euclidean_heuristic <- function(start, goal, grid_cols, grid_rows) {
  start_coords <- get_coordinates(start, grid_cols, grid_rows)
  goal_coords <- get_coordinates(goal, grid_cols, grid_rows)
  return(euclidean_distance(start_coords[1], start_coords[2], goal_coords[1], goal_coords[2]))
}

# Fonction pour la visualisation de la grille avec obstacles, départ, but, et chemin
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

# Fonction pour élaguer les voisins en appliquant des règles spécifiques
prune_neighbors <- function(p_x, x, neighbors, adjacency_list, grid_cols, grid_rows) {
  left_neighbors <- list()
  
  for (n in neighbors) {
    if (n == x) next
    
    # Calcule la distance de p_x à n en évitant x
    dist_p_x_n <- a_star(adjacency_list, euclidean_heuristic, p_x, n, grid_cols, grid_rows, avoid_node = x)$cost
    print(dist_p_x_n)
    # Distance de p_x à x
    dist_p_x_x <- a_star(adjacency_list, euclidean_heuristic, p_x, x, grid_cols, grid_rows)$cost
    print(dist_p_x_x)
    # Calcule la distance entre x et n
    dist_x_n <- a_star(adjacency_list, euclidean_heuristic, x, n, grid_cols, grid_rows, x)$cost
    print(dist_x_n)
    
    if (round(dist_p_x_x) == dist_p_x_x) {
      # Condition pour mouvement droit
      if (!(dist_p_x_n <= dist_p_x_x + dist_x_n)) {
        left_neighbors <- append(left_neighbors, list(n))
      }
    } else {
      # Condition pour mouvement diagonal
      if (!(dist_p_x_n < dist_p_x_x + dist_x_n)) {
        left_neighbors <- append(left_neighbors, list(n))
      }
    }
  }
  
  return(left_neighbors)
}

is_forced_neighbor <- function(p_x, x, n, adjacency_list, grid_cols, grid_rows) {
  
  # Calcule la distance de p_x à n en évitant x
  dist_p_x_n <- a_star(adjacency_list, euclidean_heuristic, p_x, n, grid_cols, grid_rows, avoid_node = x)$cost
  # Distance de p_x à x
  dist_p_x_x <- a_star(adjacency_list, euclidean_heuristic, p_x, x, grid_cols, grid_rows)$cost
  # Calcule la distance entre x et n
  dist_x_n <- a_star(adjacency_list, euclidean_heuristic, x, n, grid_cols, grid_rows, x)$cost

    
  if (dist_p_x_x + dist_x_n < dist_p_x_n) {
    return(TRUE)
  }
  else {
    return(FALSE)
  }
}


jump <- function(x, direction, start, goal) {
  n <- x + direction
  # Ignore n qui est un obstacle et hors de la grille
  if (n[1] >= 0 && n[1] < grid_rows &&
      n[2] >= 0 && n[2] < grid_cols || 
    !(neighbor_index %in% obstacles)) {
      return(NULL)
  }
  if (n == goal) {
    return(n) 
  }
}

# Exemple d'appel de la fonction prune_neighbors
neighbors_of_5 <- unlist(lapply(adjacency_list[[5]], function(x) x$node))  # Obtient les voisins du noeud 4
pruned_neighbors <- prune_neighbors(7, 5, neighbors_of_5, adjacency_list, grid_cols, grid_rows)
print(neighbors_of_5)
forced <- is_forced_neighbor(7, 5, 3, adjacency_list, grid_cols, grid_rows)
print(forced)

# Affiche les voisins élagués
#print("Voisins élagués :")
#for (n in pruned_neighbors) {
#  print(n)
#}
