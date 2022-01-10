## ---- warning = FALSE, message = FALSE----------------------------------------
library(jpmesh)
library(sf)
library(purrr)

## -----------------------------------------------------------------------------
mesh_to_coords(5133)
mesh_to_coords(513377)
mesh_to_coords(51337783)

## -----------------------------------------------------------------------------
export_mesh(5133778311)

## -----------------------------------------------------------------------------
coords_to_mesh(133, 34)
coords_to_mesh(133, 34, to_mesh_size = 80)
coords_to_mesh(133, 34, to_mesh_size = 0.125)

## -----------------------------------------------------------------------------
# 80kmメッシュに含まれる10kmメッシュを返します
coords_to_mesh(133, 34, to_mesh_size = 80) %>% 
  fine_separate()

# 隣接するメッシュコードを同じスケールで返します
coords_to_mesh(133, 34, to_mesh_size = 80) %>% 
  neighbor_mesh()
coords_to_mesh(133, 34, 0.5) %>% 
  neighbor_mesh()

## ---- results = "asis"--------------------------------------------------------
administration_mesh(code = 33, to_mesh_size = 80) %>% 
  head() %>% 
  knitr::kable(format = "markdown")

## ---- sessioninfo-------------------------------------------------------------
sessionInfo()

