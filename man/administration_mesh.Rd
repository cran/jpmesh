% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/administration_mesh.R
\name{administration_mesh}
\alias{administration_mesh}
\title{Extract administration mesh code}
\usage{
administration_mesh(code, to_mesh_size)
}
\arguments{
\item{code}{administration code}

\item{to_mesh_size}{target mesh type. From 80km to 0.100km. If \code{NULL},
the meshcode of one small scale will be returned.
If it is the same as the original size, the meshcode of the input
will be return.}
}
\description{
Extract administration mesh code
}
\examples{
\dontrun{
administration_mesh(code = "35201", to_mesh_size = 1)
administration_mesh(code = "08220", to_mesh_size = 80)
administration_mesh(code = c("08220", "08221"), to_mesh_size = 10)
administration_mesh(code = "35", to_mesh_size = 80)
administration_mesh(code = c("33", "34"), to_mesh_size = 80)
}
}
