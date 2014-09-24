# tests for droplets
context("droplets")

source("keys.R")

test_that("httr curl options work", {
  library("httr")
  expect_error(droplets(config=timeout(seconds = 0.001)))
})
