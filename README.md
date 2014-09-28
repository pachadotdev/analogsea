analogsea
=======

[![Build Status](https://api.travis-ci.org/sckott/analogsea.png?branch=master)](https://travis-ci.org/sckott/analogsea)
[![Build status](https://ci.appveyor.com/api/projects/status/ll9lcqafuw338q0h/branch/master)](https://ci.appveyor.com/project/sckott/analogsea/branch/master)

`analogsea` is an R client for the [Digital Ocean](https://www.digitalocean.com/) API. The Digital Ocean v2 API is nearly fully implemented in the `master` branch.

As this in an R package, `analogsea` will include ability to install various R things on DO droplets (we're still ironing out these functions):

* R
* RStudio Server
* RStudio Shiny Server
* OpenCPU
* Use packrat to move a project to a droplet
* and more

## Don't have a Digital Ocean account yet?

If you don't mind, sign up for an account by clicking on this link -> [https://www.digitalocean.com/?refcode=0740f5169634](https://www.digitalocean.com/?refcode=0740f5169634) - and we can get some DO credits to offset our costs for testing the package. Thanks :)

## Digital Ocean API

+ [API v2 docs](https://developers.digitalocean.com/v2/)
+ The `master` branch of `analogsea` now works with the DO `v2` API.

## Quick start

### Install

> <2014-09-28> Beware: we're in the middle of a redo of the package...do let us know of any bugs or feature requests

```r
devtools::install_github("sckott/analogsea")
library("analogsea")
```

### Authenticate

DigitalOcean uses OAuth 2. If `do_oauth()` runs succesfully, your token object is returned and cached, which will be called in other functions in this package. You don't have to authenticate as a separate step - if you use a function it will check for authentication details and do auth if you haven't already.

<!--
* Login to your Digital Ocean account. Go to _Apps & API_ page.
* In the _Developer Applications_ part of the page, press button for _Register new application_. Then enter app details:
  * _Application name:_ anything is fine
  * _Application homepage:_ anything is fine, this more used for web oauth flows.
  * _Application description:_ give a note to yourself what this app is.
  * _Application callback URL:_ use http://localhost:1410
* Once the app is registered, you can enter your appname, client id, and client secret as parameters to `do_oauth()`, or store them in your `.Rprofile` file as `do_appname`, `do_client_id`, and `do_client_secret`, respectively.
-->

### Get droplets

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

### Spin up a new droplet

To make this as dead simple as possible, you just use one function, without any parameters.

```r
droplet_new()
```

```r
Using default ssh key: Scott Chamberlain
NB: This costs $0.00744 / hour  until you droplete_delete() it
<droplet>sabaoth (2727258)
  Status: new
  Region: San Francisco 1
  Image: Ubuntu 14.04 x64
  Size: 512mb ($0.00744 / hr)
```


Alternatively, you can of course pass in lots of options for name of the droplet, RAM size, disk size, ssh keys, etc.

I strongly suggest using SSH keys.

```r
droplet_new(name="foo", size = '512mb', image = 'ubuntu-14-04-x64', region = 'sfo1', ssh_keys = 89103)
```


#### Delete a droplet


```r
droplet_delete(1707487)
```

doesn't print anything if succesful

#### Regions, and their details

```r
regions()
```

```r
$regions
$regions[[1]]
$regions[[1]]$slug
[1] "nyc1"

$regions[[1]]$name
[1] "New York 1"

$regions[[1]]$sizes
list()

$regions[[1]]$available
[1] FALSE

$regions[[1]]$features
$regions[[1]]$features[[1]]
[1] "virtio"

$regions[[1]]$features[[2]]
[1] "backups"

...cutoff
```

### RAM and disk sizes, and their details

```r
sizes()
```

```r
$sizes
$sizes[[1]]
$sizes[[1]]$slug
[1] "512mb"

$sizes[[1]]$memory
[1] 512

$sizes[[1]]$vcpus
[1] 1

$sizes[[1]]$disk
[1] 20

$sizes[[1]]$transfer
[1] 1

$sizes[[1]]$price_monthly
[1] 5

$sizes[[1]]$price_hourly
[1] 0.00744

...cutoff
```

### Chaining

Most of the `droplet_*` functions can be chained together using the `%>%` function.

For example, you can spin up a new droplet, then list your droplets

```r
droplet_new() %>%
  droplets_rename(name='mycoolnewname')
# output not shown
```

List the actions taken on a particular droplet

```r
droplets()[[1]] %>%
  droplet_actions
```

```r
[[1]]
<action> create (33365954)
  Status: completed
  Resource: droplet 2727258
```

Notice that you can't pass more than one droplet to other `droplet_*`.


## R

We're still working on these, but would love feedback.

### Install RStudio Server

You of course have to have an active droplet to do this. Once you have one, pass in a droplet id.

```r
do_install(1746479, what='rstudio_server')
```

This will install R, RStudio Server and it's dependencies. It will automatically pop open the RStudio server instance in your default browser, with default `username/password` of `rstudio/rstudio`.

Other options include:

* Install R using `what='r'`
* Install RStudio Shiny Server using `what='shiny_server'`
* Install common dependencies, e.g. `deps=c('curl','xml')`
* Install OpenCPU using `what='opencpu'` __not working yet__
