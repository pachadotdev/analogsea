#' Get information about an Object
#'
#' @param object (character) The Object to get information about
#' @param space The Space of \code{object}. A Space, or the name of the Space as a string.
#' @param ... Additional argument passed to \code{\link[aws.s3]{head_object}}
#'
#' @return A list of headers associated with the Object
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/
#' spaces/#get-object-info}
#'
#' @examples
#' \dontrun{
#' # First, create a Space and then upload a file to it
#' space_create("my-space")
#' spaces_object_put("some-file.txt", "my-object", "my-space")
#'
#' # You can get information about an Object
#' spaces_object_head("my-object", "my-space")
#' }
spaces_object_head <- function(object,
                               space,
                               spaces_region = NULL,
                               spaces_key = NULL,
                               spaces_secret = NULL,
                               ...) {
  space <- as.character(space)

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  response <- aws.s3::head_object(object,
                                  space,
                                  check_region = FALSE,
                                  region = spaces_region,
                                  key = spaces_key,
                                  secret = spaces_secret,
                                  base_url = spaces_base,
                                  ...)

  attributes(response)
}
