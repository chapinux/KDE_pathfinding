#chargement des packages utiles
library(sf) # manip données spatiales
library(ggplot2) # graphiques
library(dplyr) #manipulation de dataframe 
library(geojsonR) # entrée/sortie avec format geojson
library(leaflet) #carto web 
library(raster) #raster
library(MASS) # idem 



# définition répertoire de travail 
setwd("~/encadrement/PIR_2024_2025/KDE_pathfinding/") 



#chargement des données 
boutiques <- st_read("./data/boutiques.geojson")
restaurants <- st_read("./data/restos.geojson")
tramway <- st_read("./data/tramway.geojson")
zonepieton <- st_read("./data/zonepieton.geojson")
buildings <-  st_read("./data/BUILDINGS_NS.geojson")


#ajout d'un type pour les légendes

zonepieton$type <-  "zone marchable"
boutiques$type <-  "boutiques"
tramway$type <-  "arrêt de tram"
restaurants$type <- "restaurants"
buildings$type <- "bâti"


# projection Lambert 93 
st_crs(boutiques) <-  2154
st_crs(tramway) <-  2154
st_crs(zonepieton) <-  2154
st_crs(restaurants) <-  2154
st_crs(buildings) <-  2154


# affichage simple des géométries (sf)
plot(zonepieton$geometry, border="grey80")
plot(buildings$geometry, add=T, col="grey70", lwd=0.7)
plot(boutiques$geometry, add=T, col="orange", pch=18, cex=0.9)
plot(tramway$geometry, add=T, col="blue", pch=18, cex=0.7)
plot(restaurants$geometry, add=T, col="darkcyan", pch=18, cex=0.7)





# on met tous les points d'intérêt dans un seul dataframe
# on vérifie que les PK (ID) sont bien uniques 
all_IDs <-  c(tramway$PK, restaurants$PK, boutiques$PK)
length(unique(all_IDs))== length(all_IDs)

# on concatène les trois couches , il faut que le nombre et les noms de colonnes corresponde 
names(restaurants) %in% names(boutiques) %>%  all
names(restaurants) %in% names(tramway) %>% all
length(names(restaurants)) == length (names(tramway))
length(names(boutiques)) == length (names(tramway))


# concaténation des trois couches en une seule 
POI <- rbind(restaurants,boutiques,tramway)



# affichage plus complexe (ggplot2), avec légende automatique 
# couleurs au hasard


map1 <- ggplot()+
  geom_sf(data=zonepieton, aes(fill= type), color="grey80", lwd=0.2)+
  geom_sf(data=buildings, aes(fill= type), color="grey50", lwd=0.2 )+
  geom_sf(data=POI, aes(color= type, shape=type) )+
  scale_fill_manual(values = c("slategray1","palegreen" ))+
  scale_color_manual(values=c("black", "orange", "orchid3"))+
  labs(color="Points d'intérêt \n (POI)",
       shape="Points d'intérêt \n (POI)",
       fill="Occupation du sol")+
  theme_void()
map1



#affichage avec leaflet (beaucoup moins maniable)

# il faut reprojeter en WGS 84 
POI84 <- st_transform(POI,4326)
zonepieton84 <- st_transform(zonepieton,4326)

POI$lat <-  sf::st_coordinates(POI84)[,"Y"]
POI$long <-  sf::st_coordinates(POI84)[,"X"]


# legende de couleur , discrete
POICol <- colorFactor(palette = 'RdYlGn', POI$type)


map2 <-  leaflet() %>% 
  addTiles() %>%
  addPolygons(data=zonepieton84,weight=2) %>% 
  addCircleMarkers(data=POI84,color =~POICol(type ) ,radius=0.5, opacity=100) %>% 
  addLegend('bottomright', pal = POICol, values = POI$type,
            title = 'Point of Interest',opacity = 100)
map2




# on vérifie visuellement que la zone est connexe 
plot(zonepieton["EXPLOD_ID"])
#elle ne l'est pas , on va virer les petites zones non connectées à la grande 


#on détermine quelle est la plus grande géométrie 
index_surf_max <- which.max(st_area(zonepieton$geometry))
#on remplace la zone par la plus grande composante connexe 
zonepieton <- zonepieton %>% slice(index_surf_max)





# creation de la grille 
grid_10mx10m <- st_make_grid(zonepieton, cellsize = 10)
plot(grid_10mx10m)

grid_pieton <-  st_intersection(zonepieton,grid_10mx10m)
plot(grid_pieton$geometry)


#centroides des mailles, ça peut servir 
centro <-  st_centroid(grid_pieton)
plot(centro$geometry, cex=0.2, color="royalblue", lwd=0, pch=18 )

















# code pour plus tard 
# fonction qui calcule le KDE de base (fonction kde2D du package MASS)

st_kde <- function(points,cellsize, bandwith, extent = NULL){
  require(MASS)
  require(raster)
  require(sf)
  if(is.null(extent)){
    extent_vec <- st_bbox(points)[c(1,3,2,4)]
  } else{
    extent_vec <- st_bbox(extent)[c(1,3,2,4)]
  }
  
  n_y <- ceiling((extent_vec[4]-extent_vec[3])/cellsize)
  n_x <- ceiling((extent_vec[2]-extent_vec[1])/cellsize)
  
  extent_vec[2] <- extent_vec[1]+(n_x*cellsize)-cellsize
  extent_vec[4] <- extent_vec[3]+(n_y*cellsize)-cellsize
  
  coords <- st_coordinates(points)
  matrix <- kde2d(coords[,1],coords[,2],h = bandwith,n = c(n_x,n_y),lims = extent_vec)
  raster(matrix)
}


boutiques_dens <- st_kde(boutiques,20,300)
restaurants_dens <- st_kde(restaurants,20,400)
tramway_dens <- st_kde(tramway,20,400)

plot(boutiques_dens)
plot(restaurants_dens)
plot(tramway_dens)


