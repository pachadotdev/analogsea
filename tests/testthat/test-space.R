# tests for spaces
context("space")

test_that("fails well with no input", {
  expect_error(space_info(), "argument \"name\" is missing")
})

test_that("key checks fail when not defined in environment", {
  skip_on_cran()

  Sys.unsetenv("DO_SPACES_ACCESS_KEY")
  expect_error(check_space_access(spaces_key = NULL),
               "Need a digital ocean spaces access key defined in your session")

  Sys.unsetenv("DO_SPACES_SECRET_KEY")
  expect_error(check_space_secret(spaces_secret = NULL),
               "Need a digital ocean spaces secret key defined in your session")
})
