# tests for droplets
context("droplets")

a <- droplets()
b <- droplets(what = 'raw')

test_that("droplets returns the correct dimensions", {
  expect_equal(length(a), 3)
  expect_equal(names(a), c('droplet_ids','droplets','event_id'))

  expect_equal(length(b), 8)
})

test_that("droplets returns the correct class", {
  expect_is(a, "list")
  expect_is(b, "response")
})

test_that("httr curl options work", {
  library("httr")
  expect_error(droplets(config=timeout(seconds = 0.001)))
})