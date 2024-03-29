#' Authorize with Digital Ocean.
#'
#' This function is run automatically to allow analogsea to access your
#' digital ocean account.
#'
#' There are two ways to authorise analogsea to work with your digital ocean
#' account:
#' \itemize{
#' \item Generate a personal access token at
#'   https://cloud.digitalocean.com/settings/api/tokens and
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
      " access token (https://cloud.digitalocean.com/settings/api/tokens)",
      call. = FALSE)
  } else  {
    endpt <- httr::oauth_endpoint(
      NULL, "authorize", "token",
      base_url = "https://cloud.digitalocean.com/v1/oauth")
    token <- httr::oauth2.0_token(endpt, app, scope = c("read", "write"),
                                  cache = !reauth)

    auth_config <- httr::config(token = token)
  }

  cache$auth_config <- auth_config
  auth_config
}

cache <- new.env(parent = emptyenv())

do_app <- httr::oauth_app(
  "analogsea",
  "831a4f9874ff5ee0ec9b597c9204e5dfc4117b3a4517f5f51dc4efcc28d525fb",
  "65663547536bf76ced52ccf4949493c63833c93807bd960d86908d4175afee97"
)
