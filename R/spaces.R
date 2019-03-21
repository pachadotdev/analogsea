spaces_base <- "digitaloceanspaces.com"

#' DigitalOcean Spaces
#'
#' DigitalOcean provides support for storing files (Objects) in Spaces. This is
#' useful for storing related files for fast access, sharing, etc. See the
#' \url{https://developers.digitalocean.com/documentation/spaces/}
#' for more information.
#'
#' @param space (character) The name of the Space
#' @param object (character) The name of the Object
#'
#' @name spaces_info
#'
#' @examples \dontrun{
#' # List Spaces
#' spaces()
#'
#' # Obtain Spaces as a list of space objects
#' res <- spaces()
#'
#' # Print space summary using a space object
#' summary(res[["my_space_name"]])
#'
#' # Create a new space
#' space_create("new_space_name")
#'
#' # Create an Object in a Space
#' spaces_object_put("some_file", "new_space_name")
#'
#' # Delete an Object from a Space
#' spaces_object_delete("some_file", "new_space_name")
#'
#' # Delete a Space (can only be done on an empty Space)
#' space_delete("new_space_name")
#' }
#'
NULL

check_space_region <- function(spaces_region) {
  tmp <- ifelse(is.null(spaces_region),
                Sys.getenv("DO_SPACES_REGION"),
                spaces_region)
  if (tmp == "") {
    stop("Need a digital ocean spaces region in your session. e.g. Sys.setenv(\"DO_SPACES_REGION\"=\"nyc3\")",
         call. = FALSE)
  } else {
    tmp
  }
}

check_space_access <- function(spaces_key) {
  tmp <- ifelse(is.null(spaces_key),
                Sys.getenv("DO_SPACES_ACCESS_KEY"),
                spaces_key)
  if (tmp == "") {
    stop("Need a digital ocean spaces access key defined in your session. e.g. Sys.setenv(\"DO_SPACES_ACCESS_KEY\"=\"{YOUR_KEY}\")",
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
    stop("Need a digital ocean spaces secret key defined in your session. e.g. Sys.setenv(\"DO_SPACES_SECRET_KEY\"=\"{YOUR_SECRET}\")",
         call. = FALSE)
  } else {
    tmp
  }
}

#' List all Spaces.
#' @template spaces_args
#' @param ... Additional arguments to \code{\link{spaces_GET}}
#' @return (list)  A list of Spaces. Can be empty.
#' @export
spaces <- function(spaces_region = NULL,
                   spaces_key = NULL,
                   spaces_secret = NULL, ...) {
  res <- spaces_GET(spaces_region = spaces_region,
                    spaces_key = spaces_key,
                    spaces_secret = spaces_secret,
                    ...)

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

#' Coerce an object to a \code{space}
#'
#' @param x Object to coerce to a space
#' @export
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

#' Internal helper method to get information about a Space
#'
#' @template spaces_args
#' @param ... Additional arguments to \code{\link[aws.s3]{s3HTTP}}
#'
#' @return The raw S3 response, or throws an error
spaces_GET <- function(spaces_region = NULL,
                       spaces_key = NULL,
                       spaces_secret = NULL, ...) {

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  aws.s3::s3HTTP(verb = "GET",
                 region = spaces_region,
                 key = spaces_key,
                 secret = spaces_secret,
                 base_url = spaces_base,
                 ...)

}



#' @keywords internal
space_info <- function(name,
                       spaces_region = NULL,
                       spaces_key = NULL,
                       spaces_secret = NULL,
                       ...) {
  if (is.null(name)) stop("Please specify the space name")

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  space_info <- aws.s3::get_bucket(name,
                                   region = spaces_region,
                                   check_region = FALSE,
                                   key = spaces_key,
                                   secret = spaces_secret,
                                   base_url = spaces_base,
                                   max = Inf,
                                   ...)

  return(space_info)
}

#' Get the size of all Objects in a Space
#'
#' @param space_info (space) A Space object.
#' @return (numeric) The total of size of all Objects in the space in GiB.
#' @export
space_size <- function(space_info) {
  # grab the sizes from each file (unit is bytes)
  sizes <- vapply(space_info, function(x) x$Size, numeric(1))

  # compute total size (convert to gb)
  sum(sizes) * 1e-09
}

#' Get number of Objects in a Space
#' @param space_info (space) A Space object.
#' @return (numeric) The number of files in the Space.
#' @export
space_files <- function(space_info) {
  # remove entries with size 0 (those are nested directories)
  length(lapply(space_info, function(x) x[x$Size > 0]))
}

#' List the Objects in a Space
#'
#' @param name (character) The Space's name
#' @param ... Additional arguments passed to \code{\link[aws.s3]{get_bucket_df}}
#' @template spaces_args
#'
#' @return (data.frame) The Spaces contents as a \code{data.frame}
#' @export
#' @examples
#' \dontrun{
#' # List the contents of the space "example"
#' space_list("example")
#' }
space_list <- function(name,
                       spaces_region = NULL,
                       spaces_key = NULL,
                       spaces_secret = NULL,
                       ...) {
  if (is.null(name)) stop("Please specify the space name")

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  space_info <- aws.s3::get_bucket_df(name,
                                      region = spaces_region,
                                      check_region = FALSE,
                                      key = spaces_key,
                                      secret = spaces_secret,
                                      base_url = spaces_base,
                                      max = Inf,
                                      ...)

  return(space_info)
}

#' Create a new Space
#'
#' @export
#' @param name (character) The name of the new Space
#' @template spaces_args
#' @param ... Additional arguments to \code{\link[aws.s3]{put_bucket}}
#' @return (character) The name of the created Space.
space_create <- function(name,
                         spaces_region = NULL,
                         spaces_key = NULL,
                         spaces_secret = NULL,
                         ...) {

  if (is.null(name)) stop("Please specify the space name")

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  res <- aws.s3::put_bucket(name,
                            region = spaces_region,
                            key = spaces_key,
                            secret = spaces_secret,
                            base_url = spaces_base,
                            location_constraint = NULL,
                            ...)

  if (res) message(sprintf("New space %s created successfully", name))

  invisible(name)
}

#' Delete a Space
#'
#' @export
#' @param name (character) The name of the new Space
#' @template spaces_args
#' @param ... Additional arguments to \code{\link[aws.s3]{put_bucket}}
#' @return (character) The name of the created Space.
space_delete <- function(name,
                         spaces_region = NULL,
                         spaces_key = NULL,
                         spaces_secret = NULL,
                         ...) {

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  res <- aws.s3::delete_bucket(name,
                               region = spaces_region,
                               key = spaces_key,
                               secret = spaces_secret,
                               base_url = spaces_base,
                               ...)

}

#' Get the region of a Space
#'
#' @param name (character) The name of the Space
#' @param ... Additional arguments passed to \code{\link[aws.s3]{s3HTTP}}
#' @template spaces_args
#'
#' @return (character) The region the Space is in
#' @export
#'
#' @examples
#' \dontrun{
#' # Create a space and get its location
#' sp <- create_space("my-space")
#' space_location(sp)
#' }
space_location <- function(name,
                           spaces_region = NULL,
                           spaces_key = NULL,
                           spaces_secret = NULL,
                           ...) {
  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  r <- aws.s3::s3HTTP("GET",
                      name,
                      query = list(location = ""),
                      region = spaces_region,
                      key = spaces_key,
                      secret = spaces_secret,
                      base_url = spaces_base,
                      ...)

  # Stop now with an error if things don't look righta
  if (!is.list(r) && length(r) >= 1 && !is.character(r[[1]])) {
    stop(paste0("Something went wrong with the request to get the region for ",
                "the Space '",
                name,
                "'."))
  }

  r[[1]]
}
