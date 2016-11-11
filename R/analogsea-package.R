#' @title R client for Digital Ocean
#'
#' @description This package is an R client for Digital Ocean's RESTful API,
#' and a set of scripts that allow you to install R, RStudio server, RStudio
#' Shiny server, or OpenCPU server, in addition to common packages used. The
#' goal here is to spin up a cloud R environment without leaving R, and
#' requiring no knowledge other than R. Of course if you are more experienced
#' you can log in on the command line and modify anything you want, but for
#' those that just want a quick cloud R environment, this
#' should be one of the easiest options.
#'
#' You need to authenticate to use this package. Get your auth token at
#' https://cloud.digitalocean.com/settings/api/tokens - See
#' \code{\link{do_oauth}} for more on authentication.
#'
#' @section ssh keys:
#' \pkg{analogsea} allows you to interact with your droplet(s) from R via SSH.
#' To do this you need to setup SSH keys with Digital Ocean. Make sure you
#' provide Digitial Ocean your public key at
#' \url{https://cloud.digitalocean.com/ssh_keys}. GitHub has some good advice
#' on creating a new public key if you don't already have one:
#' \url{https://help.github.com/articles/generating-ssh-keys}.
#'
#' Note that when using ssh, you'll likely get warnings like "The authenticity
#' of host can't be established ...". This is normal, don't be worried about
#' this.
#'
#' Note that if you want to connect over SSH to a droplet you have to
#' create the droplet with an SSH key with the \code{ssh_keys} parameter.
#' If you don't you can still interact with the droplet via the Digital
#' Ocean API, but you can't access the droplet over SSH.
#'
#' @importFrom stats setNames
#' @importFrom utils browseURL read.csv
#' @importFrom jsonlite fromJSON unbox
#' @importFrom httr VERB HEAD GET POST add_headers oauth_endpoint oauth2.0_token
#' config oauth_app stop_for_status content status_code headers
#' @importFrom yaml yaml.load_file as.yaml
#' @name analogsea-package
#' @aliases analogsea
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @author Hadley Wickham \email{hadley@@rstudio.com}
#' @author Winston Chang \email{winston@@stdout.org}
#' @author Bob Rudis \email{bob@@rudis.net}
#' @docType package
#' @keywords package
NULL

#' 1000 words to use for seeding random word selection when name not given
#' for a droplet
#' @name words
#' @docType data
#' @keywords data
NULL

#' Adjectives to use for seeding random word selection when name not given
#' for a droplet
#'
#' @details A vector of 999 adjectives. From the GitHub repo
#' \url{https://github.com/dariusk/corpora} - the data is licensed CC0.
#' @name adjectives
#' @docType data
#' @keywords data
NULL

#' Nouns to use for seeding random word selection when name not given
#' for a droplet
#'
#' @details A vector of 1000 nouns From the GitHub repo
#' \url{https://github.com/dariusk/corpora} - the data is licensed CC0.
#' @name nouns
#' @docType data
#' @keywords data
NULL
