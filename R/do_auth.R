#' Set up authentication details for the Digital Ocean API
#'
#' This function sets options in your current R session, and passes on to each function call.
#'
#' @export
#' @param client_id (character) Your Digital Ocean client ID. Default NULL
#' @param api_key (character) Your Digital Ocean API key. Default NULL
#' @param force (logical) Force update
#'
#' @return A simple S3 class ("doauth") as a list that has a print method to nicely print out your
#' auth details.
#' @details  There are three ways you can use this function.
#'
#' \itemize{
#'  \item You can enter your details using the client_id and api_key parameters directly.
#'  \item You can execute the function without any inputs. The function then first looks in your
#'  options for the option variables digocean_client_id and digocean_api_key. If they are not found
#'  the function asks you to enter them. You can set force=TRUE to force the function to ask
#'  you for new id and key.
#'  \item Set your options using the function \code{options}. See examples.
#'  \item Set your options in your .Rprofile file with entries
#'  \code{options(digocean_client_id = '<clientid>')} and
#'  \code{options(digocean_api_key = '<apikey>')}. Remember to restart your R session after you
#'  do this so that R knows about them. If you do this option, you don't have to use this auth
#'  function at all - the various functions in the package will read your client id and api key
#'  from your .Rprofile file.
#' }
#'
#' @examples \dontrun{
#' # If you do
#' do_auth()
#' }

do_auth <- function(client_id=NULL, api_key=NULL, force = FALSE) {
  id <- getOption('digocean_client_id', default = "")
  if (identical(id, "") || force){
    if (!interactive()) {
      stop("Please set option variable digocean_client_id to your Digital Ocean Client Id (CI)",
           call. = FALSE)
    }
    message("Couldn't find option var digocean_client_id. See ?do_auth for more details.")
    message("Please enter your Digital Ocean client ID and press enter:")
    clientid <- readline(": ")
    if (identical(clientid, "")) {
      stop("Digital Ocean client id entry failed", call. = FALSE)
    }
    message("Updating digocean_client_id option var\n")
    options(digocean_client_id = clientid)
  } else { clientid <- id }

  key <- getOption('digocean_api_key', default = "")
  if (identical(key, "") || force){
    if (!interactive()) {
      stop("Please set option var digocean_api_key to your Digital Ocean API key",
           call. = FALSE)
    }
    message("Couldn't find option var digocean_api_key See ?do_auth for more details.")
    message("Please enter your Digital Ocean API key and press enter:")
    apikey <- readline(": ")
    if (identical(apikey, "")) {
      stop("Digital Ocean API key entry failed", call. = FALSE)
    }
    message("Updating digocean_api_key option var")
    options(digocean_api_key = apikey)
  } else { apikey <- key }

  res <- list(client_id = clientid, api_key = apikey)
  class(res) <- 'doauth'
  res
}
#   if (!identical(env2, "") && !force) return(env2)

#' Print method for doauth object
#' @export
#' @param x Object of class doauth
#' @param ... Further args, ignored
#' @rdname do_auth
print.doauth <- function(x, ...){
  cat("Client ID: ", x$client_id, "\n")
  cat("API key:   ", x$api_key, "\n")
}

#' Get auth details and handle errors
#'
#' @export
do_get_auth <- function(){
  id <- getOption("digocean_client_id")
  key <- getOption("digocean_api_key")

  if(is.null(id) | is.null(key)) do_auth()

  id <- getOption("digocean_client_id")
  key <- getOption("digocean_api_key")

  list(id=id, key=key)
}
