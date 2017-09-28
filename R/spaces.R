spaces_base <- "nyc3.digitaloceanspaces.com"

check_space_access <- function(spaces_key) {
  tmp <- if (is.null(spaces_key)) Sys.getenv("DO_SPACES_ACCESS_KEY") else spaces_key
  if (tmp == "") stop("Need a digital ocean spaces access key defined in your session") else tmp
}

check_space_secret <- function(spaces_secret) {
  tmp <- if (is.null(spaces_secret)) Sys.getenv("DO_SPACES_SECRET_KEY") else spaces_secret
  if (tmp == "") stop("Need a digital ocean spaces access key defined in your session") else tmp
}

#' Spaces storage operations
#'
#' \describe{
#'  \item{space}{List space contents}
#'  \item{spaces}{List spaces in your digital ocean account}
#'  \item{space_create}{Create a new space}
#' }
#'
#' @param name (character) Name of the new space. Required.
#' @param object (character) Name of the object you want to either save
#'   to a space or load from a space.
#' @param envir R environment to either save objects from or load objects
#'   into.  Default is \code{parent.frame()} from which the function is called.
#' @param spaces_key (character) String containing a spaces access key. If
#'   missing, defaults to value stored in an environment variable \dQuote{DO_SPACES_ACCESS_KEY}.
#' @param spaces_secret (character) String containing the secret associated
#'   with the spaces key. If missing, defaults to value stored in an environment
#'   variable \dQuote{DO_SPACES_SECRET_KEY}.
#' @param acl Access level to set for the space.  Choices are \dQuote{private}, meaning
#'   only you will be able to list files in the space, or \dQuote{public}, meaning
#'   anyone can list the files in your space.  Default is \dQuote{private}.
#' @param ... Additional arguments passed down to \code{aws.s3} functions.

#' List all spaces in your digital ocean account
#' @importFrom aws.s3 bucketlist
#' @export
spaces <- function(spaces_key = NULL, spaces_secret = NULL, ...) {
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  bucketlist(region = NULL,
             key = spaces_key,
             secret = spaces_secret,
             base_url = spaces_base)
}

#' List the contents of a space
#' @importFrom aws.s3 get_bucket
#' @export
space <- function(name, spaces_key = NULL, spaces_secret = NULL, ...) {
  if (is.null(name)) stop("Please specify the space name")
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  get_bucket(name,
             region = NULL,
             check_region = FALSE,
             key = spaces_key,
             secret = spaces_secret,
             base_url = spaces_base)
}

#' Create a new space
#' @importFrom aws.s3 put_bucket
#' @export
space_create <- function(name, acl = "private", spaces_key = NULL, spaces_secret = NULL, ...) {
  if (is.null(name)) stop("Please specify the space name")
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  put_bucket(name,
             region = NULL,
             acl = acl,
             key = spaces_key,
             secret = spaces_secret,
             base_url = spaces_base)
}
