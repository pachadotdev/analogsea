spaces_base <- "digitaloceanspaces.com"

#' DigitalOcean Spaces
#'
#' DigitalOcean provides support for storing files (Objects) in Spaces. This is
#' useful for storing related files for fast access, sharing, etc. See
#' https://developers.digitalocean.com/documentation/spaces/
#' for more information. The `aws.s3` package is required to use `analogsea`'s
#' Spaces functionality so be sure to install it with
#' `install.packages("aws.s3")` prior to continuing.
#'
#' In order to get started using the Spaces API, you'll need to generate a new
#' "Spaces access key" in the API section of your DigitalOcean control panel and
#' set the key and its secret as environmental variables via
#' \code{\link{Sys.setenv}}. Set the access key to \code{DO_SPACES_ACCESS_KEY}
#' and its secret to \code{DO_SPACES_SECRET_KEY}. After that, set your region to
#' \code{DO_SPACES_REGION} (e.g., nyc3). Alternatively, you can pass this
#' information as arguments to whichever Spaces API functions you're using.
#'
#' @param space A Space, or the name of the Space as a string.
#' @param object (character) The name of the Object
#'
#' @name spaces_info
#'
#' @examples \dontrun{
#' # List Spaces
#' spaces()
#'
#' # Obtain Spaces as a list of Space objects
#' res <- spaces()
#'
#' # Print Space summary using a Space object
#' summary(res[["my_space_name"]])
#'
#' # Create a new space
#' space_create("new_space_name")
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
#' @references https://developers.digitalocean.com/documentation/spaces/#get-object
#' @examples
#' \dontrun{
#' # List all of your Spaces
#' spaces()
#' }
spaces <- function(spaces_region = NULL,
                   spaces_key = NULL,
                   spaces_secret = NULL, ...) {
  check_for_a_pkg("aws.s3")

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
as.character.space <- function (x, ...) x$Name

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
#' @param ... Additional arguments to `aws.s3::s3HTTP`
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
  name <- as.character(name)

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

#' Create a new Space
#'
#' @export
#' @param name (character) The name of the new Space
#' @template spaces_args
#' @param ... Additional arguments to `aws.s3::put_bucket`
#' @return (character) The name of the created Space.
#' @examples
#' \dontrun{
#' # Create a new Space
#' # (Names must be unique within region)
#' space_create("new_space_name")
#' }
space_create <- function(name,
                         spaces_region = NULL,
                         spaces_key = NULL,
                         spaces_secret = NULL,
                         ...) {
  check_for_a_pkg("aws.s3")

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

  if (res) message(sprintf("New Space %s created successfully.", name))

  invisible(name)
}

#' Delete an existing Space
#'
#' @export
#' @param name (character) The name of the existing Space
#' @template spaces_args
#' @param ... Additional arguments to `aws.s3::delete_bucket`
#' @return (character) The name of the deleted Space.
#' @examples
#' \dontrun{
#' # Delete an existing Space
#' # (Check names within region)
#' space_delete("new_space_name")
#' }
space_delete <- function(name,
                         spaces_region = NULL,
                         spaces_key = NULL,
                         spaces_secret = NULL,
                         ...) {
  check_for_a_pkg("aws.s3")
  check_for_a_pkg("arrow")

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  fs <- arrow::S3FileSystem$create(
    anonymous = ifelse(is.null(spaces_key), TRUE, FALSE),
    scheme = "https",
    access_key = spaces_key,
    secret_key = spaces_secret,
    endpoint_override = sprintf("%s.digitaloceanspaces.com", spaces_region)
  )

  fs$DeleteDirContents(name)

  res <- aws.s3::delete_bucket(name,
                               region = spaces_region,
                               key = spaces_key,
                               secret = spaces_secret,
                               base_url = spaces_base,
                               ...)

  if (res) message(sprintf("Space %s deleted successfully.", name))

  invisible(name)
}

#' Upload a directory to an existing Space
#'
#' @export
#' @param name (character) The name of the existing Space
#' @param local (character) The name of the local directory
#' @param remote (character) The name of the remote directory
#' @template spaces_args
#' @param ... Additional arguments to `arrow::copy_files`
#' @return (character) Success/error message.
#' @examples
#' \dontrun{
#' # Upload to an existing Space
#' # (Check names within region)
#' space_upload("my_space", "my_subdir", "my_subdir", "nyc3",
#'  spaces_key = Sys.getenv("SPACES_KEY"),
#'  spaces_secret = Sys.getenv("SPACES_SECRET"))
#' }
space_upload <- function(name,
                         local = NULL,
                         remote = NULL,
                         spaces_region = NULL,
                         spaces_key = NULL,
                         spaces_secret = NULL,
                         ...) {
  check_for_a_pkg("arrow")

  stopifnot(dir.exists(local))

  if (is.null(remote)) {
    remote <- local
  }

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  fs <- arrow::S3FileSystem$create(
    anonymous = ifelse(is.null(spaces_key), TRUE, FALSE),
    scheme = "https",
    access_key = spaces_key,
    secret_key = spaces_secret,
    endpoint_override = sprintf("%s.digitaloceanspaces.com", spaces_region)
  )

  res <- arrow::copy_files(local,
                           fs$path(sprintf("%s/%s", name, remote)),
                           ...)

  message(sprintf("%s uploaded successfully.", local))
}

#' Upload a directory to an existing Space
#'
#' @export
#' @param name (character) The name of the existing Space
#' @param local (character) The name of the local directory
#' @param remote (character) The name of the remote directory
#' @template spaces_args
#' @param ... Additional arguments to `arrow::copy_files`
#' @return (character) Success/error message.
#' @examples
#' \dontrun{
#' # Upload to an existing Space
#' # (Check names within region)
#' space_download("my_space", "my_subdir", "my_subdir", "nyc3",
#'  spaces_key = Sys.getenv("SPACES_KEY"),
#'  spaces_secret = Sys.getenv("SPACES_SECRET"))
#' }
space_download <- function(name,
                           local = NULL,
                           remote = NULL,
                           spaces_region = NULL,
                           spaces_key = NULL,
                           spaces_secret = NULL,
                           ...) {
  check_for_a_pkg("arrow")

  if (is.null(local)) {
    local <- remote
  }

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  fs <- arrow::S3FileSystem$create(
    anonymous = ifelse(is.null(spaces_key), TRUE, FALSE),
    scheme = "https",
    access_key = spaces_key,
    secret_key = spaces_secret,
    endpoint_override = sprintf("%s.digitaloceanspaces.com", spaces_region)
  )

  res <- arrow::copy_files(fs$path(sprintf("%s/%s", name, remote)),
                           local,
                           ...)

  message(sprintf("%s download successfully.", remote))
}
