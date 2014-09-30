#' Remotely execute ssh code on a droplet.
#' 
#' Assumes that you have ssh installed, and password-less login set up
#' on the droplet.
#' 
#' @param droplet  A droplet, or something that can be coerced to a droplet by
#'   \code{\link{as.droplet}}.
#' @param cmd Shell command to run
#' @param user User
#' @return On success, the droplet (invisibly). On failure, throws an 
#'   error.
#' @examples
#' \dontrun{
#' d <- droplet_new() %>% droplet_wait()
#' 
#' # Upgrade system packages
#' d %>% 
#'   droplet_ssh("apt-get update") %>% 
#'   droplet_ssh("sudo apt-get upgrade -y --force-yes") %>%
#'   droplet_ssh("apt-get autoremove -y") 
#'   
#' # Install R
#' d %>%
#'   droplet_ssh("apt-get install r-base-core r-base-dev --yes --force-yes")
#' }
droplet_ssh <- function(droplet, cmd, user = "root", verbose = FALSE) {
  droplet <- as.droplet(droplet)
  
  cmd <- sprintf("ssh -o StrictHostKeyChecking=no %s@%s %s", user, 
    droplet_ip(droplet), shQuote(cmd))
  
  mssg(verbose, cmd)
  status <- system(cmd)
  if (status != 0) {
    stop("ssh failed\n", cmd, call. = FALSE)
  }
  
  invisible(droplet)
}

droplet_ip <- function(x) {
  v4 <- x$network$v4
  if (length(v4) == 0) {
    stop("No network interface registered for this droplet",
      call. = FALSE)
  }
  
  v4[[1]]$ip_address
}
