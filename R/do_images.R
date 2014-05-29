#' Get list of images and their metadata
#'  
#' @importFrom plyr rbind.fill
#' @export
#' @param filter Filter stuff, one of my_images or global
#' @template params
#' @examples \dontrun{
#' head(do_images())
#' do_images(filter='my_images')
#' do_images(what='raw')
#' }

do_images <- function(filter=NULL, what="parsed", ...)
{
  au <- do_get_auth()
  res <- do_handle(what, 'images', ct(filter=filter), ...)
  if(what == 'raw'){ res } else {
    dat <- lapply(res$images, parseres)
    do.call(rbind.fill, dat)
  }
}

parseres <- function(z){
  z[sapply(z, is.null)] <- NA
  z <- z[ !names(z) %in% 'regions' ]
  slugs <- unlist(z$region_slugs)
  ones <- rep(1, length(slugs))
  names(ones) <- slugs
  z <- z[ !names(z) %in% 'region_slugs' ]
  data.frame(c(z, ones), stringsAsFactors = FALSE)
}