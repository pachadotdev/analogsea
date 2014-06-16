#' Get metadata on all your droplets, or droplets by id
#'
#' @importFrom magrittr %>%
#' @export
#' @param droplet A droplet number or the result from a call to \code{droplets()}
#' @template params
#' @examples \dontrun{
#' actions()
#' }

actions <- function(id=NULL, what="parsed", ...)
{
#   if(!is.null(droplet)){
#     if(is.list(droplet)){
#       if(!is.numeric(droplet$id)) stop("Could not detect a droplet id")
#     } else {
#       if(!is.numeric(as.numeric(as.character(droplet)))) stop("Could not detect a droplet id")
#     }
#     id <- if(is.numeric(droplet)) droplet else droplet$id
#   } else { id <- NULL }
  path <- if(is.null(id)) 'actions' else sprintf('actions/%s', id)
  tmp <- do_GET(what, FALSE, path, ...)
  if(what == 'raw'){ tmp } else {
#     if ("droplet" %in% names(tmp)){
#       names(tmp) <- "droplets"
#       ids <- tmp$droplets$id
#     } else { ids <- sapply(tmp$droplets, "[[", "id") }
#     list(droplet_ids = ids, droplets = tmp$droplets, event_id=NULL)
    tmp
  }
}


# curl -X $HTTP_METHOD -H "Authorization: Bearer $TOKEN""https://api.digitalocean.com/v2/$OBJECT"