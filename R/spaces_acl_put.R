#' Set an Object's Access Control List (ACL)
#'
#' @param object (character) The Object to set the ACL on
#' @param space (character) The Space the Object is found in
#' @param body (character) The XML-formatted ACL. Can optionally be an
#' \code{xml_document} if the \code{xml2} package is installed.
#' @template spaces_args
#' @param ... Additional argument passed to \code{\link[aws.s3]{put_acl}}
#'
#' @return \code{TRUE} or \code{FALSE} depending on whether the ACL was successfully set
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/
#' spaces/#acls}
#' @references \url{https://developers.digitalocean.com/documentation/
#' spaces/#set-object-acls}
#'
#' @examples
#' \dontrun{
#' # First, create a Space and upload an Object to it
#' space_create("my-space")
#' spaces_object_put("some-file.txt", space = "my-space")
#'
#' # You can get a copy of the ACL
#' acl <- spaces_acl_get("some-file.txt", "my-space")
#'
#' # Then, after you've modified it, you can update the ACL
#' spaces_acl_put("some-file.txt", "my-space", acl)
#'
#' # If you have the xml2 package, install you can modify it entirely in R and
#' # send the \code{xml_document} directly instead of a character string
#' # (as above)
#' if (requireNamespace("xml2")) {
#'   acl <- xml2::read_xml(acl)
#'   # Do your modifications here
#'   spaces_acl_put("some-file.txt", "my-space", acl)
#' }
#' }
spaces_acl_put <- function(object,
                           space,
                           body,
                           spaces_key = NULL,
                           spaces_secret = NULL,
                           ...) {
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  # If the 'body' arg is an 'xml_document', convert it to character before
  # sending the request
  if (inherits(body, "xml_document")) {
    if (!requireNamespace("xml2")) {
      stop("Couldn't convert 'body' to a character vector because the 'xml2' ",
           "package is not installed. Install it and try again.", call. = FALSE)
    }

    body <- as.character(body)
  }

  aws.s3::put_acl(object,
                  space,
                  body = body,
                  check_region = FALSE,
                  key = spaces_key,
                  secret = spaces_secret,
                  base_url = spaces_base,
                  ...)
}
