#' Get list of images and their metadata, or a single image
#'
#' @importFrom plyr rbind.fill
#' @export
#' @param image (numeric) This is the id or slug of the image to return
#' @template params
#' @examples \dontrun{
#' out <- images()
#' out$images
#' images(image=6374124)
#' images(image='coreos-alpha')
#' images(per_page=2)
#' }

images <- function(image=NULL, page=1, per_page=25) {
  path <- if(is.null(image)) 'images' else sprintf('images/%s', image)
  res <- do_GET(path, query = list(page=page, per_page=per_page))
  list(images=parseimg(image, res[[1]]), meta=res$meta, links=res$links)
}

parseimg <- function(image, x) if(is.null(image)) imagestodf(x) else imagetodf(x)
imagestodf <- function(x) do.call(rbind.fill, lapply(x, imagetodf))
imagetodf <- function(x){
  data.frame(lapply(x, function(z){
    tmp <- if(is(z, "list")) paste(unlist(z), collapse = ", ") else z
    if(is.null(tmp)) NA else tmp
  }), stringsAsFactors=FALSE)
}

#' Delete an image
#'
#' There is no way to restore a deleted image so be careful and ensure your data is properly
#' backed up before deleting it.
#'
#' @export
#' @param image_id (numeric) This is the id of the image to return
#' @param config Options passed on to httr::GET. Must be named, see examples.
#' @examples \dontrun{
#' images_delete(image_id=5620385)
#' }

images_delete <- function(image_id=NULL, ...)
{
  assert_that(!is.null(image_id))
  do_DELETE(sprintf('images/%s', image_id), ...)
}

#' Transfer an image to a specified region.
#'
#' @export
#' @param image_id (numeric) Required. The image id.
#' @param region (numeric) Required. The region slug that represents the region target.
#' @template whatconfig
#' @examples \dontrun{
#' images_transfer(image_id=5710271, region='nyc2')
#' images_transfer(image_id=4546004, region='nyc1')
#' }

images_transfer <- function(image_id=NULL, region=NULL) {
  assert_that(!is.null(image_id), !is.null(region))
  res <- do_POST(sprintf('images/%s/actions', image_id), 
    body = list(type='transfer', region=region))
  as.action(res)
}

#' Rename an image.
#' 
#' In the API docs, they call this updating the image, but the only thing you can do is rename it.
#'
#' @export
#' @param image_id (numeric) This is the id of the image to return
#' @param name (characer) New name for image.
#' @template whatconfig
#' @examples \dontrun{
#' images_rename(image_id=5710271, name='mirror_image2')
#' }

images_rename <- function(image_id=NULL, name=NULL, ...) {
  res <- do_PUT(sprintf('images/%s', image_id), query = list(name=name), ...)
  parse_img(res$image)
}

#' Retrieve an action associated with a particular image id.
#'
#' @export
#' @param image_id An image id.
#' @param action_id An action id associated with an image.
#' @template whatconfig
#' @examples \dontrun{
#' images_actions(5710271, 31221438)
#' }

images_actions <- function(image_id=NULL, action_id=NULL, ...)
{
  res <- do_GET(sprintf('images/%s/actions/%s', image_id, action_id), ...)
  parse_action(res$action)
}
