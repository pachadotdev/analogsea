test_that("pull Docker images work (Ubuntu)", {
  skip_on_cran()

  # Create droplet ----

  # using 4 CPUs + 8GB RAM droplet for faster testing
  r <- "tor1"
  s <- "s-4vcpu-8gb-intel"

  n <- paste("docker-test", gsub(":", "", gsub(".* ", "", Sys.time())), sep = "-")
  x <- docklet_create(n, region = r, size = s, image = "docker-20-04", wait = T)
  x <- droplet(x$id)

  # wait until all services load
  Sys.sleep(30)

  expect_output(docklet_pull(x, "rocker/tidyverse"))

  expect_silent(droplet_delete(x))
})
