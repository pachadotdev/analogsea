#' Authorize with Digital Ocean.
#'
#' This function is run automatically to allow analogsea to access your
#' digital ocean account.
#'
#' There are two ways to authorise analogsea to work with your digital ocean
#' account:
#' \itemize{
#' \item Generate a personal access token at
#'   https://cloud.digitalocean.com/settings/tokens/new and
#'   record in the \code{DO_PAT} envar.
#'
#' \item Interatively login into your DO account and authorise with
#'   OAuth.
#' }
#'
#' Using \code{DO_PAT} is recommended.
#'
#' @param app An \code{\link[httr]{oauth_app}} for DO. The default uses the
#'   standard ROpenSci application.
#' @param reauth (logical) Force re-authorization?
#' @export
do_oauth <- function(app = do_app, reauth = FALSE) {

  if (exists("auth_config", envir = cache) && !reauth) {
    return(cache$auth_config)
  }

  pat <- Sys.getenv("DO_PAT", "")
  if (!identical(pat, "")) {
    auth_config <- httr::add_headers(Authorization = paste0("Bearer ", pat))
  } else if (!interactive()) {
    stop("In non-interactive environments, please set DO_PAT env to a DO",
      " access token (https://cloud.digitalocean.com/settings/tokens/new)",
      call. = FALSE)
  } else  {
    endpt <- httr::oauth_endpoint(NULL, "authorize", "token",
      base_url = "https://cloud.digitalocean.com/v1/oauth")
    token <- httr::oauth2.0_token(endpt, app, scope = c("read", "write"), cache = !reauth)

    auth_config <- httr::config(token = token)
  }

  cache$auth_config <- auth_config
  auth_config
}

cache <- new.env(parent = emptyenv())

do_app <- httr::oauth_app(
  "rdigocean",
  "9039627f86f984a13f4736b94458154bdeba668537d50c6394172f6185b14063",
  "ffaa1c6775656d3e2aee0d079768bc4b444832164c8953ec1129cf8b41007928"
)
