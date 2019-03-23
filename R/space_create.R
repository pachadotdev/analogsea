#' Create a new Space
#'
#' @export
#' @param name (character) The name of the new Space
#' @template spaces_args
#' @param ... Additional arguments to \code{\link[aws.s3]{put_bucket}}
#' @return (character) The name of the created Space.
#' @references \url{https://developers.digitalocean.com/documentation/spaces/
#' #create-a-bucket}
#' @examples
#' \dontrun{
#' # Create a new Space
#' # (Names must be unique within region)
#' space_create("new_space_name")
#' }
space_create <- function(name,
                         spaces_region = NULL,
                         spaces_key = NULL,
                         spaces_secret = NULL,
                         ...) {
  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  res <- aws.s3::put_bucket(name,
                            region = spaces_region,
                            key = spaces_key,
                            secret = spaces_secret,
                            base_url = spaces_base,
                            location_constraint = NULL,
                            ...)

  if (res) message(sprintf("New Space %s created successfully.", name))

  invisible(name)
}
