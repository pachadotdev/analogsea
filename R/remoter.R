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
#' # If you already have a droplet
#' (d <- droplets()[[1]])
#' path <- remoter({
#'   install.packages("ggplot2")
#'   library('ggplot2')
#'   carsplot <- qplot(mpg, wt, data=mtcars)
#'   df <- diamonds[1:5000,]
#'   diaomondsplot <- qplot(cut, carat, data=df)
#'   numbers <- runif(100)
#' }, droplet = d)
#' remoter_load(path)
#' 
#' # With a new droplet
#' path <- remoter({
#'   numbers <- runif(100)
#' }, droplets()[[3]])
#' remoter_load(path)
#' }

remoter <- function(code, droplet=NULL, verbose=TRUE, savepath=NULL){
  
  # spin up new droplet, collect info
  if(is.null(droplet)) droplet <- droplet_new()
  id <- droplet$id
  tmp2 <- droplet(id)
  ip <- tmp2$networks$v4[[1]]$ip_address

  # wait until droplet is up and running
  mssg(verbose, "Waiting for droplet to spin up")
  wait_running(id)
  
  # check if R is installed, and if not, install R
  do_swap(TRUE, ip, swap_string, verbose)
  r_installed(ip, r_string, verbose)

  # deparse input code, write to file
  code_string <- parse_code(code)
  writefile("remoter_code.R", code_string)

  # send and run code on droplet
  mssg(verbose, "Sending R code to DO Droplet...")
  scp('remoter_code.R', ip)
  mssg(verbose, "Running R code on DO Droplet...")
  writefile('remoter_run.sh', sprintf(run_r, 'remoter_code.R'))
  scp_ssh('remoter_run.sh', ip, verbose = verbose)

  # Retrieve results from droplet
  mssg(verbose, "Receiving results from DO Droplet...")
  savepath <- if(is.null(savepath)) tempdir() else savepath
  scp_get(file = 'output.RData', ip, path = savepath)

  # Delete the droplet
  answer <- readline("Delete droplet? (y/n) ")
  answer <- match.arg(answer, c('yes','no'))
  if(answer=="yes"){
    droplet_delete(tmp2)
    message(sprintf("Droplet %s deleted", id))
  } else { message("droplet still running") }
  
  return( savepath )
}

remoter_load <- function(x){
  path <- file.path(x, 'output.RData')
  assert_that(file.exists(path))
  load(path, envir = .GlobalEnv, verbose = TRUE)
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

run_r <- 'R -e \'source(\"%s\"); save.image(\"~/output.RData\")\''
