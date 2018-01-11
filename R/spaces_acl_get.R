#' Retrieve an Object's Access Control List (ACL)
#'
#' @param object (character) The Object to get the ACL on
#' @param space (character) The Space the Object is found in
#' @param spaces_key (character) String containing a spaces access key. If
#'   missing, defaults to value stored in an environment variable
#'   \code{DO_SPACES_ACCESS_KEY}.
#' @param spaces_secret (character) String containing the secret associated
#'   with the spaces key. If missing, defaults to value stored in an environment
#'   variable \code{DO_SPACES_SECRET_KEY}.
#' @param ... Additional argument passed to \code{\link[aws.s3]{get_acl}}
#'
#' @return The Object's ACL (as an XML string)
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/
#' spaces/#acls}
#' @references \url{https://developers.digitalocean.com/documentation/
#' spaces/#get-object-acls}
#'
#' @examples
#' \dontrun{
#' # First, create a Space and upload an Object to it
#' space_create("my-space")
#' spaces_object_put("some-file.txt", space = "my-space")
#'
#' # You can get an ACL for your Object
#' acl <- spaces_acl_get("some-file.txt", "my-space")
#' acl
#' }
spaces_acl_get <- function(object,
                           space,
                           spaces_key = NULL,
                           spaces_secret = NULL,
                           ...) {
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::get_acl(object,
                  space,
                  check_region = FALSE,
                  key = spaces_key,
                  secret = spaces_secret,
                  base_url = spaces_base,
                  ...)

}
