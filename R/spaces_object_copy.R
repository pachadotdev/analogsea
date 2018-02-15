#' Copy an Object from one Space to another
#'
#' @param from_object (character) The Object to copy
#' @param to_object (character) The key for the copied Object. Defaults to the same key as the Object being copied.
#' @param from_space (character) The Space the Object being copied is found in
#' @param to_space (character) The Space to copy the Object to
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
#' # First, create two Spaces and an Object in the first space
#' space_create("primary-space")
#' space_create("secondary-space")
#' spaces_object_put("some-file.txt", space = "primary-space")
#'
#' # You can then copy the object from one space to another
#' spaces_object_copy("my-object", "copied-object", "primary_space", "secondary-space")
#'
#' # And you can also copy over the Object with the same key
#' spaces_object_copy("my-object",
#'                    from_space = "primary-space",
#'                    to_space = "secondary-space")
#' }
spaces_object_copy <- function(from_object,
                               to_object = from_object,
                               from_space,
                               to_space,
                               spaces_key = NULL,
                               spaces_secret = NULL,
                               ...) {
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::copy_object(from_object,
                      to_object,
                      from_space,
                      to_space,
                      check_region = FALSE,
                      key = spaces_key,
                      secret = spaces_secret,
                      base_url = spaces_base,
                      ...)

}
