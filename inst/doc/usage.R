## ---- warning = FALSE, message = FALSE-----------------------------------
library(jpmesh)
library(sf)
library(purrr)

## ------------------------------------------------------------------------
mesh_to_coords(5133)
mesh_to_coords(513377)
mesh_to_coords(51337783)

## ------------------------------------------------------------------------
export_mesh(5133778311)

## ------------------------------------------------------------------------
coords_to_mesh(133, 34)
coords_to_mesh(133, 34, mesh_size = "80km")
coords_to_mesh(133, 34, mesh_size = "125m")

## ------------------------------------------------------------------------
# 80kmメッシュに含まれる10kmメッシュを返します
coords_to_mesh(133, 34, "80km") %>% 
  fine_separate()

# 隣接するメッシュコードを同じスケールで返します
coords_to_mesh(133, 34, "80km") %>% 
  neighbor_mesh()
coords_to_mesh(133, 34, "500m") %>% 
  neighbor_mesh()

## ---- results = "asis"---------------------------------------------------
administration_mesh(code = 33, type = "prefecture") %>% 
  head() %>% 
  knitr::kable(format = "markdown")

## ---- sessioninfo--------------------------------------------------------
sessionInfo()

