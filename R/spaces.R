spaces_base <- "digitaloceanspaces.com"

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
#' @template spaces_args
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
spaces_GET <- function(spaces_region = NULL,
                       spaces_key = NULL,
                       spaces_secret = NULL, ...) {

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  res <- aws.s3::s3HTTP(verb = "GET",
                        region = spaces_region,
                        key = spaces_key,
                        secret = spaces_secret,
                        base_url = spaces_base,
                        ...)

  return(res)
}

#' @export
#' @rdname spaces
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

#' @importFrom aws.s3 get_bucket
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

  space_info <- get_bucket(name,
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

#' Create a new space
#'
#' This function is not implemented yet. A working implementation is planned in
#' future releases of this package.
#'
#' @importFrom aws.s3 put_bucket
#' @rdname spaces
space_create <- function(name,
                         spaces_region = NULL,
                         spaces_key = NULL,
                         spaces_secret = NULL,
                         ...) {

  if (is.null(name)) stop("Please specify the space name")

  spaces_region <- check_space_region(spaces_region)
  spaces_key <- check_space_access(spaces_key)
  spaces_secret <- check_space_secret(spaces_secret)

  res <- put_bucket(name,
                    region = spaces_region,
                    key = spaces_key,
                    secret = spaces_secret,
                    base_url = spaces_base,
                    location_constraint = NULL,
                    ...)

  if (res) message(sprintf("New space %s created successfully", name))
}
