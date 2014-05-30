#' Get list of images and their metadata
#'  
#' @importFrom plyr rbind.fill
#' @export
#' @param filter Filter stuff, one of my_images or global
#' @template params
#' @examples \dontrun{
#' head(images())
#' images(filter='my_images')
#' images(what='raw')
#' }

images <- function(filter=NULL, what="parsed", ...)
{
  res <- do_handle(what, path='images', query = ct(filter=filter), ...)
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