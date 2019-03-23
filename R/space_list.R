#' List the Objects in a Space
#'
#' @param space A Space, or something that can be coerced to a Space by
#'   \code{\link{as.space}}.
#' @param ... Additional arguments passed to \code{\link[aws.s3]{get_bucket_df}}
#' @template spaces_args
#'
#' @return (data.frame) The Spaces contents as a \code{data.frame}
#' @export
#' @references \url{https://developers.digitalocean.com/documentation/spaces/
#' #list-bucket-contents}
#' @examples
#' \dontrun{
#' # List the contents of the Space "example"
#' space_list("example")
#' }
space_list <- function(space,
                       spaces_region = NULL,
                       spaces_key = NULL,
                       spaces_secret = NULL,
                       ...) {
  name <- as.character(space)

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
