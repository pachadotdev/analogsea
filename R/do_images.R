#' Get list of images and their metadata
#'  
#' @importFrom plyr rbind.fill
#' @export
#' @param filter Filter stuff, one of my_images or global
#' @param what (character) One of parsed (data.frame) or raw (httr response object)
#' @param callopts Curl options passed on to httr::GET
#' @examples \dontrun{
#' head(do_images())
#' do_images(filter='my_images')
#' do_images(what='raw')
#' }

do_images <- function(filter=NULL, what="parsed", callopts=list())
{
  au <- do_get_auth()
  url <- 'https://api.digitalocean.com/v1/images'
  args <- ct(filter=filter, client_id=au$id, api_key=au$key)
  res <- do_handle(what, url, args, callopts)
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