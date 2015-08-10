# tests for regions
context("regions")

test_that("returns expected output", {
  regs <- regions()

  expect_is(regs, "data.frame")
  expect_is(regs$slug, "character")
  expect_is(regs$available, "logical")
})

test_that("httr curl options work", {
  library("httr")
  expect_error(regions(config = timeout(seconds = 0.001)))
})
