#' Execute code remotely on Digital Ocean in a single command.
#'
#' See Details.
#'
#' @param x Code to excute on Digital Ocean droplet.
#' @param verbose (logical) Print messages
#' @details
#' This function (when complete, that is):
#' \itemize{
#'  \item Spin up a new droplet, or use an existing one.
#'  \item Parse your code input to parameter \code{x}
#'  \item Send code to droplet
#'  \item Execute code on droplet
#'  \item Return code to the session or directory when complete
#'  \item Destory droplet
#' }
#' @examples \dontrun{
#' remoter({
#'   head(mtcars)
#'   head(iris)
#' })
#' }

remoter <- function(x, verbose=TRUE){
  # spin up new droplet, collect info
  tmp <- droplet_new()
  id <- tmp$id
  tmp2 <- droplet(id)
  ip <- tmp2$networks$v4[[1]]$ip_address

  # wait until droplet is up and running
  mssg(verbose, "Waiting for droplet to spin up")
  wait_running(id)

  # deparse input code, write to file
  tmp <- parse_code(x)
  writefile("remoter_send.txt", tmp)

  # send and run code on droplet
  mssg(verbose, "Sending R code to DO Droplet...")
  scp_ssh('remoter_send.txt', ip)
  mssg(verbose, "Running R code on DO Droplet...")
  writefile('remoter_run.sh', 'xxxx')
  scp_ssh('remoter_run.sh', ip)

  # Retrieve results from droplet
  mssg(verbose, "Receiving results from DO Droplet...")
  writefile('remoter_get.sh', 'xxxx')
  scp_ssh('remoter_get.sh', ip)

  # Delete the droplet
  droplet_delete(tmp2)
  mssg(verbose, sprintf("Droplet %s deleted", id))
}

wait_running <- function(id){
  stat <- "new"
  while(stat == "new"){
    Sys.sleep(1)
    out <- droplet(id)
    stat <- out$status
  }
}

parse_code <- function(x){
  tmp <- deparse(substitute(x))
  tmp <- gsub("\\s+", "", tmp)
  tmp <- tmp[-c(1,length(tmp))]
  paste(tmp, collapse = "\n")
}
