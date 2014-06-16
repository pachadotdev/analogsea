analogsea
=======

[![Build Status](https://api.travis-ci.org/sckott/analogsea.png)](https://travis-ci.org/sckott/analogsea)

A general purpose R interface to [Digital Ocean](https://www.digitalocean.com/)

### Digital Ocean info

+ [API v1 docs](https://developers.digitalocean.com/)
+ [API v2 docs](https://developers.digitalocean.com/v2/)

### v1 and v2

The version on the `master` branch holds code that works with the Digital Ocean API v1.

The `v2` branch holds code in development for Digital Ocean API v2.

### Quick start

__Install__

```coffee
devtools::install_github("sckott/analogsea")
library("analogsea")
```

__Authenticate__

Which in different scenarios asks for id and api key, or pulls from your `.Rprofile` file if you stored them there, or pulls from the R current session options if already stored in the current session.

```coffee
do_auth()
```

After you authenticate one during the session, you don't need to anymore - auth details are gathered automatically within each function.

You can also run `do_auth()` after authenticating to print your auth details.

__Get droplets__

All droplets

```coffee
droplets()
```

```coffee
$droplets
$droplets[[1]]
$droplets[[1]]$id
[1] 1746449

$droplets[[1]]$name
[1] "foo"

$droplets[[1]]$image_id
[1] 3240036

$droplets[[1]]$size_id
[1] 63

$droplets[[1]]$region_id
[1] 3

$droplets[[1]]$backups_active
[1] FALSE

$droplets[[1]]$ip_address
[1] "107.170.220.59"

$droplets[[1]]$private_ip_address
NULL

$droplets[[1]]$locked
[1] FALSE

$droplets[[1]]$status
[1] "off"

$droplets[[1]]$created_at
[1] "2014-05-29T23:51:12Z"


$droplets[[2]]
$droplets[[2]]$id
[1] 1746479

...cutoff
```

A single droplet. Pass in a list with details like above or a single droplet id.

```coffee
droplets(1746449)
# This does the same
# drops <- droplets()
# droplets(drops$droplets[[1]])
```

```coffee
$droplet
$droplet$id
[1] 1746449

$droplet$name
[1] "foo"

$droplet$image_id
[1] 3240036

$droplet$size_id
[1] 63

$droplet$region_id
[1] 3

$droplet$backups_active
[1] FALSE

$droplet$ip_address
[1] "107.170.220.59"

$droplet$private_ip_address
NULL

$droplet$locked
[1] FALSE

$droplet$status
[1] "off"

$droplet$created_at
[1] "2014-05-29T23:51:12Z"

$droplet$backups
list()

$droplet$snapshots
list()
```

__Spin up a new droplet__


Here, we're choosing the smallest droplet, least amount of RAM, smallest disk size, in San Francisco, and using my SSH key. You can alternatively use a password, but I prefer SSH keys.

```coffee
droplets_new(name="foo", size_slug = '512mb', image_slug = 'ubuntu-14-04-x64', region_slug = 'sfo1', ssh_key_ids = 89103)
```

```coffee
$droplet
$droplet$id
[1] 1746841

$droplet$name
[1] "foo"

$droplet$image_id
[1] 3240036

$droplet$size_id
[1] 66

$droplet$event_id
[1] 25390286
```

__Destroy a droplet__


```coffee
droplets_destroy(id=1746841)
```

```coffee
$event_id
[1] 25390323
```


__Install RStudio Server__


You of course have to have an active droplet to do this. Once you have one, pass in a droplet id.

```coffee
do_install(1746479, what='rstudio', usr='hey', pwd='there')
```

This will install R, RStudio Server and it's dependencies. It will automatically pop open the RStudio server instance in your default browser.
