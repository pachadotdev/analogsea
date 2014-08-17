#' Get list of images and their metadata, or a single image
#'
#' @importFrom plyr rbind.fill
#' @export
#' @param image_id (numeric) This is the id of the image to return
#' @param image_slug (character) This is the slug of the image to return
#' @param filter Filter stuff, one of my_images or global
#' @template params
#' @examples \dontrun{
#' out <- images()
#' out$data
#' out$action_ids
#' sapply(out$action_ids, names)
#' 
#' head(images()$data)
#' images(filter='my_images')
#' images(what='raw')
#' images(image_id=3209452)
#' images(image_id=4315195)
#' }

images <- function(image_id=NULL, image_slug=NULL, filter=NULL, what="parsed", page=1, per_page=25, ...)
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
  res <- do_GET(what, FALSE, path = path, query = ct(filter=filter, page=page, per_page=per_page), parse=FALSE, ...)
  if(what == 'raw'){ res } else {
    if(!is.null(id)){ res$images } else {
      dat <- lapply(res$images, parseres)
      df <- do.call(rbind.fill, lapply(dat, "[[", "data"))
      list(data=df, action_ids=lapply(dat, "[[", "action_ids"))
    }
  }
}

parseres <- function(z){
  z[sapply(z, is.null)] <- NA
  z$regions <- paste(z$regions, collapse = ",")
  z$action_ids <- paste(z$action_ids, collapse=",")
  tmp <- c(z$action_ids)
  names(tmp) <- z$id
  list(data=data.frame(z[!names(z)%in%"action_ids"], stringsAsFactors = FALSE), action_ids=tmp)
}

#' Delete an image
#'
#' There is no way to restore a deleted image so be careful and ensure your data is properly
#' backed up before deleting it.
#'
#' @export
#' @param image_id (numeric) This is the id of the image to return
#' @template params
#' @examples \dontrun{
#' images_delete(image_id=5620385)
#' }

images_delete <- function(image_id=NULL, what="parsed", ...)
{
  assert_that(!is.null(image_id))
  path <- sprintf('images/%s', image_id)
  do_DELETE(what, path = path, ...)
}

do_DELETE <- function(what, path, parse=FALSE, ...) {
  url <- file.path("https://api.digitalocean.com/v2", path)
  au <- do_get_auth()
  auth <- add_headers(Authorization = sprintf('Bearer %s', au$token))
  
  tt <- DELETE(url, config = c(auth, ...))
  if(tt$status_code > 204){
    if(tt$status_code > 204) stop(content(tt)$message)
    if(content(tt)$status == "ERROR") stop(content(tt)$message)
  }
  if(http_status(tt)$category=='success'){
    message(http_status(tt)$message)
    invisible(http_status(tt)$message)
  } else { stop('Something went wrong') }
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
#' 
#' images_transfer(image_id=4546004, region_slug='nyc1')
#' }

images_transfer <- function(image_id=NULL, image_slug=NULL, region_slug=NULL, what="parsed", ...)
{
  assert_that(xor(is.null(image_id), is.null(image_slug)))
  id <- ct(image_id=image_id, image_slug=image_slug)
  path <- sprintf('images/%s/actions', id)
  do_GET(what, FALSE, path = path, query = ct(region=region_slug, type='transfer'), parse=TRUE, ...)
}
