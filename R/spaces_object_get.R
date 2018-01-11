#' Retrieve an Object from a Space
#'
#' @param object (character) The Object to get
#' @param space (character) The Space the Object is found in
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
#' # First, create a space and then upload a file to it
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
                              spaces_key = NULL,
                              spaces_secret = NULL,
                              ...) {
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::get_object(object,
                     space,
                     check_region = FALSE,
                     key = spaces_key,
                     secret = spaces_secret,
                     base_url = spaces_base,
                     ...)
}
