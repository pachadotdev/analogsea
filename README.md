analogsea
=========

[![codecov.io](https://codecov.io/github/pachadotdev/analogsea/coverage.svg?branch=master)](https://codecov.io/github/pachadotdev/analogsea?branch=master)
[![rstudio mirror downloads](https://cranlogs.r-pkg.org/badges/analogsea)](https://github.com/r-hub/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/analogsea)](https://cran.r-project.org/package=analogsea)
[![R-CMD-check](https://github.com/pachadotdev/analogsea/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/pachadotdev/analogsea/actions/workflows/R-CMD-check.yml)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

<img src="https://raw.githubusercontent.com/pachadotdev/analogsea/main/inst/analogsea.svg" width=150 align="center" alt="sticker"/>

`analogsea` is an R client for version 2 of the Digital Ocean API.  See `?droplet_functions` after loading analogsea. It allows you to programatically create and destroy droplets (remote computers), and install various R related tools:

* R (done)
* RStudio Server (done)
* RStudio Shiny Server (done)
* OpenCPU (not yet)
* Use packrat to move a project to a droplet (not yet)

In addition, it allows you to use a readily available image with RStudio Server, Shiny Server and fully tidyverse from [DigitalOcean Marketplace](https://marketplace.digitalocean.com/apps/rstudio).

Docs: https://pacha.dev/analogsea/. 

## Use cases

- Andrew Heiss: [Create a cheap, disposable supercomputer with R, DigitalOcean, and future](https://www.andrewheiss.com/blog/2018/07/30/disposable-supercomputer-future/)

## Install

Stable version from CRAN

```r
install.packages("analogsea")
```

Development version from GitHub

```r
remotes::install_github("pachadotdev/analogsea")
```

```r
library("analogsea")
```

## Create a DO account

If you don't already have one, [create a DO account](https://m.do.co/c/6119f0430dad). By using this link, you'll start with $100 in credits with a 2 months limit. This is enough for 1440 hours of computing on a machine with 4 GB memory and 2 dedicated CPUs and additional hours to experiment with 1 GB memory machines. Thanks to DigitalOcean for covering the costs for testing!

## Authenticate

The best way to authenticate is to generate a personal access token (https://cloud.digitalocean.com/settings/tokens/new) and save it in an environment variable called `DO_PAT`. If you don't do this, you'll be prompted to authenticate in your browser the first time you use analogsea.

Make sure you provide digital ocean your public key at https://cloud.digitalocean.com/ssh_keys. Github has some good advice on creating a new public key if you don't already have one: https://help.github.com/articles/generating-ssh-keys/.

## Get droplets

All droplets

```r
droplets()
```

```r
<r> droplets()
$unintrenchable
<droplet>unintrenchable (2724525)
  Status: off
  Region: San Francisco 1
  Image: Ubuntu 14.04 x64
  Size: 512mb ($0.00744 / hr)

$basipterygium
<droplet>basipterygium (2724526)
  Status: active
  Region: San Francisco 1
  Image: Ubuntu 14.04 x64
  Size: 512mb ($0.00744 / hr)
```

A single droplet. Pass in a single droplet id.

```r
droplet(2724525)
```

```r
<droplet>unintrenchable (2724525)
  Status: off
  Region: San Francisco 1
  Image: Ubuntu 14.04 x64
  Size: 512mb ($0.00744 / hr)
```

## Spin up a new droplet

To make this as dead simple as possible, you just use one function, without any parameters.

```r
droplet_create()
```

```r
Using default ssh key: Jane Doe
NB: This costs $0.00744 / hour  until you droplet_delete() it
<droplet>sabaoth (2727258)
  Status: new
  Region: San Francisco 1
  Image: Ubuntu 14.04 x64
  Size: 512mb ($0.00744 / hr)
```

You can of course pass in lots of options for name of the droplet, RAM size, disk size, ssh keys, etc.  See `regions()` and `sizes()` to list available regions and sizes.

### Delete a droplet

```r
droplet_delete(1707487)
```

## Chaining

Most of the `droplet_*` functions can be chained together using the `%>%` function. For example, you can turn a droplet off, snapshot, and then turn it back on with:

```r
d %>%
   droplet_power_off() %>%
   droplet_snapshot() %>%
   droplet_power_on() %>%
```

## R/RStudio

*We're still working on these, but would love feedback.*

By default, `analogsea` creates an Ubuntu 20.04 image. Let's say you've got ten students from an R workshop, then you can run

```r
droplet_create("rstudio-20-04")

users <- list(
  user = paste0("student", 1:5),
  password = sapply(rep(8,5), create_password)
)
  
for (i in seq_along(users$user)) {
  ubuntu_create_user(x, users$user[i], users$password[i], keyfile = "~/.ssh/id_rsa")
}
```

Then, each student shall be able to open RStudio from the browser, by visiting http://123.456.789:8787 and accessing with studentX (X = 1,...,10) and the password created.

To install more R packages, you can make them readily available for all the users that have access to your droplet with

```r
ubuntu_install_r() # ohlf if you didn't use the RStudio image
install_r_package("arrow")
```

## Shiny

The RStudio Server image also features readily available Shiny Server, but we provide the functions `ubuntu_install_shiny()` and `docklet_shinyserver()` (requires to use the Docker image, i.e. `docklet_create()`) to configure Shiny from scratch.

## Install RStudio Server

For the standard Ubuntu image you can use `ubuntu_install_rstudio()`.

For dockerized RStudio you have the next option:

```r
docklet_create() %>%
  docklet_rstudio()
```

This will install R, RStudio Server and it's dependencies. It will automatically pop open the RStudio server instance in your default browser, with default `username/password` of `rstudio/server`.


## Meta

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/pachadotdev/analogsea/blob/master/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
