## Ce code permet de tester les 3 algorithmes ( Djikstra , A* et JPS ) sur une grille 2D ;
# et de sauvegarder  les résultats dans des fichiers excel , en ajoutant les grandeurs statistiques pour évaluer la stochasticité des algo
# Définition des dimensions de la grille

#étape 1 :  Génération des obstacles et de points de test ed manière dynamique et les sauvegarder dans des fichier .rds
grid_rows <- 100
grid_cols <- 100
total_nodes <- grid_rows * grid_cols

# Génération aléatoire des obstacles
set.seed(1223)  # Pour reproductibilité
num_obstacles <- 10000 
obstacles <- sample(1:total_nodes, num_obstacles, replace = TRUE)
saveRDS(obstacles, file = "obstacles.rds")
print(obstacles)
#print(obstacles)
set.seed(4506)  # Pour reproductibilité
num_pairs <- 25 #nombre de couples de test

# Fonction pour générer un point accessible aléatoire
generate_accessible_point <- function(excluded_points) {
  repeat {
    point <- sample(1:total_nodes, 1)  # Point aléatoire
    if (!(point %in% excluded_points)) {
      return(point)
    }
  }
}
# Liste pour stocker les couples (start, end)
test_pairs <- vector("list", num_pairs)
# Générer les couples
for (i in 1:num_pairs) {
  start <- generate_accessible_point(obstacles)
  end <- generate_accessible_point(c(obstacles, start))  # Le point de destination doit aussi être accessible et différent
  test_pairs[[i]] <- list(start = start, end = end)  # Chaque paire est une liste avec start et end
}

# Sauvegarde dans un fichier RDS
saveRDS(test_pairs, "test_pairs.rds")
test_cases <- readRDS("test_pairs.rds")
print(test_cases)







## étape 2: compilation des algorithmes 
library(igraph)
## Djikstra perso
# Fonctions de base auciliares
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


# fonction pricipale de djikstra 
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

# Fonction pour calculer la distance euclidienne
euclidean_distance <- function(row1, col1, row2, col2) {
  return(sqrt((row1 - row2)^2 + (col1 - col2)^2))
}

# Fonction pour obtenir les coordonnées
get_coordinates <- function(node, grid_cols,grid_rows=grid_cols) {
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
#print(adjacency_list[1])

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



adjacency_list <- build_adjacency_list(total_nodes, grid_cols, grid_rows, obstacles)


# Définition des noeuds de départ et but pour un petit test unitaire
start_node <- 7263
goal_node <- 3461
# Exécution
start_time <- Sys.time()
result <- a_star(adjacency_list, euclidean_heuristic, start_node, goal_node, grid_cols)
end_time <- Sys.time()
execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

cat("Chemin A*:", result$path, "\n")
cat("Nombre de neouds ", length(result$path)  )
cat("Coût A* :", result$cost, "\n")
cat("temps d'exécution A* :", execution_time, "\n")


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
  cat("result*path",resultat_dijkstra$path)
  #cat("\nTypes de mouvements:\n")
  #for(move in resultat_dijkstra$moves) {
  # cat(sprintf("De %d à %d : %s\n", move$from, move$to, move$type))
  #}
} else {
  cat("Aucun chemin trouvé entre", start_node, "et", goal_node, "\n")
  cat("Vérifiez que les points de départ et d'arrivée ne sont pas des obstacles\n")
  cat("et qu'il existe un chemin possible entre eux.\n")
}

cat("\nTemps d'exécution:", execution_time, "secondes\n")


# Affichage
#plot_grid(grid_rows, grid_cols, adjacency_list, start_node, goal_node, result$path, obstacles)

#plot_grid(grid_rows, grid_cols, adjacency_list, start_node, goal_node,resultat_dijkstra$path, obstacles)





############ JPS
# Helper Functions for Pathfinding
# Heuristique basée sur la distance euclidienne entre les positions de la grille
euclidean_heuristic <- function(start, goal, grid_cols, grid_rows) {
  start_coords <- get_coordinates(start, grid_cols, grid_rows)
  goal_coords <- get_coordinates(goal, grid_cols, grid_rows)
  return(euclidean_distance(start_coords[1], start_coords[2], goal_coords[1], goal_coords[2]))
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
    # print(current)
    #print(start)
    
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

# Run the A* with JPS algorithm
start_time <- Sys.time()
result <- a_star_jps(adjacency_list, euclidean_heuristic, start_node, goal_node, grid_cols, grid_rows, obstacles)
end_time <- Sys.time()
execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

cat("Chemin JPS:", result$path, "\n")
cat("Nombre de neouds ", length(result$path)  )
cat("Coût JPS :", result$cost, "\n")
cat("temps d'exécution JPS :", execution_time, "\n")

# Plot the result
#plot_grid(grid_rows, grid_cols, adjacency_list, start_node, goal_node, result$path, obstacles)













############################ étape 3  :  tester et sauvegarder les résultats ( temps d'exécution et couts ) 
library(openxlsx)
# Fonction pour calculer le temps d'exécution d'une fonction
measure_execution_time <- function(start, end, g, obstacles) {
  start_time <- Sys.time()
  
  # Appliquer l'algorithme de Dijkstra ici
  # Remplacez cette partie par votre fonction Dijkstra
  result <- shortest_paths(g, from = start_node, to = goal_node)
  
  end_time <- Sys.time()
  
  # Calculer le temps d'exécution
  execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  return(execution_time)
}

# Exemple de points de départ et d'arrivée
test_cases <- readRDS("test_pairs.rds")
#print(test_cases)

# Tableau pour stocker les résultats
results <- data.frame(
  Algorithm = character(0),
  ID_paire=character(0),
  ID_rep=character(0),
  Start = integer(0),
  End = integer(0),
  ExecutionTime = numeric(0),
  cout=numeric(0)
)

## Dijkstra
i<- 0
for (test_case in test_cases) {
  start <- test_case$start
  end <- test_case$end
  
  # Mesurer le temps d'exécution pour 100 répétitions
  for (j in 1:100) {
    
    start_time <- Sys.time()
    resultat_dijkstra <- dijkstra_dynamic(adjacency_list, start_node, goal_node, grid_cols)
    end_time <- Sys.time()
    execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

    # Stocker les résultats dans le tableau
    results <- rbind(results, data.frame(Algorithm="Djikstra" ,ID_paire=paste("P", i, sep = ""),ID_rep=paste("R", j, sep = ""),Start = start, End = end, ExecutionTime = execution_time,cout=resultat_dijkstra$cost))

  }
  i<-i+1
}
## A*
i<- 0
for (test_case in test_cases) {
  start <- test_case$start
  end <- test_case$end
  # Mesurer le temps d'exécution pour 100 répétitions
  for (j in 1:100) {
    start_time <- Sys.time()
    result <- a_star(adjacency_list, euclidean_heuristic, start_node, goal_node, grid_cols)
    end_time <- Sys.time()
    execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    # Stocker les résultats dans le tableau
    results <- rbind(results, data.frame(Algorithm="A*",ID_paire=paste("P", i, sep = ""),ID_rep=paste("R", j, sep = "") ,Start = start, End = end, ExecutionTime = execution_time,cout=result$cost))
  }
  i<-i+1
}

## JPS : 

i<- 0
for (test_case in test_cases) {
  #start <- test_case$start
  start <- test_case$start
  end <- test_case$end
  #end <- test_case$end
  # Mesurer le temps d'exécution pour 100 répétitions
  for (j in 1:100) {
    start_time <- Sys.time()
    result <- a_star_jps(adjacency_list, euclidean_heuristic, start, end, grid_cols, grid_rows, obstacles)
    end_time <- Sys.time()
    execution_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    # Stocker les résultats dans le tableau
    results <- rbind(results, data.frame(Algorithm="JPS",ID_paire=paste("P", i, sep = ""),ID_rep=paste("R", j, sep = "") ,Start = start, End = end, ExecutionTime = execution_time,cout=result$cost))
  }
  i<-i+1
}

# Afficher les résultats
print(results)
# Exporter les résultats dans un fichier Excel
write.xlsx(results, "execution_times_v2_1.xlsx")










########## étape 4 : calcul et ajout de :  Moyenne , Variance et écart type :
library(openxlsx)

# Charger les résultats depuis le fichier Excel
results <- read.xlsx("execution_times_v2_1.xlsx")

# Calculer la moyenne, la variance et l'écart type des temps d'exécution pour chaque combinaison Algorithm et ID_paire
moyennes <- aggregate(ExecutionTime ~ Algorithm + ID_paire, data = results, FUN = mean)
moyennesCout <- aggregate(cout ~ Algorithm + ID_paire, data = results, FUN = mean)

variances <- aggregate(ExecutionTime ~ Algorithm + ID_paire, data = results, FUN = var)
ecarts_types <- aggregate(ExecutionTime ~ Algorithm + ID_paire, data = results, FUN = sd)

# Renommer les colonnes pour les nouvelles statistiques
colnames(moyennesCout)[3] <- "Cout_Moyen"
colnames(moyennes)[3] <- "T_moy_par_paire"
colnames(variances)[3] <- "Variance"
colnames(ecarts_types)[3] <- "Ecart_Type"

# Fusionner les statistiques dans un tableau récapitulatif
statistiques <- merge(moyennes, variances, by = c("Algorithm", "ID_paire"))
statistiques <- merge(statistiques, moyennesCout, by = c("Algorithm", "ID_paire"))
statistiques <- merge(statistiques, ecarts_types, by = c("Algorithm", "ID_paire"))

# Ajouter la colonne Ratio : Ecart_Type / T_moy_par_paire
statistiques$Ratio <- statistiques$Ecart_Type / statistiques$T_moy_par_paire

# Créer un fichier Excel pour enregistrer les résultats
wb <- createWorkbook()
addWorksheet(wb, "Resultats")

# Écrire le tableau original à partir de la colonne 1
writeData(wb, "Resultats", results, startCol = 1, startRow = 1)

# Ajouter deux colonnes vides et écrire le tableau récapitulatif avec toutes les statistiques
start_col_récap <- ncol(results) + 3 # Deux colonnes vides après le tableau original
writeData(wb, "Resultats", statistiques, startCol = start_col_récap, startRow = 1)

# Sauvegarder le fichier Excel avec le tableau original et le récapitulatif
saveWorkbook(wb, "resultats_avec_resume_v2_1.xlsx", overwrite = TRUE)

# Afficher un aperçu des deux tableaux
cat("Aperçu du tableau original :\n")
print(head(results))
cat("\nAperçu du tableau récapitulatif avec moyenne, variance, et écart type :\n")
print(head(statistiques))
