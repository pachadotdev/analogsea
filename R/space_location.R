#' Get the region of a Space
#'
#' @param space A Space, or something that can be coerced to a Space by
#'   \code{\link{as.space}}.
#' @param ... Additional arguments passed to \code{\link[aws.s3]{s3HTTP}}
#' @template spaces_args
#'
#' @return (character) The region the Space is in
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/spaces/
#' #get-bucket-location}
#' @examples
#' \dontrun{
#' # Create a Space and get its location
#' sp <- create_space("my-space")
#' space_location(sp)
#' }
space_location <- function(space,
                           spaces_region = NULL,
                           spaces_key = NULL,
                           spaces_secret = NULL,
                           ...) {
  name <- as.character(space)

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  r <- aws.s3::s3HTTP("GET",
                      name,
                      query = list(location = ""),
                      region = spaces_region,
                      key = spaces_key,
                      secret = spaces_secret,
                      base_url = spaces_base,
                      ...)

  # Stop now with an error if things don't look righta
  if (!is.list(r) && length(r) >= 1 && !is.character(r[[1]])) {
    stop(paste0("Something went wrong with the request to get the region for ",
                "the Space '",
                name,
                "'."))
  }

  r[[1]]
}
