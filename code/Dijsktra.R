## Djikstra 
# Fonctions de auxiliaires
get_coordinates <- function(node, grid_cols, grid_rows=grid_cols) {
  row <- (node - 1) %/% grid_cols
  col <- (node - 1) %% grid_cols
  return(c(row, col))
}

calculate_move_cost <- function(node1, node2, grid_cols) {
  coords1 <- get_coordinates(node1, grid_cols)
  coords2 <- get_coordinates(node2, grid_cols)
  
  row_diff <- abs(coords1[1] - coords2[1])
  col_diff <- abs(coords1[2] - coords2[2])
  
  if (row_diff == 1 && col_diff == 1) {
    return(sqrt(2))  
  } else if (row_diff == 1 || col_diff == 1) {
    return(1)  
  } else {
    return(0)  
  }
}

# Construction de la liste d'adjacence
build_adjacency_list <- function(total_nodes, grid_cols, grid_rows, obstacles) {
  adjacency_list <- vector("list", total_nodes)
  
  for (node in 1:total_nodes) {
    if (node %in% obstacles) {
      adjacency_list[[node]] <- NULL
      next
    }
    
    coords <- get_coordinates(node, grid_cols)
    row <- coords[1]
    col <- coords[2]
    
    neighbors <- list()
    # Vérifier les 8 directions possibles
    for (dr in -1:1) {
      for (dc in -1:1) {
        if (dr == 0 && dc == 0) next
        
        new_row <- row + dr
        new_col <- col + dc
        
        # Vérifier si le voisin est dans la grille
        if (new_row >= 0 && new_row < grid_rows && 
            new_col >= 0 && new_col < grid_cols) {
          neighbor_node <- new_row * grid_cols + new_col + 1
          
          # Vérifier si le voisin n'est pas un obstacle
          if (!(neighbor_node %in% obstacles)) {
            # Calculer le coût du mouvement
            cost <- if(abs(dr) + abs(dc) == 2) sqrt(2) else 1
            neighbors[[length(neighbors) + 1]] <- list(node = neighbor_node, distance = cost)
          }
        }
      }
    }
    adjacency_list[[node]] <- neighbors
  }
  return(adjacency_list)
}


#fonction pricnipale
dijkstra_dynamic <- function(graph, start, goal, grid_cols) {
  n_nodes <- length(graph)
  distances <- rep(Inf, n_nodes)
  distances[start] <- 0
  predecessors <- rep(NA, n_nodes)
  visited <- rep(FALSE, n_nodes)
  
  while(TRUE) {
    # Trouver le noeud non visité avec la plus petite distance
    min_dist <- Inf
    current <- NULL
    for(i in 1:n_nodes) {
      if(!visited[i] && distances[i] < min_dist) {
        min_dist <- distances[i]
        current <- i
      }
    }
    
    # Si aucun noeud trouvé ou si on a atteint le but
    if(is.null(current) || current == goal) break
    
    visited[current] <- TRUE
    
    # Vérifier si le noeud courant a des voisins
    if(length(graph[[current]]) > 0) {
      for(neighbor in graph[[current]]) {
        # Vérifier si neighbor est une liste valide avec un champ 'node'
        if(is.list(neighbor) && !is.null(neighbor$node)) {
          neighbor_node <- neighbor$node
          if(!visited[neighbor_node]) {
            # Calculer le coût réel du déplacement
            move_cost <- calculate_move_cost(current, neighbor_node, grid_cols)
            new_distance <- distances[current] + move_cost
            
            if(new_distance < distances[neighbor_node]) {
              distances[neighbor_node] <- new_distance
              predecessors[neighbor_node] <- current
            }
          }
        }
      }
    }
  }
  
  # Reconstruction du chemin
  if(distances[goal] == Inf) {
    return(list(path = NULL, cost = Inf))
  }
  
  path <- c()
  current <- goal
  total_cost <- 0
  previous <- NA
  
  while(!is.na(current)) {
    path <- c(current, path)
    if(!is.na(previous)) {
      total_cost <- total_cost + calculate_move_cost(current, previous, grid_cols)
    }
    previous <- current
    current <- predecessors[current]
  }
  
  # Créer la liste des mouvements avec leur type
  moves <- list()
  if(length(path) > 1) {
    for(i in 1:(length(path)-1)) {
      move_cost <- calculate_move_cost(path[i], path[i+1], grid_cols)
      type <- if(move_cost == sqrt(2)) "diagonal" else "orthogonal"
      moves[[i]] <- list(from = path[i], to = path[i+1], type = type)
    }
  }
  
  return(list(
    path = path,
    cost = total_cost,
    moves = moves
  ))
}


obstacles <- readRDS("obstacles.rds")
#print(obstacles)


# Charger les obstacles
obstacles <- readRDS("obstacles.rds")

# Construire la liste d'adjacence correcte
adjacency_list <- build_adjacency_list(total_nodes, grid_cols, grid_rows, obstacles)

# Définition des noeuds de départ et but (prend des neouds accessible )
start_node <- 692
goal_node <- 9379

# Exécuter Dijkstra avec la bonne structure de données
start_time <- Sys.time()
resultat_dijkstra <- dijkstra_dynamic(adjacency_list, start_node, goal_node, grid_cols)
end_time <- Sys.time()
execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

# Afficher les résultats
if (!is.null(resultat_dijkstra$path)) {
  cat("Chemin trouvé !\n")
  cat("Nombre de nœuds dans le chemin:", length(resultat_dijkstra$path), "\n")
  # cat("Chemin Dijkstra:", paste(resultat_dijkstra$path, collapse = " -> "), "\n")
  cat("Coût total:", resultat_dijkstra$cost, "\n")
} else {
  cat("Aucun chemin trouvé entre", start_node, "et", goal_node, "\n")
  cat("Vérifiez que les points de départ et d'arrivée ne sont pas des obstacles\n")
  cat("et qu'il existe un chemin possible entre eux.\n")
}

cat("\nTemps d'exécution:", execution_time, "secondes\n")



# Affichage

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


plot_grid(grid_rows, grid_cols, adjacency_list, start_node, goal_node, resultat_djikstra$path, obstacles)


