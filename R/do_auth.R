#' Set up authentication details for the Digital Ocean API
#' 
#' Create an object and pass on to each function call.
#' 
#' @export
#' @param client_id Your Digital Ocean client id.
#' @param api_key Your Digital Ocean api key.
#' @return A simple S3 class ("doauth") as a list that has a print method to nicely print out your 
#' auth details.
#' @examples
#' client_id = '<client id>'
#' api_key = '<api key>'
#' do_auth(client_id=client_id, api_key=api_key)
#' 
#' # from .Rprofile
#' do_auth2()
do_auth <- function(client_id = NULL, api_key = NULL)
{
  console <- if(is.null(client_id) & is.null(api_key)) FALSE else TRUE
  if(is.null(client_id)) client_id <- getOption('do_client_id')
  if(is.null(api_key)) api_key <- getOption('do_api_key')
  res <- list(client_id = client_id, api_key = api_key)
  class(res) <- "doauth"
  attr(res, "from") <- if(console) "console" else ".Rprofile"
  return( res )
}

#' Print method for doauth object
#' @export
#' @param x Object of class doauth
#' @param ... Further args, ignored
#' @rdname do_auth
print.doauth <- function(x, ...){
  cat("Client ID: ", x$client_id, "\n")
  cat("API key:   ", x$api_key, "\n")
  cat("from:      ", attr(x, "from"))
}

do_auth2 <- function(force = FALSE) {
  env <- Sys.getenv('DO_CLIENT_ID')
  if (!identical(env, "") && !force) return(env)
  if (!interactive()) {
    stop("Please set env var DO_CLIENT_ID to your Digital Ocean Client Id (CI)",
         call. = FALSE)
  }
  message("Couldn't find env var DO_CLIENT_ID. See ?do_auth for more details.")
  message("Please enter your CI and press enter:")
  clientid <- readline(": ")
  if (identical(clientid, "")) {
    stop("Github personal access token entry failed", call. = FALSE)
  }
  message("Updating DO_CLIENT_ID env var")
  Sys.setenv(DO_CLIENT_ID = clientid)
  clientid
  
  env2 <- Sys.getenv('DO_API_KEY')
  if (!identical(env2, "") && !force) return(env2)
  if (!interactive()) {
    stop("Please set env var DO_API_KEY to your Digital Ocean API key",
         call. = FALSE)
  }
  message("Couldn't find env var DO_API_KEY See ?do_auth for more details.")
  message("Please enter your CI and press enter:")
  apikey <- readline(": ")
  if (identical(apikey, "")) {
    stop("Github personal access token entry failed", call. = FALSE)
  }
  message("Updating DO_API_KEY env var")
  Sys.setenv(DO_API_KEY = apikey)
  apikey
}