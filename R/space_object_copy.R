#' Copy an object from one Space to another
#'
#' @param from_object (character) The Object to copy
#' @param to_object (character) The key for the copied Object. Defaults to the same key as the Object being copied.
#' @param from_space The Space the object being copied is found in. A space, or the name of the Space as a string.
#' @param to_space The Space to copy the object to. A space, or the name of the Space as a string.
#' @template spaces_args
#' @param ... Additional argument passed to \code{\link[aws.s3]{copy_object}}
#'
#' @return If successful, information about the copied Object
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/
#' spaces/#copy-object}
#'
#' @examples
#' \dontrun{
#' # First, create two spaces and an Object in the first space
#' space_create("primary-space")
#' space_create("secondary-space")
#' spaces_object_put("some-file.txt", space = "primary-space")
#'
#' # You can then copy the object from one Space to another
#' spaces_object_copy("my-object", "copied-object", "primary_space", "secondary-space")
#'
#' # And you can also copy over the Object with the same key
#' spaces_object_copy("my-object",
#'                    from_space = "primary-space",
#'                    to_space = "secondary-space")
#' }
space_object_copy <- function(from_object,
                               to_object = from_object,
                               from_space,
                               to_space,
                               spaces_region = NULL,
                               spaces_key = NULL,
                               spaces_secret = NULL,
                               ...) {
  from_space <- as.character(from_space)
  to_space <- as.character(to_space)

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::copy_object(from_object,
                      to_object,
                      from_bucket = from_space,
                      to_bucket = to_space,
                      region = spaces_region,
                      key = spaces_key,
                      secret = spaces_secret,
                      base_url = spaces_base,
                      ...)
}
