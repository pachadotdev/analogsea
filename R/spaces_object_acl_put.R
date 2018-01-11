#' Set an Object's Access Control List (ACL)
#'
#' @param object (character) The Object to set the ACL on
#' @param space (character) The Space the Object is found in
#' @param body (character) The XML-formatted ACL
#' @param spaces_key (character) String containing a spaces access key. If
#'   missing, defaults to value stored in an environment variable
#'   \code{DO_SPACES_ACCESS_KEY}.
#' @param spaces_secret (character) String containing the secret associated
#'   with the spaces key. If missing, defaults to value stored in an environment
#'   variable \code{DO_SPACES_SECRET_KEY}.
#' @param ... Additional argument passed to \code{\link[aws.s3]{put_acl}}
#'
#' @return TRUE or FALSE depending on whether the ACL was successfully set
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/spaces/#set-object-acls}
#'
#' @examples
#' \dontrun{
#' # Get an ACL for an Object
#' acl <- spaces_object_acl_get("my-object", "my-space")
#' # Modify ACL and then run:
#' spaces_object_acl_put("my-object", "my-space", acl)
#' }
spaces_object_acl_put <- function(object, space, body, spaces_key = NULL, spaces_secret = NULL, ...) {
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::put_acl(object,
                  space,
                  body = body,
                  check_region = FALSE,
                  key = spaces_key,
                  secret = spaces_secret,
                  base_url = spaces_base,
                  ...)
}
