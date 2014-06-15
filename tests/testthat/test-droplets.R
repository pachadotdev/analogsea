# tests for droplets
context("droplets")

a <- droplets()
b <- droplets(what = 'raw')

c <- droplets_new(name="testingtesting123", size_id = 66, image_id = 3240036, region_slug = 'sfo1')

test_that("droplets returns the correct dimensions", {
  expect_equal(length(a), 3)
  expect_equal(names(a), c('droplet_ids','droplets','event_id'))

  expect_equal(length(b), 8)

  expect_equal(length(c), 1)
  expect_equal(length(c$droplet), 5)
})

test_that("droplets returns the correct class", {
  expect_is(a, "list")
  expect_is(b, "response")
  expect_is(c, "list")
})

test_that("httr curl options work", {
  library("httr")
  expect_error(droplets(config=timeout(seconds = 0.001)))
})

# cleanup
droplets_destroy(droplets(c$droplet$id))
