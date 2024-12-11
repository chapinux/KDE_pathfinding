############################################### Raster d'origine : dimension : 301 * 250 ############################

## Dijkstra
## raster initiale : nombre de prixels totale : 75250  , nombre de pixel de valuer 31 ( zone supposée marchable) :12416
## résolution du raster :  3.738582 * 3.738582 , dimension : 301 * 250
## durée d'exécution avec Dijkstra : 14s 
library(raster)
library(igraph)
start_time <- Sys.time()
# Code permet de récupérer les pixel de la zone marchable , de  stcoker les noeuds-voisins dans un dictionnaire ,puis de convertir ce dict en liste d'adjacence puis en graphe  
r <- raster("./data/Raster_zone_marchable/Zone_marchable_raster.tif")
print(r)
print(res(r))
print(dim(r))
nombre_pixels <- nrow(r) * ncol(r)
print(paste( " Nombre de pixel :", nombre_pixels))
marchable_value <- 31.00
pixel_values <- values(r)
indices_31 <- which(pixel_values == marchable_value)

#print(pixel_values)
print(length(indices_31))
# Création de la table de hachage des coordonnées
hash_coords <- new.env(hash = TRUE, parent = emptyenv())
for (index in indices_31) {
  row <- (index - 1) %% nrow(r) + 1
  col <- (index - 1) %/% nrow(r) + 1
  hash_coords[[as.character(index)]] <- c(row, col)
}

# Fonction pour obtenir les voisins en 8-connexions
get_neighbors <- function(index, hash_coords, r) {
  coord <- hash_coords[[as.character(index)]]
  if (is.null(coord)) return(NULL)
  
  row <- coord[1]
  col <- coord[2]
  
  directions <- list(
    c(-1, 0), c(-1, 1), c(0, 1), c(1, 1),
    c(1, 0), c(1, -1), c(0, -1), c(-1, -1)
  )
  
  neighbors <- c()
  for (dir in directions) {
    new_row <- row + dir[1]
    new_col <- col + dir[2]
    
    if (new_row >= 1 && new_row <= nrow(r) && new_col >= 1 && new_col <= ncol(r)) {
      neighbor_index <- (new_col - 1) * nrow(r) + new_row
      if (!is.null(hash_coords[[as.character(neighbor_index)]])) {
        neighbors <- c(neighbors, neighbor_index)
      }
    }
  }
  return(neighbors)  
}

# Créer une liste d'adjacence unique sans doublons
adj_list <- vector("list", length(indices_31))
names(adj_list) <- as.character(indices_31)

for (index in indices_31) {
  neighbors <- get_neighbors(index, hash_coords, r)
  #print(neighbors)
  adj_list[[as.character(index)]] <- neighbors
}

#print(adj_list)
# Construire le graphe par la méthode 1 : en créant une liste d'arêtes unique à partir de la liste d'adjacence , 
edges <- c()
for (node in names(adj_list)) {
  neighbors <- adj_list[[node]]
  for (neighbor in neighbors) {
    edges <- c(edges, node, neighbor)
  }
}

# Créer le graphe non orienté
g <- graph(edges = edges, directed = FALSE)

# Construire le graphe par la méthode 2 : en utilisant la fonction   "graph_from_adj_list" , ( à revoir )
#g <- graph_from_adj_list(adj_list, mode = "all")

# exmple de test : 
depart<- "7312"
arrivee <- "7019"

neighbors_list <- neighbors(g, v = depart, mode = "out")
cat("Voisins du nœud", depart, ": ", neighbors_list, "\n")
neighbors_list <- neighbors(g, v = arrivee, mode = "out")
cat("Voisins du nœud", arrivee, ": ", neighbors_list, "\n")

if (!is.na(depart) && !is.na(arrivee) && depart %in% V(g) && arrivee %in% V(g)) {
  resultat <- shortest_paths(g, from = depart, to = arrivee)
  print(resultat)
} else {
  cat("Les nœuds de départ ou d'arrivée ne sont pas valides dans le graphe.\n")
}

#print(adj_list)
print(resultat)

end_time <- Sys.time()  
execution_time <- end_time - start_time  
print(paste("Temps d'exécution total pour Dijstra appliqué sur le Raster d'origine:", execution_time))











## A*
## raster initiale : nombre de prixels totale : 75250  , nombre de pixel de valuer 31 ( zone supposée marchable) :12416
## résolution du raster :  3.738582 * 3.738582 , dimension : 301 * 250
## durée d'exécution avec A*: 2.8"
start_time <- Sys.time()
# Code permet de récupérer les pixel de la zone marchable , de  stcoker les noeuds-voisins dans un dictionnaire ,puis de convertir ce dict en liste d'adjacence puis en graphe  
library(raster)
library(igraph)

# Charger le raster et obtenir la liste d'adjacence
r <- raster("./data/Raster_zone_marchable/Zone_marchable_raster.tif")
marchable_value <- 31.00
pixel_values <- values(r)
indices_31 <- which(pixel_values == marchable_value)

# Création de la table de hachage des coordonnées
hash_coords <- new.env(hash = TRUE, parent = emptyenv())
for (index in indices_31) {
  row <- (index - 1) %% nrow(r) + 1
  col <- (index - 1) %/% nrow(r) + 1
  hash_coords[[as.character(index)]] <- c(row, col)
}

# Fonction pour obtenir les voisins en 8-connexions
get_neighbors <- function(index, hash_coords, r) {
  coord <- hash_coords[[as.character(index)]]
  if (is.null(coord)) return(NULL)
  
  row <- coord[1]
  col <- coord[2]
  
  directions <- list(
    c(-1, 0), c(-1, 1), c(0, 1), c(1, 1),
    c(1, 0), c(1, -1), c(0, -1), c(-1, -1)
  )
  
  neighbors <- c()
  for (dir in directions) {
    new_row <- row + dir[1]
    new_col <- col + dir[2]
    
    if (new_row >= 1 && new_row <= nrow(r) && new_col >= 1 && new_col <= ncol(r)) {
      neighbor_index <- (new_col - 1) * nrow(r) + new_row
      if (!is.null(hash_coords[[as.character(neighbor_index)]])) {
        neighbors <- c(neighbors, neighbor_index)
      }
    }
  }
  return(neighbors)  
}

# Créer une liste d'adjacence unique sans doublons
adj_list <- vector("list", length(indices_31))
names(adj_list) <- as.character(indices_31)

for (index in indices_31) {
  neighbors <- get_neighbors(index, hash_coords, r)
  adj_list[[as.character(index)]] <- neighbors
}

# Fonction heuristique pour A* : distance euclidienne
euclidean_heuristic <- function(node, goal, hash_coords) {
  coord_node <- hash_coords[[as.character(node)]]
  coord_goal <- hash_coords[[as.character(goal)]]
  sqrt((coord_goal[1] - coord_node[1])^2 + (coord_goal[2] - coord_node[2])^2)
}

# Algorithme A*
a_star <- function(adj_list, heuristic, start, goal, hash_coords) {
  open_set <- list(start)
  came_from <- list()
  
  g_score <- setNames(rep(Inf, length(adj_list)), names(adj_list))
  g_score[as.character(start)] <- 0
  
  f_score <- setNames(rep(Inf, length(adj_list)), names(adj_list))
  f_score[as.character(start)] <- heuristic(start, goal, hash_coords)
  
  while (length(open_set) > 0) {
    # Trouver le nœud avec le plus petit f_score
    current <- open_set[[which.min(sapply(open_set, function(node) f_score[as.character(node)]))]]
    
    if (current == goal) {
      # Reconstruire le chemin
      path <- list(current)
      while (!is.null(came_from[[as.character(current)]])) {
        current <- came_from[[as.character(current)]]
        path <- append(list(current), path)
      }
      return(list(path = unlist(path), cost = g_score[as.character(goal)]))
    }
    
    open_set <- open_set[open_set != current]
    
    for (neighbor in adj_list[[as.character(current)]]) {
      tentative_g_score <- g_score[as.character(current)] + 1  # Poids uniforme pour les voisins
      
      if (tentative_g_score < g_score[as.character(neighbor)]) {
        came_from[[as.character(neighbor)]] <- current
        g_score[as.character(neighbor)] <- tentative_g_score
        f_score[as.character(neighbor)] <- g_score[as.character(neighbor)] + heuristic(neighbor, goal, hash_coords)
        
        if (!(neighbor %in% open_set)) {
          open_set <- append(open_set, neighbor)
        }
      }
    }
  }
  
  return(list(path = NULL, cost = Inf))  # Si aucun chemin trouvé
}
# Exécution de l'algorithme A*
start_node <- indices_31[1000]  # Premier pixel marchable
goal_node <- indices_31[length(indices_31)]  # Dernier pixel marchable

start_node<- 7312
goal_node <- 7019

result <- a_star(adj_list, euclidean_heuristic, start_node, goal_node, hash_coords)

cat("Chemin :", result$path, "\n")
cat("Coût :", result$cost, "\n")

end_time <- Sys.time()  
execution_time <- end_time - start_time  
print(paste("Temps d'exécution total pour A* appliqué sur le Raster d'origine:", execution_time))

























########################################### Raster aggrégé *2  : dimension : 151*125  #####################################################




## Dijkstra
## Généralisation du raster, dans cet exemple on a réduit chaque 4pixels en un pixel . 
## nombre de pixel totol : 18875, 
## nombre de pixel ayant la valeur 31 : 2060
## rapidité de d'éxécution : 0.7 s  ,   résolution du raster médiocre : 7.477164 7.477164 ; dimension : 151*125 
library(raster)
library(igraph)

start_time <- Sys.time()
# Code permet de récupérer les pixel de la zone marchable , de  stcoker les noeuds-voisins dans un dictionnaire ,puis de convertir ce dict en liste d'adjacence puis en graphe  

r <- raster("./data/Raster_zone_marchable/Zone_marchable_raster.tif")
##réduction du raster 
r <- aggregate(r, fact = 2, fun = mean)
print(res(r))
print(dim(r))

nombre_pixels <- nrow(r) * ncol(r)
print(paste( " Nombre de pixel :", nombre_pixels))
marchable_value <- 31.00
pixel_values <- values(r)
indices_31 <- which(pixel_values == marchable_value)

#print(pixel_values)
print(length(indices_31))
# Création de la table de hachage des coordonnées
hash_coords <- new.env(hash = TRUE, parent = emptyenv())
for (index in indices_31) {
  row <- (index - 1) %% nrow(r) + 1
  col <- (index - 1) %/% nrow(r) + 1
  hash_coords[[as.character(index)]] <- c(row, col)
}


# Fonction pour obtenir les voisins en 8-connexions
get_neighbors <- function(index, hash_coords, r) {
  coord <- hash_coords[[as.character(index)]]
  if (is.null(coord)) return(NULL)
  
  row <- coord[1]
  col <- coord[2]
  
  directions <- list(
    c(-1, 0), c(-1, 1), c(0, 1), c(1, 1),
    c(1, 0), c(1, -1), c(0, -1), c(-1, -1)
  )
  
  neighbors <- c()
  for (dir in directions) {
    new_row <- row + dir[1]
    new_col <- col + dir[2]
    
    if (new_row >= 1 && new_row <= nrow(r) && new_col >= 1 && new_col <= ncol(r)) {
      neighbor_index <- (new_col - 1) * nrow(r) + new_row
      if (!is.null(hash_coords[[as.character(neighbor_index)]])) {
        neighbors <- c(neighbors, neighbor_index)
      }
    }
  }
  return(neighbors)  
}


# Créer une liste d'adjacence unique sans doublons
adj_list <- vector("list", length(indices_31))
names(adj_list) <- as.character(indices_31)

for (index in indices_31) {
  neighbors <- get_neighbors(index, hash_coords, r)
  #print(neighbors)
  adj_list[[as.character(index)]] <- neighbors
}

#print(adj_list)
# Construire le graphe par la méthode 1 : en créant une liste d'arêtes unique à partir de la liste d'adjacence , 
edges <- c()
for (node in names(adj_list)) {
  neighbors <- adj_list[[node]]
  for (neighbor in neighbors) {
    edges <- c(edges, node, neighbor)
  }
}

# Créer le graphe non orienté
g <- graph(edges = edges, directed = FALSE)


# Construire le graphe par la méthode 2 : en utilisant la fonction   "graph_from_adj_list" , ( à revoir )
#g <- graph_from_adj_list(adj_list, mode = "all")


# exmple de test : 

depart<- "6726"
arrivee <- "6730"

neighbors_list <- neighbors(g, v = depart, mode = "out")
cat("Voisins du nœud", depart, ": ", neighbors_list, "\n")
neighbors_list <- neighbors(g, v = arrivee, mode = "out")
cat("Voisins du nœud", arrivee, ": ", neighbors_list, "\n")


resultat <- shortest_paths(g, from = depart, to = arrivee)

#print(adj_list)
print(resultat)

end_time <- Sys.time()  
execution_time <- end_time - start_time  
print(paste("Temps d'exécution total pour Dijkstra appliqué sur Raster aggrégé :", execution_time))














## A*
## Généralisation du raster, dans cet exemple on a réduit chaque 4pixels en un pixel . 
## nombre de pixel totol : 18875, 
## nombre de pixel ayant la valeur 31 : 2060
## rapidité de d'éxécution : 0.46 s  ,   résolution du raster médiocre : 7.477164 7.477164 ; dimension : 151*125 
library(raster)
library(igraph)

start_time <- Sys.time()
# Code permet de récupérer les pixel de la zone marchable , de  stcoker les noeuds-voisins dans un dictionnaire ,puis de convertir ce dict en liste d'adjacence puis en graphe  

r <- raster("./data/Raster_zone_marchable/Zone_marchable_raster.tif")
##réduction du raster 
r <- aggregate(r, fact = 2, fun = mean)
print(res(r))
print(dim(r))

nombre_pixels <- nrow(r) * ncol(r)
print(paste( " Nombre de pixel :", nombre_pixels))
marchable_value <- 31.00
pixel_values <- values(r)
indices_31 <- which(pixel_values == marchable_value)

#print(pixel_values)
print(length(indices_31))
# Création de la table de hachage des coordonnées
hash_coords <- new.env(hash = TRUE, parent = emptyenv())
for (index in indices_31) {
  row <- (index - 1) %% nrow(r) + 1
  col <- (index - 1) %/% nrow(r) + 1
  hash_coords[[as.character(index)]] <- c(row, col)
}


# Fonction pour obtenir les voisins en 8-connexions
get_neighbors <- function(index, hash_coords, r) {
  coord <- hash_coords[[as.character(index)]]
  if (is.null(coord)) return(NULL)
  
  row <- coord[1]
  col <- coord[2]
  
  directions <- list(
    c(-1, 0), c(-1, 1), c(0, 1), c(1, 1),
    c(1, 0), c(1, -1), c(0, -1), c(-1, -1)
  )
  
  neighbors <- c()
  for (dir in directions) {
    new_row <- row + dir[1]
    new_col <- col + dir[2]
    
    if (new_row >= 1 && new_row <= nrow(r) && new_col >= 1 && new_col <= ncol(r)) {
      neighbor_index <- (new_col - 1) * nrow(r) + new_row
      if (!is.null(hash_coords[[as.character(neighbor_index)]])) {
        neighbors <- c(neighbors, neighbor_index)
      }
    }
  }
  return(neighbors)  
}


# Créer une liste d'adjacence unique sans doublons
adj_list <- vector("list", length(indices_31))
names(adj_list) <- as.character(indices_31)

for (index in indices_31) {
  neighbors <- get_neighbors(index, hash_coords, r)
  #print(neighbors)
  adj_list[[as.character(index)]] <- neighbors
}


# Fonction heuristique pour A* : distance euclidienne
euclidean_heuristic <- function(node, goal, hash_coords) {
  coord_node <- hash_coords[[as.character(node)]]
  coord_goal <- hash_coords[[as.character(goal)]]
  sqrt((coord_goal[1] - coord_node[1])^2 + (coord_goal[2] - coord_node[2])^2)
}

# Algorithme A*
a_star <- function(adj_list, heuristic, start, goal, hash_coords) {
  open_set <- list(start)
  came_from <- list()
  
  g_score <- setNames(rep(Inf, length(adj_list)), names(adj_list))
  g_score[as.character(start)] <- 0
  
  f_score <- setNames(rep(Inf, length(adj_list)), names(adj_list))
  f_score[as.character(start)] <- heuristic(start, goal, hash_coords)
  
  while (length(open_set) > 0) {
    # Trouver le nœud avec le plus petit f_score
    current <- open_set[[which.min(sapply(open_set, function(node) f_score[as.character(node)]))]]
    
    if (current == goal) {
      # Reconstruire le chemin
      path <- list(current)
      while (!is.null(came_from[[as.character(current)]])) {
        current <- came_from[[as.character(current)]]
        path <- append(list(current), path)
      }
      return(list(path = unlist(path), cost = g_score[as.character(goal)]))
    }
    
    open_set <- open_set[open_set != current]
    
    for (neighbor in adj_list[[as.character(current)]]) {
      tentative_g_score <- g_score[as.character(current)] + 1  # Poids uniforme pour les voisins
      
      if (tentative_g_score < g_score[as.character(neighbor)]) {
        came_from[[as.character(neighbor)]] <- current
        g_score[as.character(neighbor)] <- tentative_g_score
        f_score[as.character(neighbor)] <- g_score[as.character(neighbor)] + heuristic(neighbor, goal, hash_coords)
        
        if (!(neighbor %in% open_set)) {
          open_set <- append(open_set, neighbor)
        }
      }
    }
  }
  
  return(list(path = NULL, cost = Inf))  # Si aucun chemin trouvé
}

# Exécution de l'algorithme A*

start_node<- 6726
goal_node <- 6730

result <- a_star(adj_list, euclidean_heuristic, start_node, goal_node, hash_coords)

cat("Chemin :", result$path, "\n")
cat("Coût :", result$cost, "\n")

end_time <- Sys.time()  
execution_time <- end_time - start_time  
print(paste("Temps d'exécution total pour A* appliqué sur le Raster aggrégé:", execution_time))








