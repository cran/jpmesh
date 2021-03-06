#' @title Convert from coordinate to mesh code
#' @description From coordinate to mesh codes.
#' @param longitude longitude that approximately to .120.0 to 154.0 (`double`)
#' @param latitude latitude that approximately to 20.0 to 46.0 (`double`)
#' @param mesh_size Gives the unit in km for target mesh type.
#' That is, 1 for 1km, and 0.5 for 500m. From 80km to 125m. Default is 1.
#' @param geometry XY sfg object
#' @param ... other parameters
#' @importFrom rlang is_true quo_squash warn
#' @return mesh code (default 3rd meshcode aka 1km mesh)
#' @references Akio Takenaka: [http://takenaka-akio.org/etc/j_map/index.html](http://takenaka-akio.org/etc/j_map/index.html) # nolint
#' @seealso [mesh_to_coords()] for convert from meshcode to coordinates
#' @examples
#' coords_to_mesh(141.3468, 43.06462, mesh_size = 1)
#' coords_to_mesh(139.6917, 35.68949, mesh_size = 0.250)
#' coords_to_mesh(139.71475, 35.70078)
#' coords_to_mesh(c(141.3468, 139.71475), 
#'                c(43.06462, 35.70078), 
#'                mesh_size = c(1, 10))
#' # Using sf (point as sfg object)
#' library(sf)
#' coords_to_mesh(geometry = st_point(c(139.71475, 35.70078)))
#' coords_to_mesh(geometry = st_point(c(130.4412895, 30.2984335)))
#' @export
coords_to_mesh <- function(longitude, latitude, mesh_size = 1, geometry = NULL, ...) { # nolint
  to_mesh_size <- 
    units::as_units(mesh_size, "km")
  if (rlang::is_true(identical(which(to_mesh_size %in% mesh_units[-8]), integer(0)))) # nolint
    rlang::abort(
      paste0("`mesh_size` should be one of: ",
             paste(
               units::drop_units(mesh_units)[-seq.int(7, 8)],
               collapse = ", "),
             " or ",
             paste(units::drop_units(mesh_units)[7])))
  if (rlang::is_false(is.null(geometry))) {
    geometry <- 
      sf::st_sfc(geometry)
    coords <-
      lapply(geometry, function(x) {
        if (sf::st_is(x, "POINT"))
          list(longitude = sf::st_coordinates(x)[1],
               latitude =  sf::st_coordinates(x)[2])
        else
          list(longitude = sf::st_coordinates(sf::st_centroid(x))[1],
               latitude =  sf::st_coordinates(sf::st_centroid(x))[2])
      })
    if (!rlang::is_missing(longitude) | !rlang::is_missing(latitude))
      rlang::inform("the condition assigned coord and geometry, only the geometry will be used") # nolint
    longitude <-
      coords %>%
      purrr::map("longitude")
    latitude <-
      coords %>%
      purrr::map("latitude")
  } else {
    longitude <- rlang::quo_squash(longitude)
    latitude <- rlang::quo_squash(latitude)
  }
  purrr::pmap(
    list(longitude = longitude,
         latitude = latitude,
         to_mesh_size = to_mesh_size),
    ~ .coord2mesh(..1, ..2, ..3)) %>% 
    purrr::reduce(c)
}

.coord2mesh <- function(longitude, latitude, to_mesh_size) {
  .x <- .y <- NULL
  coords_evalated <-
    purrr::map2_lgl(longitude,
                    latitude,
                    ~ eval_jp_boundary(.x, .y))
  if (coords_evalated == FALSE) {
    rlang::warn("Longitude / Latitude values is out of range.")
    return(NA_character_)
  }
  if (coords_evalated == TRUE) {
    code12 <- (latitude * 60) %/% 40
    code34 <- as.integer(longitude - 100)
    check_80km_ares <- 
      paste0(code12, code34) %>%
      match(meshcode_80km_num) %>% # nolint
      any()
    if (rlang::is_true(check_80km_ares)) {
      code_a <- (latitude * 60) %% 40
      code5 <- code_a %/% 5
      code_b <- code_a %% 5
      code7 <- (code_b * 60) %/% 30
      code_c <- (code_b * 60) %% 30
      code_s <- code_c %/% 15
      code_d <- code_c %% 15
      code_t <- code_d %/% 7.5
      code_e <- code_d %% 7.5
      code_u <- code_e %/% 3.75
      code_f <- (longitude - 100) - as.integer(longitude - 100)
      code6 <- (code_f * 60) %/% 7.5
      code_g <- (code_f * 60) %% 7.5
      code8 <- (code_g * 60) %/% 45
      code_h <- (code_g * 60) %% 45
      code_x <- code_h %/% 22.5
      code_i <- code_h %% 22.5
      code_y <- code_i %/% 11.25
      code_j <- code_i %% 11.25
      code_z <- code_j %/% 5.625
      code9 <- (code_s * 2) + (code_x + 1)
      code10 <- (code_t * 2) + (code_y + 1)
      code11 <- (code_u * 2) + (code_z + 1)
      meshcode <- paste0(code12,
                         code34,
                         code5,
                         code6,
                         code7,
                         code8,
                         code9,
                         code10,
                         code11)
      meshcode <-
        if (to_mesh_size == units::as_units(80.000, "km")) {
          substr(meshcode, 1, 4)
        } else if (to_mesh_size == units::as_units(10.000, "km")) {
          substr(meshcode, 1, 6)
        } else if (to_mesh_size == units::as_units(5.000, "km")) {
          paste0(substr(meshcode, 1, 6),
                 (code_b %/% (5 / 2) * 2) + (code_g %/% (7.5 / 2) + 1))
        } else if (to_mesh_size == units::as_units(1.000, "km")) {
          substr(meshcode, 1, 8)
        } else if (to_mesh_size == units::as_units(0.500, "km")) {
          substr(meshcode, 1, 9)
        } else if (to_mesh_size == units::as_units(0.250, "km")) {
          substr(meshcode, 1, 10)
        } else if (to_mesh_size == units::as_units(0.125, "km")) {
          meshcode
        }
      meshcode(meshcode)
    } else if (is.na(check_80km_ares)) {
      rlang::warn("Longitude / Latitude values is out of range.")
      return(NA_character_)
    }
  }
}
