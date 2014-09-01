#' Kill all droplets.
#'
#' @export
#' @param x A droplet number or the result from a call to \code{droplets()}
#' @return A message that the droplet(s) has/have been killed.
#' @examples \dontrun{
#' droplets_kill() # kill all droplets
#' droplets_kill(2508542) # kill 1 or more droplets by id numbers
#' droplets(<droplet id>) %>% droplets_kill # kill all droplets via a call to droplets()
#' }

droplets_kill <- function(x=NULL, ask=TRUE){
  ids <- if(is.numeric(x)) { x } else {
    ids <- droplets()
    ids$droplets$data$id
  }
  if(is.null(ids)) stop("No droplets found :/ Spin up a new droplet with droplets_new()", call. = FALSE)
  if(ask && !is.numeric(x)){
    message("Are you sure you want to delete all your droplets? (y/n)")
    resp <- readline(": ")
  } else { resp <- 'y' }
  if(resp %in% c('y','yes','Yes','YES')) invisible(lapply(ids, droplets_delete)) else stop("okay, no worries", call. = FALSE)
}
