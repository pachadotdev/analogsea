context("droplet_create")

test_that("create and delete droplet works", {
  skip_on_cran()
  # skip_on_ci()

  # check regions and hardware before passing arguments to droplet_create()
  # r <- regions()
  # r2 <- r$slug[1]
  # s <- sizes()
  # s2 <- grep(r2, s$region)
  # s2 <- s[s2, ]
  # s2 <- s2$slug[1]
  # using CPU optimized 4GB RAM droplet for faster testing
  r <- "tor1"
  s <- "c2-4vcpu-8gb"
  img <- "ubuntu-20-04-x64"

  n <- paste("rstudio-test", gsub(":", "", gsub(".* ", "", Sys.time())), sep = "-")
  x <- droplet_create(n, region = r, size = s, image = img, wait = T)

  Sys.sleep(15)
  expect_gte(x$id, 0)
  expect_equal(x$name, n)
  expect_false(x$locked)
  expect_equal(x$status, "active")
  expect_is(x$features, "list")
  expect_is(x$region, "list")
  expect_equal(x$region$slug, r)
  expect_true(x$region$available)

  expect_silent(droplet_delete(x))
})
