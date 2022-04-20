# tests for spaces
context("spaces")

test_that("list, create, and delete spaces work", {
  skip_on_cran()

  # add random integer to avoid duplicated names
  sout <- tolower(paste0("mtcars-", analogsea:::random_name()))

  space_create(sout, "nyc3", spaces_key = Sys.getenv("SPACES_KEY"),
               spaces_secret = Sys.getenv("SPACES_SECRET"))

  dout <- tempdir()
  dout <- paste0(dout, "/mtcars")
  try(dir.create(dout))
  fout <- paste0(dout, "/mtcars.csv")
  write.csv(mtcars, fout)

  space_upload(sout, dout, "subdir", "nyc3", spaces_key = Sys.getenv("SPACES_KEY"),
               spaces_secret = Sys.getenv("SPACES_SECRET"))

  dinp <- tempdir()
  space_download(sout, dinp, "subdir", "nyc3", spaces_key = Sys.getenv("SPACES_KEY"),
                 spaces_secret = Sys.getenv("SPACES_SECRET"))

  space_delete(sout, "nyc3", spaces_key = Sys.getenv("SPACES_KEY"),
               spaces_secret = Sys.getenv("SPACES_SECRET"))
})
