test_that("install R pkgs works", {
  skip_on_cran()

  # using 4 CPUs + 8GB RAM droplet for faster testing
  r <- "tor1"
  s <- "c2-4vcpu-8gb"
  img <- "rstudio-20-04"

  # use rstudio image fro quicker testing
  n <- paste("ubuntu-test", gsub(":", "", gsub(".* ", "", Sys.time())), sep = "-")
  x <- droplet_create(n, region = r, size = s, image = img, wait = T)
  x <- droplet(x$id)

  # wait until all services load
  Sys.sleep(30)

  expect_equal(x$status, "active")
  expect_false(x$locked)

  # install eflm bc it has no deps besides base, quick test
  y <- install_r_package(x, "eflm", keyfile = "~/.ssh/id_rsa")
  expect_false(y$locked)
  expect_equal(y$status, "active")

  z <- install_github_r_package(x, "pachamaltese/eflm")
  expect_false(z$locked)
  expect_equal(z$status, "active")

  expect_silent(droplet_delete(x))
})
