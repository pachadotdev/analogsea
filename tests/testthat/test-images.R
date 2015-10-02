# tests for images
context("images")

test_that("returns expected output for public images", {
  skip_on_cran()

  imgs <- images()

  expect_is(imgs, "list")
  expect_is(imgs[[1]], "image")
  expect_is(imgs[[1]]$id, "integer")
  expect_is(imgs[[1]]$name, "character")
  expect_true(imgs[[1]]$public)
})

test_that("fails well with wrong input type to private parameter", {
  skip_on_cran()

  expect_error(images(private = "af"), "is not TRUE")
})

test_that("works with type parameter", {
  skip_on_cran()

  imgs_dist <- images(type = "distribution")
  imgs_appl <- images(type = "application")

  expect_is(imgs_dist, "list")
  expect_is(imgs_appl, "list")

  expect_false(any(grepl("Docker", names(imgs_dist))))
  expect_true(any(grepl("Docker", names(imgs_appl))))
})

test_that("public parameter is defunct", {
  skip_on_cran()

  expect_error(images(public = TRUE), "The parameter public has been removed, see private")
})

test_that("httr curl options work", {
  skip_on_cran()

  library("httr")
  expect_error(images(config = timeout(seconds = 0.001)))
})
