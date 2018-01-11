#' Upload an Object to a Space
#'
#' @param file (character) The path to the file to upload.
#' @param object (character) The key for the new Object. Defaults to the basename of the \code{path} returned by \code{\link{basename}}.
#' @param space (character) The Space to upload the Object to
#' @param spaces_key (character) String containing a spaces access key. If
#'   missing, defaults to value stored in an environment variable
#'   \code{DO_SPACES_ACCESS_KEY}.
#' @param spaces_secret (character) String containing the secret associated
#'   with the spaces key. If missing, defaults to value stored in an environment
#'   variable \code{DO_SPACES_SECRET_KEY}.
#' @param ... Additional argument passed to \code{\link[aws.s3]{put_object}}
#'
#' @return TRUE of FALSE dependong on whether the Object was uploaded
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/spaces/#object}
#'
#' @examples
#' \dontrun{
#' spaces_object_put("./some-file.txt", "my-object", "my-space")
#'
#' # Let the function choose an Object key automatically based on the file's
#' # basename
#' spaces_object_put("./some-file.txt", space = "my-space")
#' }
spaces_object_put <- function(file, object = basename(file), space, spaces_key = NULL, spaces_secret = NULL, ...) {
  if (!file.exists(file)) {
    stop("No file exists at the path \"", file, "\".", call. = FALSE)
  }

  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::put_object(file,
                     object,
                     space,
                     check_region = FALSE,
                     key = spaces_key,
                     secret = spaces_secret,
                     base_url = spaces_base,
                     ...)

}
