% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/snapshots.R
\name{as.snapshot}
\alias{as.snapshot}
\alias{snapshots}
\alias{snapshot}
\alias{snapshot_delete}
\title{Snapshot operations}
\usage{
as.snapshot(x)

snapshots(type = NULL, page = 1, per_page = 20, ...)

snapshot(id, ...)

snapshot_delete(snapshot, ...)
}
\arguments{
\item{x}{Object to coerce to an snapshot}

\item{type}{(character) \code{NULL} (all snapshots), or one of droplet
(droplet snapshots) or volume (volume snapshots)}

\item{page}{Which 'page' of paginated results to return (default 1).}

\item{per_page}{Number of items returned per page (default 20, maximum 200)}

\item{...}{Additional options passed down to \code{\link[httr]{GET}},
\code{\link[httr]{POST}}, etc.}

\item{id}{A snapshot id (varies depending on droplet or volume ID)}

\item{snapshot}{A snapshot, or something that can be coerced to a snapshot by
\code{\link{as.snapshot}}.}
}
\description{
\describe{
\item{snapshot}{retrieve a snapshot}
\item{snapshots}{list snapshots, all, droplets, or volumes}
\item{snapshot_delete}{delete a snapshot}
}
}
\examples{
\dontrun{
# list all snapshots
(res <- snapshots())

# list droplet snapshots
snapshots(type = "droplet")

# list volume snapshots
snapshots(type = "volume")

# paging
snapshots(per_page = 5)
snapshots(per_page = 5, page = 2)

# get a single snapshot
snapshot(res[[1]]$id)

# delete a snapshot
## a whole snapshot class object
snapshot_delete(res[[2]])
## by id
snapshot_delete(res[[2]]$id)
## by name
snapshot_delete(res[[2]]$name)

# delete many snapshots
lapply(snapshots(), snapshot_delete)
}
}
