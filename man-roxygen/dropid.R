#' @section Missing droplet ID:
#' If you get a droplet object back without an IP address, the IP 
#' address was not assigned when the payload was returned by DigitalOcean. 
#' Simply run `d <- droplet(d$id)` to update your droplet object and the IP
#' address will populate.
