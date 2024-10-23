library(igraph)

# Fonction pour transformer une matrice en graphe
matrice_to_graphe <- function(grid) {
  rows <- nrow(grid)
  cols <- ncol(grid)
  g <- make_empty_graph(n = rows * cols, directed = FALSE)  #permet de  Créer un graphe vide
  
  # Fonction pour obtenir l'indice d'un nœud à partir de ses coordonnées (i, j) sur la matrice
  index <- function(i, j) {
    return((i - 1) * cols + j)
  }
  
  # Ajouter des arêtes entre les cases marchables ( cases de valeur 1)
  for (i in 1:rows) {
    for (j in 1:cols) {
      if (grid[i, j] == 1) {  # Si la case est marchable
        # Ajouter des connexions aux voisins (haut, bas, gauche, droite) si marchables
        if (i > 1 && grid[i - 1, j] == 1) {
          g <- add_edges(g, c(index(i, j), index(i - 1, j)))
        }
        if (i < rows && grid[i + 1, j] == 1) {
          g <- add_edges(g, c(index(i, j), index(i + 1, j)))
        }
        if (j > 1 && grid[i, j - 1] == 1) {
          g <- add_edges(g, c(index(i, j), index(i, j - 1)))
        }
        if (j < cols && grid[i, j + 1] == 1) {
          g <- add_edges(g, c(index(i, j), index(i, j + 1)))
        }
      }
    }
  }
  
  return(g)
}

# Exemple de matrice 5x5 (1 = marchable, 0 = obstacle)
grid <- matrix(c(1, 1, 1, 0, 1,
                 1, 0, 1, 0, 1,
                 1, 1, 1, 0, 1,
                 0, 0, 1, 1, 1,
                 1, 1, 1, 1, 1), nrow = 5, byrow = TRUE)

# Transformer la matrice en graphe
graphe <- matrice_to_graphe(grid)

## Plot graphe : 
# Afficher le graphe dans la zone de tracé
plot(graphe, 
     vertex.label = 1:vcount(graphe),  # Afficher les indices des nœuds
     vertex.size = 15,                 # Taille des nœuds
     vertex.color = "skyblue",         # Couleur des nœuds
     edge.color = "gray",              # Couleur des arêtes
     main = "Graphe des Cases Marchables")  # Titre du graphe

# Définir le point de départ et d'arrivée (transformés en indices de graphe)
depart <- 1  # Coin supérieur gauche (indice 1)
arrivee <- 25  # Coin inférieur droit (indice 25)

# Mesurer le temps d'exécution du calcul de Dijkstra
temps_execution <- system.time({
  # Appliquer l'algorithme de Dijkstra pour trouver le chemin le plus court : fonction "shortest_paths"s
  resultat <- shortest_paths(graphe, from = depart, to = arrivee)
})

# Sans system.time :   resultat <- shortest_paths(graphe, from = depart, to = arrivee)

# Afficher le chemin trouvé (indices des nœuds)
print(resultat$vpath[[1]])

# Fonction pour reconvertir un index en coordonnées (i, j) dans la matrice
index_to_coords <- function(index, ncol) {
  row <- ((index - 1) %/% ncol) + 1
  col <- ((index - 1) %% ncol) + 1
  return(c(row, col))
}

# Afficher les coordonnées (i, j) du chemin
chemin_coords <- lapply(resultat$vpath[[1]], index_to_coords, ncol = ncol(grid))
print(chemin_coords)

# Fonction pour calculer la distance totale du chemin
calculer_distance <- function(chemin_indices, pixel_size_cm) {
  # La distance totale est simplement le nombre d'étapes (nombre de pixels parcourus) multiplié par la taille du pixel
  nb_etapes <- length(chemin_indices) - 1  # Le nombre d'étapes est le nombre de pixels moins 1 (le point de départ n'est pas une étape)
  distance_totale_cm <- nb_etapes * pixel_size_cm
  return(distance_totale_cm)  # Retourne la distance en cm
}

# Définir la taille réelle d'un pixel sur le terrain (en cm)
taille_pixel_cm <- 50  # Chaque pixel représente 50 cm su terrain

# Calculer la distance totale du chemin trouvé
distance_totale <- calculer_distance(resultat$vpath[[1]], taille_pixel_cm)
cat("Distance totale parcourue :", distance_totale, "cm\n")

# Afficher le temps d'exécution
cat("Temps d'exécution de l'algorithme de Dijkstra :", temps_execution["elapsed"], "secondes\n")
