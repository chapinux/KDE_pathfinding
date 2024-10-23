# ESTIMATION DE LA DENSITÉ 2D PAR NOYAU DANS L’ESPACE URBAIN
 PIÉTON
 
## 1. Etat de l’art sur le pathfinding 2D

## Ressources bibliographiques
1. [Planning as heuristic search Blai Bonet ∗, Héctor Geffner](https://pdf.sciencedirectassets.com/271585/1-s2.0-S0004370200X0077X/1-s2.0-S0004370201001084/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEgaCXVzLWVhc3QtMSJIMEYCIQDy4E4uEtroJsB4pUhSj5loIrIhP19pF0JdotiwNOpvHgIhAK%2BTcTgYR4BJPMBHCITlVCfvqQJnEyNmko1dN6GJoW6kKrwFCLD%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQBRoMMDU5MDAzNTQ2ODY1Igzx1vhyXFBpQsfQiWcqkAX56QE%2Fny%2F78Wo242Wgi1FsXmRlU%2BfFJDANAMF5VzJAnIpEhIYFJFhK2H18DsJ76VxIevkUQ7qNeV93xGo0nySxh3Zb0uY3LAjefop4rutgmbvzC9l3zUGWGugSIIMo9oNnzjgxPCTRGG2jVxf6bQwGCWKoERvoB4aY3inwOjloFu%2Ft0EPDLxGtTkBI756zBYgs%2Fry690MQX7aBcnZhjvDr%2Bqa1J6ZsJ4gphXUHBGQ9a7iIjlcMT62PdOVb7najkLBnlrX2x47wurjxaJVJf%2Blj4ilw5v8Fg3LTRRLzKLmn%2FTaY2uF7CO%2BaYXUPE8fGBXNGN1OUnvoOSh6MEwXs1G0sV52h9uKkRbwEwmrfdpjUIG4cgxJOIQUXhivYqAD3lbWQSSinjw7ZLTz0sjl8%2BHuALMCRayr8V7MZlrLwnP3YPZldiiUtsijaIs384nOj4L6b%2FGo293yM3OcZuWY8IMBq7UjA%2FIm7%2Fzsrgv94aVOePcpl3dLYuiAVWAWl9jB3Th47k%2B88%2FVNUE51DHP6qBN%2FOB%2F4d22Tb9D7Tvkm%2BUfI1TkwyqFwOBckbdNbuAdMzAkhFV%2BCZZy22lfkWRdtziKq4vR4Tk2GKjxM4l9GuyIxFDSN0W81pkDRo%2BqIRKxJBUeljH8i2bJqJpq9VcEtqZRnjGQOjwnPAHpU4dVHCvkmALEuGx8kC5h5g27OmxRRJY61IFEBog%2BdysSoMOUyyprJrQmVQVsM4VweHuqiQ1fVoJM60imF%2Bfvmf5i6tpNDrckQdeej%2FcjXRTKNNPUJotl7iMhTuu1v2qbHXcwzm1QxQEA%2BzeB7S3fQP9fguhzKNwVE3bhBC86QQ7YpuuI73yB4H5GK19T%2BVwPFpzAcEYsOlfTCF3%2BC4BjqwAZXmyHevAAyJXZ75j4CSDak7pPiGWs1jelunObrHdoSC1Jdjf2nNGrKtVXMHg3gmVYI5apEBnqQ02xJ37aAiptIa8VIbBGWTUY2JLReOeXeKOPl0mlsspJ%2BQ0ItLu8H1IetxUQNWYBVDXnNiPgHGpPE3HWC4OB2vCGIXmRhPSTXY7P6UDXd4GZuysQbtaPGW75BDq%2BsFgqbTC1Swj0aCzocLmboY55HzmRTFXJmRNey6&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20241022T234113Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTYRKPKQWBY%2F20241022%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=9bc9fa07a2a8de7a46d0f02a3af279138414c0f9122662447cb849ab820df919&hash=a8ad86df766c61a9b40b851b6473ebd37a3408332e5f7e3e940557af5f08ee44&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S0004370201001084&tid=spdf-f9ca8a14-cc41-4c54-96d3-292d9f6de8c2&sid=841a6b079377204b128bb1711bb48209f5b8gxrqb&type=client&tsoh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&ua=00105f02590355525056&rr=8d6d564029ff9e55&cc=fr)


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
### Les 3 algorithmes choisis :
#### Dijkstra :
- Principe : Explore  tous les chemins en calculant le coût le plus bas depuis un point de départ jusqu'à chaque autre nœud.
- Avantages : 1. le Dijkstra trouve toujours le chemin le plus court mais il ne dépend pas d'une heuristique ce qui le rend plus lent que A* dans les grands grilles.
              2. Disponible dans le package igraph pour des graphes pondérés, il peut être utilisé pour des grilles raster converties en graphe.
#### A (A-star Algorithm)* / A* Bidirectionel : 
- Principe : le A* utilise une fonction heuristique pour explorer les chemins les plus prometteurs en utilisant une combinaison du  coût réel ( noté souvent g(n) ) et une estimation de la distance restante par une heuristique ( noté souvent h(n)).
- Avantages : Trouve le chemin optimal, rapide grâce à l'heuristique, particulièrement adapté pour les grilles 2D et très efficace dans les environnements avec des obstacles.
- Le A* bidirectionel : C'est une variante de A* qui lance une recherche simultanément depuis le départ et l'arrivée, il permet dedonc de réduire la zone à explorer.Il est plus rapide que A*, car les deux recherches se rencontrent au milieu du chemin.
#### Jump Point Search (JPS) : 
- Principe : Le JPS est une optimisation de A* pour les grilles 2D, il consiste à sauter les nœuds inutiles sur les lignes droites ( ex : zone marchable continue dans la direction voulue) et se concentre uniquement sur les points de décision critiques ( Apparition d'un obstacle).
- Avantages : 1. Plus rapide que A* sur les grilles, surtout si la grille est grande et contient de nombreux chemins linéaires sans obstacles.
              2. Il est très adapté pour les grilles raster où les zones marchables sont continues .
              
              
## 3.Implémentation des trois algorithmes : 

