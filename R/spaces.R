spaces_base <- "nyc3.digitaloceanspaces.com"

check_space_access <- function(spaces_key) {
  tmp <- ifelse(is.null(spaces_key),
                Sys.getenv("DO_SPACES_ACCESS_KEY"),
                spaces_key)
  if (tmp == "") {
    stop("Need a digital ocean spaces access key defined in your session",
         call. = FALSE)
  } else {
    tmp
  }
}

check_space_secret <- function(spaces_secret) {
  tmp <- ifelse(is.null(spaces_secret),
                Sys.getenv("DO_SPACES_SECRET_KEY"),
                spaces_secret)
  if (tmp == "") {
    stop("Need a digital ocean spaces secret key defined in your session",
         call. = FALSE)
  } else {
    tmp
  }
}

#' @param x Object to coerce to a space
#' @export
#' @rdname spaces
as.space <- function(x) UseMethod("as.space")
#' @export
as.space.space <- function(x) x
#' @export
as.space.character <- function(x) spaces()[[x]]

#' @export
print.space <- function(x, ...) {
  cat("<space>", x$Name, "\n", sep = "")
  cat("  Created at: ", x$CreationDate, "\n")
}

#' @export
summary.space <- function(object, ...) {
  space_info <- space_info(name = object$Name, ...)

  # obtain total size used by space
  size <- space_size(space_info)

  # obtain number of files in space
  n_files <- space_files(space_info)

  cat("<space_detail>", object$Name, "\n", sep = "")
  cat("  Size (GB):    ", size, "\n", sep = "")
  cat("  Files:        ", n_files, "\n", sep = "")
  cat("  Created at:   ", object$CreationDate, "\n", sep = "")
}

#' Spaces storage operations
#'
#' \describe{
#'  \item{spaces}{Retrieve all spaces in your digital ocean account}
#'  \item{space_create}{Create a new space}
#' }
#' @name spaces
#' @param name (character) Space name.
#' @param spaces_key (character) String containing a spaces access key. If
#'   missing, defaults to value stored in an environment variable
#'   \code{DO_SPACES_ACCESS_KEY}.
#' @param spaces_secret (character) String containing the secret associated
#'   with the spaces key. If missing, defaults to value stored in an environment
#'   variable \code{DO_SPACES_SECRET_KEY}.
#' @param ... Additional arguments passed down to \code{\link[aws.s3]{bucketlist}},
#'   \code{\link[aws.s3]{get_bucket}}, \code{\link[aws.s3]{put_bucket}} functions
#'   from the \code{aws.s3} package.
#' @examples \dontrun{
#' # list spaces
#' spaces()
#'
#' # obtain spaces as a list of space objects
#' res <- spaces()
#'
#' # print space summary using a space object
#' summary(res[['my_space_name']])
#'
#' # create a new space
#' space_create('new_space_name')
#' }

#' @importFrom aws.s3 bucketlist
#' @keywords internal
spaces_GET <- function(spaces_key = NULL, spaces_secret = NULL, ...) {

  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  res <- aws.s3::s3HTTP(verb = "GET",
                        region = NULL,
                        key = spaces_key,
                        secret = spaces_secret,
                        base_url = spaces_base,
                        ...)

  return(res)
}

#' @export
#' @rdname spaces
spaces <- function(spaces_key = NULL, spaces_secret = NULL, ...) {
  res <- spaces_GET(spaces_key = spaces_key, spaces_secret = spaces_secret, ...)

  # when only one space is present, res$Buckets only contains the Name and
  # CreationDate.  If more than one space is present, then each space will
  # have a Bucket list object with the Name and CreationDate
  if (identical(names(res$Buckets), c("Name", "CreationDate"))) {
    res$Buckets <- list(
      Bucket = list(
        Name = res$Buckets$Name,
        CreationDate = res$Buckets$CreationDate
      )
    )
  }
  sp <- lapply(res$Buckets, structure, class = "space")
  setNames(sp, vapply(res$Buckets, function(x) x$Name, character(1)))
}

#' @importFrom aws.s3 get_bucket
#' @keywords internal
space_info <- function(name, spaces_key = NULL, spaces_secret = NULL, ...) {
  if (is.null(name)) stop("Please specify the space name")
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  space_info <- get_bucket(name,
                           region = NULL,
                           check_region = FALSE,
                           key = spaces_key,
                           secret = spaces_secret,
                           base_url = spaces_base,
                           max = Inf,
                           ...)

  return(space_info)
}

space_size <- function(space_info) {
  # grab the sizes from each file (unit is bytes)
  sizes <- vapply(space_info, function(x) x$Size, numeric(1))

  # compute total size (convert to gb)
  sum(sizes) * 1e-09
}

space_files <- function(space_info) {
  # remove entries with size 0 (those are nested directories)
  length(lapply(space_info, function(x) x[x$Size > 0]))
}

#' Create a new space
#' @importFrom aws.s3 put_bucket
#' @export
#' @rdname spaces
space_create <- function(name, spaces_key = NULL, spaces_secret = NULL, ...) {
  if (is.null(name)) stop("Please specify the space name")
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  res <- put_bucket(name,
                    region = NULL,
                    key = spaces_key,
                    secret = spaces_secret,
                    base_url = spaces_base,
                    ...)

  if (res) message(sprintf("New space %s created successfully", name))
}



#' Retrieve an Object from a Space
#'
#' @param object (character) The Object to get
#' @param space (character) The Space the Object is found in
#' @param spaces_key (character) String containing a spaces access key. If
#'   missing, defaults to value stored in an environment variable
#'   \code{DO_SPACES_ACCESS_KEY}.
#' @param spaces_secret (character) String containing the secret associated
#'   with the spaces key. If missing, defaults to value stored in an environment
#'   variable \code{DO_SPACES_SECRET_KEY}.
#' @param ... Additional argument passed to \code{\link[aws.s3]{get_object}}
#'
#' @return The raw response body of the request
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/spaces/#get-object}
#'
#' @examples
#' \dontrun{
#' spaces_put_object("./some-file.txt", "my-object", "my-space")
#' spaces_get_object("my-object", "my-space")
#' }
spaces_get_object <- function(object, space, spaces_key = NULL, spaces_secret = NULL, ...) {
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

#' Get information about an Object
#' @param object (character) The Object to get information about
#' @param space (character) The Space the Object is found in
#' @param spaces_key (character) String containing a spaces access key. If
#'   missing, defaults to value stored in an environment variable
#'   \code{DO_SPACES_ACCESS_KEY}.
#' @param spaces_secret (character) String containing the secret associated
#'   with the spaces key. If missing, defaults to value stored in an environment
#'   variable \code{DO_SPACES_SECRET_KEY}.
#' @param ... Additional argument passed to \code{\link[aws.s3]{head_object}}
#'
#' @return A list of headers associated with the Object
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/spaces/#get-object-info}
#'
#' @examples
#' \dontrun{
#' spaces_put_object("./some-file.txt", "my-object", "my-space")
#' spaces_head_object("my-object", "my-space")
#' }
spaces_head_object <- function(object, space, spaces_key = NULL, spaces_secret = NULL, ...) {
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::head_object(object,
                      space,
                      check_region = FALSE,
                      key = spaces_key,
                      secret = spaces_secret,
                      base_url = spaces_base,
                      ...)

}

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
#' spaces_put_object("./some-file.txt", "my-object", "my-space")
#'
#' # Let the function choose an Object key automatically based on the file's
#' # basename
#' spaces_put_object("./some-file.txt", space = "my-space")
#' }
spaces_put_object <- function(file, object = basename(file), space, spaces_key = NULL, spaces_secret = NULL, ...) {
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

#' Copy an Object from one Space to another
#'
#' @param from_object (character) The Object to copy
#' @param to_object (character) The key for the copied Object. Defaults to the same key as the Object being copied.
#' @param from_space (character) The Space the Object being copied is found in
#' @param to_space (character) The Space to copy the Object to
#' @param spaces_key (character) String containing a spaces access key. If
#'   missing, defaults to value stored in an environment variable
#'   \code{DO_SPACES_ACCESS_KEY}.
#' @param spaces_secret (character) String containing the secret associated
#'   with the spaces key. If missing, defaults to value stored in an environment
#'   variable \code{DO_SPACES_SECRET_KEY}.
#' @param ... Additional argument passed to \code{\link[aws.s3]{copy_object}}
#'
#' @return If successful, information about the copied Object
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/spaces/#copy-object}
#'
#' @examples
#' \dontrun{
#' spaces_copy_object("my-object", "copied-object", "my-space", "another-space")
#'
#' # Copy over the Object with the same key
#' spaces_copy_object("my-object",  from_space = "my-space", to_space = "another-space")
#' }
spaces_copy_object <- function(from_object, to_object = from_object, from_space, to_space, spaces_key = NULL, spaces_secret = NULL, ...) {
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
#' @references \url{https://developers.digitalocean.com/documentation/spaces/#get-object-acls}
#'
#' @examples
#' \dontrun{
#' spaces_get_acl("my-object", "my-space")
#' }
spaces_get_acl <- function(object, space, spaces_key = NULL, spaces_secret = NULL, ...) {
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
#' acl <- spaces_get_acl("my-object", "my-space")
#' # Modify ACL and then run:
#' spaces_put_acl("my-object", "my-space", acl)
#' }
spaces_put_acl <- function(object, space, body, spaces_key = NULL, spaces_secret = NULL, ...) {
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

#' Delete an Object from a Space
#'
#' @param object (character) The Object to delete
#' @param space (character) The Space to delete the Object from
#' @param spaces_key (character) String containing a spaces access key. If
#'   missing, defaults to value stored in an environment variable
#'   \code{DO_SPACES_ACCESS_KEY}.
#' @param spaces_secret (character) String containing the secret associated
#'   with the spaces key. If missing, defaults to value stored in an environment
#'   variable \code{DO_SPACES_SECRET_KEY}.
#' @param ... Additional argument passed to \code{\link[aws.s3]{delete_objects}}
#'
#' @return TRUE if successful, otherwise an object of class aws_error details if not.
#' @export
#'
#' @references \url{https://developers.digitalocean.com/documentation/spaces/#delete-object}
#'
#' @examples
#' \dontrun{
#' spaces_put_object("./some-file.txt", "my-object", "my-space")
#' spaces_delete_object("my-object", "my-space")
#' }
spaces_delete_object <- function(object, space, spaces_key = NULL, spaces_secret = NULL, ...) {
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::delete_object(object,
                        space,
                        check_region = FALSE,
                        key = spaces_key,
                        secret = spaces_secret,
                        base_url = spaces_base,
                        ...)

}
