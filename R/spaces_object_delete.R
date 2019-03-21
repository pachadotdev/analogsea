#' Delete an Object from a Space
#'
#' This function is not implemented yet. A working implementation is planned in
#' future releases of this package.
#'
#' @export
#' @param object (character) The Object to delete
#' @param space (character) The Space to delete the Object from
#' @template spaces_args
#' @param ... Additional argument passed to \code{\link[aws.s3]{delete_object}}
#'
#' @return \code{TRUE} if successful, otherwise an object of class aws_error
#' details if not.
#'
#' @references \url{https://developers.digitalocean.com/documentation/
#' spaces/#delete-object}
#'
#' @examples
#' \dontrun{
#' # First, create a Space and upload an Object to it
#' space_create("my-space")
#' spaces_object_put("some-file.txt", "my-object", "my-space")
#'
#' # You can delete an Object by key
#' spaces_object_delete("my-object", "my-space")
#' }
spaces_object_delete <- function(object,
                                 space,
                                 spaces_region = NULL,
                                 spaces_key = NULL,
                                 spaces_secret = NULL,
                                 ...) {
  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::delete_object(object,
                        space,
                        check_region = FALSE,
                        key = spaces_key,
                        region = spaces_region,
                        secret = spaces_secret,
                        base_url = spaces_base,
                        ...)
}
