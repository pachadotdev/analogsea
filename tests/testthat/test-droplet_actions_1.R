test_that("install R, R packages and user creation work (Ubuntu)", {
  skip_on_cran()

  # Create droplet ----

  # using 4 CPUs + 8GB RAM droplet for faster testing
  r <- "tor1"
  s <- "s-4vcpu-8gb-intel"
  img <- "ubuntu-20-04-x64"

  n <- paste("ubuntu-test", gsub(":", "", gsub(".* ", "", Sys.time())), sep = "-")
  x <- droplet_create(n, region = r, size = s, image = img, wait = T)
  x <- droplet(x$id)

  # Install R ----

  # wait until all services load
  Sys.sleep(30)

  expect_output(ubuntu_add_swap(x, keyfile = "~/.ssh/id_rsa"))
  expect_output(ubuntu_install_r(x, keyfile = "~/.ssh/id_rsa"))

  expect_equal(x$status, "active")
  expect_false(x$locked)

  # Install R packages ----

  # install eflm bc it has no deps besides base, quick test
  y <- install_r_package(x, "eflm", keyfile = "~/.ssh/id_rsa")
  expect_false(y$locked)
  expect_equal(y$status, "active")

  z <- install_github_r_package(x, "pachamaltese/eflm")
  expect_false(z$locked)
  expect_equal(z$status, "active")

  # Create users ----

  users <- list(
    user = paste0("student", 1:5),
    password = sapply(rep(8,5), create_password)
  )

  for (i in seq_along(users$user)) {
    expect_silent(
      ubuntu_create_user(x, users$user[i], users$password[i], keyfile = "~/.ssh/id_rsa")
    )
  }

  # Power off, on, reboot and delete ----

  expect_silent(droplet_power_off(x))
  expect_silent(droplet_power_on(x))
  expect_silent(droplet_reboot(x))

  expect_silent(droplet_delete(x))
})
