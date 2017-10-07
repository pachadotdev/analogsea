# tests for spaces
context("space")

test_that("fails well with no input", {
  expect_error(space_GET(), "argument \"name\" is missing")
})
