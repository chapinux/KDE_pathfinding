# import de la librairie igraph 
library(igraph)

# calcul de la distance euclidienne entre deux points
euclidean_distance <- function(point1, point2) {
  return(sqrt((point1[1] - point2[1])^2 + (point1[2] - point2[2])^2))
}

# 
coordinates <- list(
  c(1, 2),  
  c(2, 3),  
  c(4, 1),
  c(6, 2),  
  c(3, 5)   
)

# création de la matrice des distances au lieu de la matrice d'adjacences
distance_matrix <- matrix(0, nrow = length(coordinates), ncol = length(coordinates))

for (i in 1:length(coordinates)) {
  for (j in 1:length(coordinates)) {
    if (i != j) {
      distance_matrix[i, j] <- euclidean_distance(coordinates[[i]], coordinates[[j]])
    }
  }
}

print(distance_matrix)

# A*
a_star <- function(graph, heuristic, start, goal) {
  #Utilisation de la matrice d'adjacence pour trouver le nombre de noeuds e.g le nombre de lignes ou colonnes qui donne taille tableau
  #Initialisation des distances à l'infini
  distances = rep(Inf, nrow(graph))
  #initialisation de la distance à 0
  
  distances[start] = 0
  #initialisation de toutes les priorités à l'infini
  
  priorities = rep(Inf, nrow(graph))
  #le noeud de départ a une priorité qui fait la distance de l'heuristique de start jusqu'à goal
  
  priorities[start] = heuristic(coordinates[[start]], coordinates[[goal]])
  # initialisation de la liste des noeuds visités
  visited = rep(FALSE, nrow(graph))
  
  repeat {
    lowest_priority = Inf 
    lowest_priority_index = -1
    
    #si un noeud non visité et qu'il a une priorité plus importante
    
    
    for(i in seq_along(priorities)) {
      if (priorities[i] < lowest_priority && visited[i] == FALSE) {
        lowest_priority = priorities[i]
        lowest_priority_index = i
      }
    }
    
    if (lowest_priority_index == -1) {
      return (-1)
    }
    
    #si on atteint le noeud goal, on stoppe l'algo
    
    else if (lowest_priority_index == goal) {
      print("Yeppee! Goal node")
      return(distances[lowest_priority_index])
    }
    
    for(i in seq_along(graph[lowest_priority_index,])) {
      if (graph[lowest_priority_index, i] != 0 && visited[i] == FALSE) {
        if (distances[lowest_priority_index] + graph[lowest_priority_index, i] < distances[i]) {
          # cette distance est alors plus courte que la distance précédente
          distances[i] = distances[lowest_priority_index] + graph[lowest_priority_index, i]
          #update de la distance estimée avec l'heuristique
          priorities[i] = distances[i] + heuristic(coordinates[[i]], coordinates[[goal]])
        }
      }
    }
    # on met le noeud a "visité"
    
    visited[lowest_priority_index] = TRUE
  }
}

# Heuristique basée sur la distance Euclidienne
euclidean_heuristic <- function(start, goal) {
  return(euclidean_distance(start, goal))
}

# Appel de la fonction A* pour trouver un chemin entre les points 1 et 4
print(a_star(distance_matrix, euclidean_heuristic, 1, 4))
