# tests for regions
context("regions")

a <- regions()
b <- regions('raw')
  
test_that("regions returns the correct dimensions", {
  expect_equal(NCOL(a), 3)
  expect_equal(names(a), c('id','name','slug'))
  
  expect_equal(length(b), 8)
})

test_that("regions returns the correct class", {
  expect_is(a, "data.frame")
  expect_is(b, "response")
})

test_that("incorrect input to what param returns NULL", {
  expect_null(regions("asfasd"))
})