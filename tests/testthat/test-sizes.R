# tests for sizes
context("sizes")

a <- sizes()
b <- sizes('raw')

test_that("sizes returns the correct dimensions", {
  expect_equal(NCOL(a), 8)
  expect_equal(names(a), c('id','name','slug','memory','cpu','disk','cost_per_hour','cost_per_month'))

  expect_equal(length(b), 8)
})

test_that("sizes returns the correct class", {
  expect_is(a, "data.frame")
  expect_is(a$cost_per_hour, "numeric")
  expect_is(b, "response")
})

test_that("incorrect input to what param returns NULL", {
  expect_null(sizes("asfasd"))
})
