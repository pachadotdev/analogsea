# tests for sizes
context("sizes")

test_that("returns expected output", {
	skip_on_cran()

  siz <- sizes()

  expect_is(siz, "data.frame")
  expect_is(siz$slug, "character")
  expect_is(siz$available, "logical")
  expect_is(siz$price_monthly, "numeric")
})

test_that("httr curl options work", {
	skip_on_cran()

  library("httr")
  expect_error(sizes(config = timeout(seconds = 0.001)))
})
