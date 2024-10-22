# import de la librairie igraph 
library(igraph)

adj_matrix <-  matrix(c(1, 1, 1, 1, 0,
                        1, 0, 1, 0, 1,
                        1, 1, 1, 0, 1,
                        0, 0, 1, 1, 1,
                        1, 1, 1, 0, 1
                        ), nrow = 5, byrow = TRUE)




# création du graphe à partir de la matrice d'adjacence
g <- graph_from_adjacency_matrix(adj_matrix, mode = "undirected")

# Plot du graphe
plot(g)


zero_heuristic <- function(start, goal) {
  return(0)  # Heuristique basique qui retourne toujours 0
}


#A star trouve un chemin depuis start jusqu'à goal
#l'heuritique permet d'estimer le chemin depuis le noeud n jusqu'au goal
a_star <- function(graph, heuristic, start, goal) {
  #Utilisation de la matrice d'adjacence pour trouver le nombre de noeuds e.g le nombre de lignes ou colonnes qui donne taille tableau
  #Initialisation des distances à l'infini
  distances = rep(Inf, nrow(graph))
  #initialisation de la distance à 0
  distances[start] = 0
  
  #initialisation de toutes les distances à l'infini
  priorities = rep(Inf, nrow(graph))
  
  #le noeud de départ a une priorité qui fait la distance de l'heuristique de start jusqu'à goal
  priorities[start] = heuristic(start, goal)
  
  # initialisation de la liste des noeuds visités
  visited = rep(FALSE, nrow(graph))
  
  #tant que tous les noeuds n'ont pas été visités
  repeat {
    lowest_priority = Inf 
    lowest_priority_index = -1
    
    #si un noeud non visité et qu'il a une priorité plus importante
    for(i in seq_along(priorities)) {
      if (priorities[i] < lowest_priority && visited[i] == FALSE) {
        #on update les priorités
        lowest_priority = priorities[i]
        lowest_priority_index = i
      }
    }
    
    # si aucun noeud mieux n'a été trouvé, ou une erreur -> retourne -1 en guise d'erreur
    if (lowest_priority_index == -1) {
      return (-1)
    }
    
    #si on atteint le noeud goal, on stoppe l'algo
    
    else if (lowest_priority_index == goal) {
      print("Yeppee! Goal node")
      return(distances[lowest_priority_index])
    }
    
    #sinon
    for(i in seq_along(graph[lowest_priority_index,])) {
      if (graph[lowest_priority_index, i] != 0 && visited[i] == FALSE) {
        if (distances[lowest_priority_index] + graph[lowest_priority_index, i] < distances[i]) {
            # cette distance est alors plus courte que la distance précédente
            distances[i] = distances[lowest_priority_index] + graph[lowest_priority_index, i]
            #update de la distance estimée avec l'heuristique
            priorities[i] = distances[i] + heuristic(i, goal)
        }
        # on met le noeud a "visité"
        visited[lowest_priority_index] = TRUE
      }
    }
   }
  }


print(a_star(adj_matrix, zero_heuristic, 1, 4))




