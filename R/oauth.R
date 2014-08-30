#' Authorize with Digital Ocean.
#' 
#' @param appname Your Digital Ocean registered application name
#' @param client_id Your Digital Ocean registered application client id
#' @param client_secret Your Digital Ocean registered application name
#' 
#' @details Instructions for use:
#' 
#' 1. Login to your Digital Ocean account. Go to "Apps & API" page.
#' 2. In the "Developer Applications" part of the page, press button for 
#' "Register new application". 
#' 3. Enter app details: 
#' * Application name: anything is fine
#' * Application homepage: anything is fine, this more used for web oauth flows. 
#' * Application description: give a note to yourself what this app is.
#' * Application callback URL: http://localhost:1410
#' 4. Once the app is registered, you can enter your appname, client id, and 
#' client secret as parameters to this function, or store them in your .Rprofile
#' file as \code{do_appname}, \code{do_client_id}, and \code{do_client_secret}, 
#' respectively.
#' 
#' If function runs succesfully, your token object is returned and saved as an 
#' option named "do_token", which will be called in other functions in this package.
#' 
#' @examples \dontrun{
#' do_oauth()
#' }

do_oauth <- function(appname = getOption("do_appname"), 
                     client_id = getOption("do_client_id"), 
                     client_secret = getOption("do_client_secret")) 
{
  assert_that(!is.null(appname), !is.null(client_id), !is.null(client_secret))
  endpt <- oauth_endpoint(NULL, "authorize", "token", 
                          base_url = "https://cloud.digitalocean.com/v1/oauth")
  myapp <- oauth_app(appname, client_id, client_secret)
  token <- oauth2.0_token(endpt, myapp)
  options(do_token = token)
  return(token)
}
