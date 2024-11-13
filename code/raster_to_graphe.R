library(raster)
library(igraph)
start_time <- Sys.time()
# Code permet de récupérer les pixel de la zone marchable , de  stcoker les noeuds-voisins dans un dictionnaire ,puis de convertir ce dict en liste d'adjacence puis en graphe  

r <- raster("./data/Raster_zone_marchable/Zone_marchable_raster.tif")
marchable_value <- 31
pixel_values <- values(r)
indices_31 <- which(pixel_values == marchable_value)

# Limiter aux 100 premiers indices marchables
#indices_31 <- indices_31[1:min(100, length(indices_31))]


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
  return(unique(neighbors))  # Supprimer les doublons
}

# Créer une liste d'adjacence unique sans doublons
adj_list <- vector("list", length(indices_31))
names(adj_list) <- as.character(indices_31)

for (index in indices_31) {
  neighbors <- get_neighbors(index, hash_coords, r)
  adj_list[[as.character(index)]] <- neighbors
}

# Création du graphe à partir de la liste d'adjacence sans arêtes redondantes
g <- graph_from_adj_list(adj_list, mode = "out")

#Affichage analytique du graphe ( test )
cat("Affichage des nœuds et de leurs voisins :\n")
for (node in names(adj_list)) {
  neighbors <- adj_list[[node]]
  cat("Nœud", node, ": Voisins ->", paste(neighbors, collapse = ", "), "\n")
}

## pour afficher la liste d'adjacence et le graphe 
print(adj_list)
print(g)



end_time <- Sys.time()  
execution_time <- end_time - start_time  
print(paste("Temps d'exécution total :", execution_time))







