list_to_object <- function(x, singular, plural = paste0(singular, "s"),
                  name = "name", class = singular) {
  if (!is.null(x[[plural]])) {
    objs <- lapply(x[[plural]], structure, class = class)
    if (!is.null(name)) {
      names(objs) <- pluck(x[[plural]], name, character(1))
    }
    objs
  } else if (!is.null(x[[singular]])) {
    structure(x[[singular]], class = class)
  } else {
    stop("Don't know how to coerce this list to a ", class , call. = FALSE)
  }
}

mssg <- function(x, y) if (x) message(y)

writefile <- function(filename, installstring){
  installrfile = filename
  fileConn <- file(installrfile)
  writeLines(installstring, fileConn)
  close(fileConn)
}

cli_tools <- function(ip){
  tmp <- Sys.which(c("ssh","scp"))
  if (any(tmp == "")) {
    nf <- paste0(names(tmp)[tmp == ""], collapse = ", ")
    stop(sprintf("\n%s not found on your computer\nInstall the missing tool(s) and try again", nf))
  }
}

ascompact <- function(x) Filter(Negate(is.null), x)

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

`%||%` <- function(a, b) if (is.null(a)) b else a

unbox <- function(x) {
  if (is.null(x)) x else jsonlite::unbox(x)
}

get_price <- function(slug){
  sz <- sizes()
  as.list(sz[ sz$slug == slug , c("price_monthly","price_hourly") ])
}

al <- function(x){
  stopifnot(is.logical(x))
  if (x) 'true' else 'false'
}

cn <- function(x, y) if (nchar(y) == 0) y else paste0(x, y)

strExtract <- function(str, pattern) regmatches(str, regexpr(pattern, str))

strTrim <- function(str) gsub("^\\s+|\\s+$", "", str)

check_for_a_pkg <- function(x) {
  if (!requireNamespace(x, quietly = TRUE)) {
    stop("Please install ", x, call. = FALSE)
  } else {
    invisible(TRUE)
  }
}

.onAttach <- function(...) {
  message("ANALOGSEA")
  message("=========")
  message("This package requieres a DigitalOcean account.")
  message("Visit m.do.co/c/1d5a471e5f54. By using this link, you'll \nstart with $100 in credits with a 2 months limit.")
  message("You can also sponsor this package at buymeacoffee.com/pacha.")
}
