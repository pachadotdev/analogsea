#' @title R client for Digital Ocean
#'
#' @description This package is an R client for Digital Ocean's RESTful API, and a set
#' of scripts that allow you to install R, RStudio server, RStudio Shiny server, or
#' OpenCPU server, in addition to common packages used. The goal here is to spin up a
#' cloud R environment without leaving R, and requiring no knowledge other than R. Of
#' course if you are more experienced you can log in on the command line and modify
#' anything you want, but for those that just want a quick cloud R environment, this
#' should be one of the easiest options.
#'
#' You need to authenticate to use this package. Get your auth token at
#' https://cloud.digitalocean.com/settings/applications. See \code{\link{do_oauth}}
#' for more on authentication.
#'
#' @importFrom stats setNames
#' @importFrom utils browseURL read.csv
#' @importFrom jsonlite fromJSON unbox
#' @importFrom httr HEAD GET POST add_headers oauth_endpoint oauth2.0_token config oauth_app
#' stop_for_status content status_code headers
#' @importFrom yaml yaml.load_file as.yaml
#' @name analogsea-package
#' @aliases analogsea
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @author Hadley Wickham \email{hadley@@rstudio.com}
#' @author Winston Chang \email{winston@@stdout.org}
#' @docType package
#' @keywords package
NULL

#' 1000 words to use for seeding random word selection when name not given for a droplet
#' @name words
#' @docType data
#' @keywords data
NULL

#' Adjectives to use for seeding random word selection when name not given for a droplet
#'
#' @details A vector of 999 adjectives. From the GitHub repo
#' \url{https://github.com/dariusk/corpora} - the data is licensed CC0.
#' @name adjectives
#' @docType data
#' @keywords data
NULL

#' Nouns to use for seeding random word selection when name not given for a droplet
#'
#' @details A vector of 1000 nouns From the GitHub repo
#' \url{https://github.com/dariusk/corpora} - the data is licensed CC0.
#' @name nouns
#' @docType data
#' @keywords data
NULL
