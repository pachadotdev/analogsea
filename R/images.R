#####
# Images
# Get list of images and their metadata
do_images(filter='my_images', client_id='dfadeb9dc1b68d93119f886f8aa36393', api_key='16ff41ec1f6a4ec6d3f0107f639a59b7')

do_images <- function(filter=NULL, client_id=NULL, api_key=NULL, what="list", callopts=list())
{
  url <- 'https://api.digitalocean.com/v1/images'
  args <- compact(list(filter=filter, client_id=client_id, api_key=api_key))
  do_handle(url, args, callopts)
}