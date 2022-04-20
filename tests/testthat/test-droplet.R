# tests for droplet
context("droplet")

test_that("fails well with no input", {
  expect_error(droplet(), "argument \"id\" is missing")
})

test_that("fails well with non-existent droplet", {
	skip_on_cran()

  expect_error(droplet("Baby Shark doo doo, doo doo doo doo"), "The resource you were accessing could not be found")
})

test_that("httr curl options work", {
	skip_on_cran()

  library("httr")
  expect_error(droplet("Baby Shark doo doo, doo doo doo doo", config = timeout(seconds = 0.001)))
})
