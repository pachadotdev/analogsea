#' Authorize with Digital Ocean.
#'
#' @import assertthat
#' @export
#'
#' @param appname Your Digital Ocean registered application name
#' @param client_id Your Digital Ocean registered application client id
#' @param client_secret Your Digital Ocean registered application name
#' @param scope A character vector of scopes to request. One of 'read', 'write', or both.
#' Default: \code{c('read','write')}.
#' @param reauth (logical) Whether to force re-authorization. Auth details are cached locally
#' on your machine in a secrure hidden file, so you don't have to re-authorize very often. 
#' When your auth details are expired you will be forced to re-authorize anyway.
#'
#' @details
#' After you first authorize via this function, this function will be called within other
#' functions to check if you're already authorized, and if not do the authorization.
#'
#' Instructions for use:
#' \enumerate{
#'  \item Login to your Digital Ocean account. Go to "Apps & API" page.
#'  \item In the "Developer Applications" part of the page, press button for
#' "Register new application".
#'  \item Enter app details:
#'  \itemize{
#'   \item Application name: anything is fine
#'   \item Application homepage: anything is fine, this more used for web oauth flows.
#'   \item Application description: give a note to yourself what this app is.
#'   \item Application callback URL: http://localhost:1410
#'  }
#'  \item Once the app is registered, you can enter your appname, client id, and
#' client secret as parameters to this function, or store them in your .Rprofile
#' file as \code{do_appname}, \code{do_client_id}, and \code{do_client_secret},
#' respectively.
#' }
#'
#' If function runs succesfully, your token object is returned and cached, which will be
#' called in other functions in this package.
#'
#' @examples \dontrun{
#' # If passing in auth details in the function call
#' do_oauth(appname="<app name>", client_id="<client id>", client_secret="<client secret>")
#'
#' # If details stored in your .Rprofile file
#' do_oauth()
#'
#' # Pass in options, e.g. scope here set to read only
#' do_oauth(scope='read')
#' }

do_oauth <- function(appname = 'rdigocean', 
  client_id = "9039627f86f984a13f4736b94458154bdeba668537d50c6394172f6185b14063",
  client_secret = "ffaa1c6775656d3e2aee0d079768bc4b444832164c8953ec1129cf8b41007928", 
  scope=c('read','write'), reauth=FALSE) {

  pat <- Sys.getenv("DO_PAT", "")
  if (!identical(pat, "")) {
    httr::add_headers(Authorization = paste0("Bearer ", pat))
  } else {
    # Fall back to OAuth
    
    assert_that(!is.null(appname), !is.null(client_id), !is.null(client_secret))
    endpt <- httr::oauth_endpoint(NULL, "authorize", "token",
      base_url = "https://cloud.digitalocean.com/v1/oauth")
    myapp <- httr::oauth_app(appname, client_id, client_secret)
    token <- httr::oauth2.0_token(endpt, myapp, scope = scope, cache = !reauth)
    
    httr::config(token = token)
  }
}
