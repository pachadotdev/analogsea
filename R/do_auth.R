#' Set up authentication details for the Digital Ocean API
#'
#' This function sets options in your current R session, and passes on to each function call.
#'
#' @export
#' @keywords internal
#' @param token (character) Your Digital Ocean OAuth token. Default NULL
#' @param force (logical) Force update
#'
#' @return A simple S3 class ("doauth") as a list that has a print method to nicely print out your
#' auth details.
#' @details  There are three ways you can use this function.
#'
#' \itemize{
#'  \item You can enter your details using the token parameter directly.
#'  \item You can execute the function without any inputs. The function then first looks in your
#'  options for the option variable digocean_oauth_token . If they are not found
#'  the function asks you to enter it. You can set force=TRUE to force the function to ask
#'  you for new token.
#'  \item Set your options using the function \code{options}. See examples.
#'  \item Set your options in your .Rprofile file with the entry  
#'  \code{options(digocean_oauth_token = '<oauth token>')}. Remember to restart your R session 
#'  after you do this so that R knows about them. If you do this option, you don't have to use 
#'  this auth function at all - the various functions in the package will read your client id and 
#'  api key from your .Rprofile file.
#' }
#'
#' @examples \dontrun{
#' # If you do
#' do_auth()
#' }

do_auth <- function(token=NULL, force = FALSE) {
  token <- getOption('digocean_oauth_token', default = "")
  if (identical(token, "") || force){
    if (!interactive()) {
      stop("Please set option variable digocean_oauth_token to your Digital Ocean OAuth token",
           call. = FALSE)
    }
    message("Couldn't find option var digocean_oauth_token. See ?do_auth for more details.")
    message("Please enter your Digital Ocean OAuth token and press enter:")
    oauthtoken <- readline(": ")
    if (identical(oauthtoken, "")) {
      stop("Digital Ocean token entry failed", call. = FALSE)
    }
    message("Updating digocean_oauth_token option var\n")
    options(digocean_oauth_token = oauthtoken)
  } else { oauthtoken <- token }
  
  res <- list(oauthtoken = oauthtoken)
  class(res) <- 'doauth'
  res
}

#' Print method for doauth object
#' @export
#' @param x Object of class doauth
#' @param ... Further args, ignored
#' @rdname do_auth
print.doauth <- function(x, ...){
  cat("OAuth token:\n", x$oauthtoken, "\n")
}

#' Get auth details and handle errors
#'
#' @export
#' @keywords internal
do_get_auth <- function(){
  token <- getOption("digocean_oauth_token")
  if(is.null(token)) do_auth()
  token <- getOption("digocean_oauth_token")
  list(token=token)
}
