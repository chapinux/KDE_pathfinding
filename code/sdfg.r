library(igraph)

#initialisation du raster, obstacle et génération dynamique des couples de test
r <- raster("./data/Raster_zone_marchable/Zone_marchable_raster.tif")
r_aggregated <- aggregate(r, fact = 2, fun = mean)
r <- r_aggregated
    
grid_rows <- nrow(r)
grid_cols <- ncol(r)
total_nodes <- grid_rows * grid_cols

#print(paste( " Nombre de pixel :", nombre_pixels))


marchable_value <- 31.00
pixel_values <- values(r)
indices_1 <- which(pixel_values == marchable_value)

indices_0 <- which(pixel_values != marchable_value)

#print(indices_1)
#print(indices_0)
obstacles <- indices_0

## couple de test
set.seed(4506)  # Pour reproductibilité
num_pairs <- 25 #nombre de couples de test
# Fonction pour générer un point accessible aléatoire
generate_accessible_point <- function(excluded_points) {
  repeat {
    point <- sample(1:total_nodes, 1)  # Point aléatoire
    if (!(point %in% excluded_points)) {
      return(point)
    }
  }
}
# Liste pour stocker les couples (start, end)
test_pairs <- vector("list", num_pairs)
# Générer les couples
for (i in 1:num_pairs) {
  start <- generate_accessible_point(obstacles)
  end <- generate_accessible_point(c(obstacles, start))  # Le point de destination doit aussi être accessible et différent
  test_pairs[[i]] <- list(start = start, end = end)  # Chaque paire est une liste avec start et end
}

# Sauvegarde dans un fichier RDS
saveRDS(test_pairs, "test_pairs.rds")
test_cases <- readRDS("test_pairs.rds")
print(test_cases)