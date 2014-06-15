#' Get list of images and their metadata, or a single image
#'
#' @importFrom plyr rbind.fill
#' @export
#' @param image_id (numeric) This is the id of the image to return
#' @param image_slug (character) This is the slug of the image to return
#' @param filter Filter stuff, one of my_images or global
#' @template params
#' @examples \dontrun{
#' head(images_get())
#' images_get(filter='my_images')
#' images_get(what='raw')
#' images_get(image_id=3209452)
#' images_get(image_id=4315195)
#' }

images_get <- function(image_id=NULL, image_slug=NULL, filter=NULL, what="parsed", ...)
{
  if(!is.null(image_id) || !is.null(image_slug)){
    assert_that(xor(is.null(image_id), is.null(image_slug)))
    if(!is.null(image_id)){
      assert_that(is.numeric(as.numeric(image_id)))
      id <- image_id
    }
    if(!is.null(image_slug)){
      assert_that(is.character(image_slug))
      id <- image_slug
    }
  } else { id <- NULL }
  path <- if(is.null(id)) 'images' else sprintf('images/%s', id)
  res <- do_GET(what, FALSE, path = path, query = ct(filter=filter), ...)
  if(what == 'raw'){ res } else {
    if(!is.null(id)){ res$image } else {
      dat <- lapply(res$images, parseres)
      do.call(rbind.fill, dat)
    }
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

#' Destroy an image
#'
#' There is no way to restore a deleted image so be careful and ensure your data is properly
#' backed up.
#'
#' @export
#' @param image_id (numeric) This is the id of the image to return
#' @param image_slug (character) This is the slug of the image to return
#' @template params
#' @examples \dontrun{
#' images_get(image_id=4315195)
#' }

images_destroy <- function(image_id=NULL, image_slug=NULL, what="parsed", ...)
{
  assert_that(xor(is.null(image_id), is.null(image_slug)))
  id <- ct(image_id=image_id, image_slug=image_slug)
  path <- sprintf('images/%s/destroy', id)
  do_GET(what, FALSE, path = path, ...)
}

#' Transfer an image to a specified region.
#'
#' @export
#' @param image_id (numeric) This is the id of the image to return
#' @param image_slug (character) This is the slug of the image to return
#' @param region_id (numeric) Required. This is the id of the region to which you would like
#' to transfer.
#' @template params
#' @examples \dontrun{
#' id <- droplets_new(name="stuffstuff", size_id = 64, image_id = 3240036, region_slug = 'sfo1')
#' droplets(id$droplet$id) %>%
#'  droplets_power_off %>%
#'  droplets_snapshot(name = "coolimage")
#' images_transfer(image_id=4315784, region_id=4)
#' }

images_transfer <- function(image_id=NULL, image_slug=NULL, region_id=NULL, what="parsed", ...)
{
  assert_that(xor(is.null(image_id), is.null(image_slug)))
  id <- ct(image_id=image_id, image_slug=image_slug)
  path <- sprintf('images/%s/transfer', id)
  res <- do_GET(what, FALSE, path = path, query = ct(region_id=region_id), ...)
  res[ !names(res) %in% "status" ]
}
