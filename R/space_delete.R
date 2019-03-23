#' Delete a Space
#'
#' @export
#' @param space A Space, or something that can be coerced to a Space by
#'   \code{\link{as.space}}.
#' @template spaces_args
#' @param ... Additional arguments to \code{\link[aws.s3]{put_bucket}}
#' @return (character) The name of the created Space.
#' @references \url{https://developers.digitalocean.com/documentation/spaces/
#' #delete-a-buckets}
#' @examples
#' \dontrun{
#' # First, create a Space
#' space_create("new_space_name")
#'
#' # The we can delete it
#' space_delete("new_space_name")
#' }
space_delete <- function(space,
                         spaces_region = NULL,
                         spaces_key = NULL,
                         spaces_secret = NULL,
                         ...) {
  space <- as.space(space)

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  res <- aws.s3::delete_bucket(name,
                               region = spaces_region,
                               key = spaces_key,
                               secret = spaces_secret,
                               base_url = spaces_base,
                               ...)

}
