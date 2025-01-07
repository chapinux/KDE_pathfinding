import plotly.figure_factory as ff

data = [
    dict(Task="Explication du sujet, compréhension du travail demandé et du problème associé", Start="2024-10-02", Finish="2024-10-14"),
    dict(Task="Recherche bibliographique sur le sujet : Pathfinding 2D", Start="2024-10-02", Finish="2024-10-16"),
    dict(Task="Identification et sélection des algorithmes de pathfinding 2D les plus adaptés", Start="2024-10-02", Finish="2024-10-17"),
    dict(Task="Recherche bibliographique approfondie sur les algorithmes A* et Dijkstra", Start="2024-10-23", Finish="2024-11-14"),
    dict(Task="Implémentation de base des algorithmes A* et Dijkstra", Start="2024-10-23", Finish="2024-11-15"),
    dict(Task="Recherche bibliographique sur l'algorithme JPS", Start="2024-11-06", Finish="2024-11-15"),
    dict(Task="Implémentation de JPS", Start="2024-11-06", Finish="2024-12-15"),
    dict(Task="Développement du code pour convertir le raster en graphe", Start="2024-11-15", Finish="2024-12-18"),
    dict(Task="Tests initiaux des algorithmes Dijkstra et A*", Start="2024-12-11", Finish="2024-12-30"),
    dict(Task="Amélioration du raster de la zone praticable", Start="2024-12-19", Finish="2024-12-19"),
    dict(Task="Benchmarking des algorithmes", Start="2024-12-19", Finish="2024-12-19"),
    dict(Task="Changement dans le graphe utilisé par Dijkstra", Start="2025-01-05", Finish="2025-01-07"),
    dict(Task="Rédaction des rapports et préparation des diapositives de présentation", Start="2025-01-05", Finish="2025-01-07"),
]







fig = ff.create_gantt(data)
fig.show()
