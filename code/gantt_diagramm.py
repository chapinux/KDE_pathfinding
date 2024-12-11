import plotly.figure_factory as ff

data = [
    dict(Task="Initial Project Setup", Start="2023-06-13", Finish="2023-06-13"),
    dict(Task="Project Presentation Preparation", Start="2023-10-18", Finish="2023-10-18"),
    dict(Task="Data Acquisition and GeoJSON Processing", Start="2024-10-08", Finish="2024-10-09"),
    dict(Task="A* Algorithm Implementation", Start="2024-10-22", Finish="2024-10-23"),
    dict(Task="Pathfinding with Dijkstra's Algorithm", Start="2024-10-23", Finish="2024-11-11"),
    dict(Task="Grid and Heuristics Optimization", Start="2024-11-12", Finish="2024-11-26"),
    dict(Task="Raster to Graph Conversion", Start="2024-11-13", Finish="2024-12-04"),
    dict(Task="Performance Improvements and JPS implementation", Start="2024-12-05", Finish="2024-12-06"),
]



fig = ff.create_gantt(data)
fig.show()
