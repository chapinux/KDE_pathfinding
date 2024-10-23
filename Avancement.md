# ESTIMATION DE LA DENSITÉ 2D PAR NOYAU DANS L’ESPACE URBAIN
 PIÉTON
 
## 1. Etat de l’art sur le pathfinding 2D

## Ressources bibliographiques
1. [Planning as heuristic search Blai Bonet ∗, Héctor Geffner](https://pdf.sciencedirectassets.com/271585/1-s2.0-S0004370200X0077X/1-s2.0-S0004370201001084/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEgaCXVzLWVhc3QtMSJIMEYCIQDy4E4uEtroJsB4pUhSj5loIrIhP19pF0JdotiwNOpvHgIhAK%2BTcTgYR4BJPMBHCITlVCfvqQJnEyNmko1dN6GJoW6kKrwFCLD%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQBRoMMDU5MDAzNTQ2ODY1Igzx1vhyXFBpQsfQiWcqkAX56QE%2Fny%2F78Wo242Wgi1FsXmRlU%2BfFJDANAMF5VzJAnIpEhIYFJFhK2H18DsJ76VxIevkUQ7qNeV93xGo0nySxh3Zb0uY3LAjefop4rutgmbvzC9l3zUGWGugSIIMo9oNnzjgxPCTRGG2jVxf6bQwGCWKoERvoB4aY3inwOjloFu%2Ft0EPDLxGtTkBI756zBYgs%2Fry690MQX7aBcnZhjvDr%2Bqa1J6ZsJ4gphXUHBGQ9a7iIjlcMT62PdOVb7najkLBnlrX2x47wurjxaJVJf%2Blj4ilw5v8Fg3LTRRLzKLmn%2FTaY2uF7CO%2BaYXUPE8fGBXNGN1OUnvoOSh6MEwXs1G0sV52h9uKkRbwEwmrfdpjUIG4cgxJOIQUXhivYqAD3lbWQSSinjw7ZLTz0sjl8%2BHuALMCRayr8V7MZlrLwnP3YPZldiiUtsijaIs384nOj4L6b%2FGo293yM3OcZuWY8IMBq7UjA%2FIm7%2Fzsrgv94aVOePcpl3dLYuiAVWAWl9jB3Th47k%2B88%2FVNUE51DHP6qBN%2FOB%2F4d22Tb9D7Tvkm%2BUfI1TkwyqFwOBckbdNbuAdMzAkhFV%2BCZZy22lfkWRdtziKq4vR4Tk2GKjxM4l9GuyIxFDSN0W81pkDRo%2BqIRKxJBUeljH8i2bJqJpq9VcEtqZRnjGQOjwnPAHpU4dVHCvkmALEuGx8kC5h5g27OmxRRJY61IFEBog%2BdysSoMOUyyprJrQmVQVsM4VweHuqiQ1fVoJM60imF%2Bfvmf5i6tpNDrckQdeej%2FcjXRTKNNPUJotl7iMhTuu1v2qbHXcwzm1QxQEA%2BzeB7S3fQP9fguhzKNwVE3bhBC86QQ7YpuuI73yB4H5GK19T%2BVwPFpzAcEYsOlfTCF3%2BC4BjqwAZXmyHevAAyJXZ75j4CSDak7pPiGWs1jelunObrHdoSC1Jdjf2nNGrKtVXMHg3gmVYI5apEBnqQ02xJ37aAiptIa8VIbBGWTUY2JLReOeXeKOPl0mlsspJ%2BQ0ItLu8H1IetxUQNWYBVDXnNiPgHGpPE3HWC4OB2vCGIXmRhPSTXY7P6UDXd4GZuysQbtaPGW75BDq%2BsFgqbTC1Swj0aCzocLmboY55HzmRTFXJmRNey6&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20241022T234113Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTYRKPKQWBY%2F20241022%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=9bc9fa07a2a8de7a46d0f02a3af279138414c0f9122662447cb849ab820df919&hash=a8ad86df766c61a9b40b851b6473ebd37a3408332e5f7e3e940557af5f08ee44&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S0004370201001084&tid=spdf-f9ca8a14-cc41-4c54-96d3-292d9f6de8c2&sid=841a6b079377204b128bb1711bb48209f5b8gxrqb&type=client&tsoh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&ua=00105f02590355525056&rr=8d6d564029ff9e55&cc=fr)
2. [Le pathfinding A* et l'optimisation pour des grilles 2D, Memoire de Master : Université de Poitiers et l’Université de La Rochelle](https://www.guillaumelevieux.com/siteperso/contents/recherchem1/essamir/pathfinding.pdf)
3. [A Visual Explanation of Jump Point Search, Site Web](https://zerowidth.com/2013/a-visual-explanation-of-jump-point-search/)
4. 

## 2. Sélection de trois algorithmes efficaces : 

### Listes d'algorithmes de pathfindig : 
- *A (A-star Algorithm)*
- *Dijkstra's Algorithm*
- *Bellman-Ford Algorithm*
- *Floyd-Warshall Algorithm*
- *Greedy Best-First Search*
- *Breadth-First Search (BFS)*
- *Depth-First Search (DFS)*
- *Johnson’s Algorithm*
- *Bi-directional A-Star*
- *Jump Point Search (JPS)*
Cette liste n'est pas exhaustive , mais ce sont les algorithmes de pathifinding les plus efficaces et les plus utilisées.
### Critères de sélection: 
Le choix de 3 algorithmes adéquats pour notre sujet, pour les impélemnter et les tester ensuite sur les données du projet pour pouvoir évaluer leur performance et précision, est fait sur la base de plusieurs cirtères : 
#### Tableau de critères :
| Critères     | A*  | Dijkstra       |JPS       |
|---------|------|-------------|-------------|
| Adaptation aux grilles 2D   | Trés bien adapté   | Bien Adapté       | Optimisé pour les grilles, trés bien adapté pour les grilles continues |
| Coût et Performance (temps)     | Optimal : utilise une heuristique   | Optimal mais plus lent        | Optimal et trés rapide   |
| Utilisation d'heuristique    | oui  | non      | oui et avec optimisation  |
| Gestion des obstacles   | oui, efficace | oui mais exploration exhaustive      | oui, optimisation sur les obstacles  |
| Capacité à trouver le chemin optimal    | Toujours si l'heuristique est correcte  | Toujours      | Toujours |

---
Les autres algorithmes ne sont pas adaptés pour des problèmes de pathfindig sur des grilles 2D, ils sont adaptés plus pour des graphes pondérés.



### Les 3 algorithmes choisis :
#### Dijkstra :
- Principe : Explore  tous les chemins en calculant le coût le plus bas depuis un point de départ jusqu'à chaque autre nœud.
- Avantages : 1. le Dijkstra trouve toujours le chemin le plus court mais il ne dépend pas d'une heuristique ce qui le rend plus lent que A* dans les grands grilles.
              2. Disponible dans le package igraph pour des graphes pondérés, il peut être utilisé pour des grilles raster converties en graphe.
#### A (A-star Algorithm)* / A* Bidirectionnel : 
- Principe : le A* utilise une fonction heuristique pour explorer les chemins les plus prometteurs en utilisant une combinaison du  coût réel ( noté souvent g(n) ) et une estimation de la distance restante par une heuristique ( noté souvent h(n)).
- Avantages : Trouve le chemin optimal, rapide grâce à l'heuristique, particulièrement adapté pour les grilles 2D et très efficace dans les environnements avec des obstacles.
- Le A* bidirectionel : C'est une variante de A* qui lance une recherche simultanément depuis le départ et l'arrivée, il permet dedonc de réduire la zone à explorer.Il est plus rapide que A*, car les deux recherches se rencontrent au milieu du chemin.
#### Jump Point Search (JPS) : 
- Principe : Le JPS est une optimisation de A* pour les grilles 2D, il consiste à sauter les nœuds inutiles sur les lignes droites ( ex : zone marchable continue dans la direction voulue) et se concentre uniquement sur les points de décision critiques ( Apparition d'un obstacle).
- Avantages : 1. Plus rapide que A* sur les grilles, surtout si la grille est grande et contient de nombreux chemins linéaires sans obstacles.
              2. Il est très adapté pour les grilles raster où les zones marchables sont continues .
              
              
## 3.Implémentation des trois algorithmes : 
### 1. DIJKSTRA :
Cet algorithme permet de trouver le *plus court chemin* entre deux points sur un graphe pondéré avec des coûts fixes ou variable mais positifs.
- Dijkstra fonctionne en explorant tous les noeuds d'un graphe en calculant à chaque itération le coût le plus bas.
- A chaque itération il sélectionne le noeud le plus proche qui n'a pas été encore visité, puis il met à jour les coûts pour ces noeuds voisins et continue jusqu'à l'arrivé au neud voulu.

Pour utiliser Dijkstra sur une image raster ( matrice 2D: 0 pour les zones non marchables / 1 pour les zones marchables) :

1. Il faut Représentater de la grille comme un graphe :
- Chaque case de la matrice qui a une valauer 1 : marchable est considérée comme un nœud du graphe, tandis que 0 (non marchables) sont des obstacles, donc elles n'ont aucune arête connectée.
- Les voisins adjacents de chaque case (haut, bas, gauche, droite, et les diagonales ) sont connectés par des arêtes.
- Chaque arête entre deux cases a un coût (pondération). ( 1 par exemple ou autre coût basé sur une métrique de distance)

2. Application de l'algorithme : 
- Dijkstra est appliqué en partant du point de départ et en explorant chaque nœud marchable (cases de valeur 1) de manière à trouver le chemin le plus court jusqu'au point d'arrivée, en évitant les obstacles (cases de valeur 0).
- Dijkstra fonctionne bien avec les coûts uniformes (toutes les arêtes ont un coût de 1), mais on peut optimiser plus l'algorithme : 
- 1. Rendre les  coûts variables en essayant de simplifier des cases marchables horizontalement ou verticalement 
- 2. Rendre les coûts  variables en fonction du terrain (exemple : terrain difficile, passage à éviter .. ? ).

### Etapes de l'algorithme : 
```R
 
* Variables
 G : graphe représenté par une matrice d’adjacence ou une liste d’adjacence
 s : sommet source
 t : sommet de destination
 d : tableau des distances minimales entre s et chaque sommet v du graphe
 π : tableau des prédecesseurs (chemin le plus court) entre s et chaque sommet v du graphe
 Q : file à priorités (tas) contenant les sommets non visités, triée par distance minimale
* Algorithme
1. Initialisation :
     d[s] = 0 (distance minimale entre s et lui-même est 0)
     π[s] = s (prédecesseur de s est s lui-même)
     Q = {s} (ajoute s à la file à priorités)
2. Tant que Q n’est pas vide :
    u = ExtractMin(Q) (extraire le sommet avec la distance minimale la plus faible de la file à priorités)
    Pour chaque voisin v de u :
       dist = d[u] + weight(u, v) (calculer la distance entre u et v en ajoutant le poids de l’arête)
       Si dist < d[v] :
           d[v] = dist (mise à jour de la distance minimale entre s et v)
           π[v] = u (mise à jour du prédecesseur de v)
       Ajouter v à Q si v n’a pas encore été visité
3. Retourner d[t] (distance minimale entre s et t) et π (chemin le plus court entre s et t)
  ```
 ### Note : ExtractMin(Q) est une fonction qui extrait le sommet avec la distance minimale la plus faible de la file à priorités Q. weight(u, v) est une fonction qui retourne le poids de l’arête entre les sommets u et v.


### 2. A* :
L’algorithme A* est considéré parmi les meilleurs algorithmes de pathfinding. Il est utilisé généralement pour trouver le plus court chemin dans un graphe en combinant deux concepts principales de pathfinding :
  1. La recherche en largeur ( BFS ) :
La recherche en largeur d'abord (BFS - Breadth-First Search) consiste à explorer un graphe en largeur, c'est-à-dire qu'il parcourt d'abord tous les voisins immédiats du nœud de départ avant de s'aventurer plus loin. Pour ce faire, BFS utilise une file (queue) pour garder la trace des nœuds à visiter dans l'ordre où ils ont été découverts.
  2. La recherche en cout uniforme (Dijkstra) :
- But : Trouver le chemin le moins coûteux (ou le plus court) entre un point de départ et tous les autres points dans un graphe pondéré.
Dijkstra explore les chemins en minimisant le coût cumulé depuis le point de départ vers les autres nœuds.
Uniforme signifie ici que l'algorithme traite chaque nœud en fonction du coût réel accumulé, et non en fonction d'une estimation (comme c'est le cas pour le A*, qui utilise une heuristique).
 
- Concepts clés dans A* :
  * Graphe : une grille qui peut représenter : une maquette de jeu 2D ou une carte…. ou un système de navigation GPS) où chaque nœud représente un emplacement.
  * nœuds : Un nœud est une position dans l'espace que l'algorithme va explorer. Chaque nœud possède un coût pour être atteint.
  * Heuristique : Une fonction qui estime le coût restant pour atteindre l’objectif à partir d’un nœud donné. Elle permet à l’algorithme de choisir le chemin qui semble le plus prometteur.
    * g(n) : Le coût exact du chemin allant du point de départ jusqu'au nœud actuel n.
    * h(n) : L'estimation (heuristique) du coût restant pour aller du nœud actuel n à l’objectif. Elle ne doit jamais surestimer le coût réel pour garantir que A* trouve le chemin optimal.
    * f(n) : La somme des deux coûts, soit   C'est cette valeur qui est utilisée pour déterminer quel nœud explorer ensuite.
- Principe de fonctionnement:
  1. Initialisation :
    * Placez le point de départ dans une file appelée open set (ensemble ouvert), qui contient les nœuds à explorer.
    * Définissez g(start) = 0 (le coût de départ au départ est 0) et calculez                              f(start) = g(start) + h(start)
  2. Boucle principale :
    * Tant que l’open set n’est pas vide :
        1. Sélectionnez le nœud n ayant la plus petite valeur dans l’open set (le nœud le plus prometteur).
        2. Si ce nœud est le nœud objectif, l’algorithme est terminé : vous avez trouvé le chemin optimal.
        3. Sinon, déplacez le nœud n de l’open set vers un ensemble appelé closed set (ensemble fermé), ce qui signifie qu’il a été exploré.
        4. Explorez tous les voisins du nœud n :
            * Pour chaque voisin v, calculez le coût  pour aller au voisin en passant par le nœud n.
            * Si ce coût est inférieur au coût précédent calculé pour v, mettez à jour le chemin :  et  Ajoutez le voisin v à l’open set si ce n'est pas déjà fait.
  3. Reconstruction du chemin :
    Une fois l’objectif atteint, l’algorithme remonte le chemin en utilisant les nœuds parents de chaque nœud pour obtenir le chemin complet du départ à l’objectif.
 
- Les Heuristiques les plus utilisées dans A* :
  La qualité de l’heuristique  H(n) a un impact considérable sur l’efficacité de l’algorithme A* fortement
  * Distance de Manhattan : Utilisée dans les grilles où le mouvement est uniquement permis horizontalement ou verticalement (comme dans les jeux ou cartes 2D).
  * Distance Euclidienne : Utilisée lorsque le mouvement est permis dans toutes les directions (2D ou 3D).
  * Distance diagonale : Utilisée dans des grilles où le déplacement en diagonale est permis.


### 3. JPS : 

### 4. A* bidirectionnel : 



