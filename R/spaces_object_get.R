#' Retrieve an Object from a space
#'
#' @param object (character) The Object to get
#' @param space The Space \code{object} is in. A Space, or the name of the Space as a string.
#' @template spaces_args
#' @param ... Additional argument passed to \code{\link[aws.s3]{get_object}}
#'
#' @return The raw response body of the request
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/
#' spaces/#get-object}
#'
#' @examples
#' \dontrun{
#' # First, create a Space and then upload a file to it
#' space_create("my-space")
#' spaces_object_put("some-file.txt", "my-object", "my-space")
#'
#' # You can get back the Object as text
#' rawToChar(spaces_object_get("my-object", "my-space"))
#'
#' # Or you can get back the raw response
#' spaces_object_get("my-object", "my-space")
#' }
spaces_object_get <- function(object,
                              space,
                              spaces_region = NULL,
                              spaces_key = NULL,
                              spaces_secret = NULL,
                              ...) {
  space <- as.character(space)

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::get_object(object,
                     space,
                     check_region = FALSE,
                     key = spaces_key,
                     region = spaces_region,
                     secret = spaces_secret,
                     base_url = spaces_base,
                     ...)
}
