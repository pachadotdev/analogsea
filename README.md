analogsea
=======

master branch: [![Build Status](https://api.travis-ci.org/sckott/analogsea.png?branch=master)](https://travis-ci.org/sckott/analogsea)
[![Build status](https://ci.appveyor.com/api/projects/status/ll9lcqafuw338q0h/branch/master)](https://ci.appveyor.com/project/sckott/analogsea/branch/master)

v2 branch: [![Build Status](https://api.travis-ci.org/sckott/analogsea.png?branch=v2)](https://travis-ci.org/sckott/analogsea)
[![Build status](https://ci.appveyor.com/api/projects/status/ll9lcqafuw338q0h/branch/v2)](https://ci.appveyor.com/project/sckott/analogsea/branch/v2)

`analogsea` is a general purpose R interface to the [Digital Ocean](https://www.digitalocean.com/) API, AND includes scripts to install various R things:

* R
* RStudio Server
* RStudio Shiny Server
* OpenCPU

The Digital Ocean v2 API is fully implemented, but we're still working on the installation scripts...

## Digital Ocean API

+ [API v1 docs](https://developers.digitalocean.com/)
+ [API v2 docs](https://developers.digitalocean.com/v2/)

### v1 and v2

The version on the `master` branch holds code that works with the Digital Ocean API v1.

The `v2` branch holds code in development for Digital Ocean API v2.

## Quick start

### Install

```coffee
devtools::install_github("sckott/analogsea", ref="v2")
library("analogsea")
```

### Authenticate

DigitalOcean uses OAuth, but we don't do the song and dance you may be used to. We send a bearer authorization header with each request to the DO API. This is a preferred method of authenticating because it completes the authorization request in the header portion, away from the actual request.

You can generate an OAuth token by visiting the [Apps & API](https://cloud.digitalocean.com/settings/applications) section of the DigitalOcean control panel for your account.

Which if you haven't authenticated yet will look for your OAuth token in your `.Rprofile` file, or in options for the current R session, and if not found, will ask you for the token, which will only be saved for the current R session. Ideally you put your OAuth token in your `.Rprofile` file, which makes sure it's not shared with others, and so that you don't have to enter any auth details every time you use this package.

```coffee
do_auth()
```

After you authenticate one during the session, you don't need to anymore - auth details are gathered automatically within each function.

You can also run `do_auth()` after authenticating to print your auth details.

### Get droplets

All droplets

```coffee
droplets()
```

```coffee
$meta
$meta$total
[1] 3


$droplet_ids
[1] 2435583 2435584 2435586

$droplets
$droplets$data
       id         name memory vcpus disk locked status           created_at region            image
1 2435583     feminist    512     1   20   TRUE    new 2014-08-23T22:10:21Z   sfo1 Ubuntu 14.04 x64
2 2435584 cellulomonas    512     1   20   TRUE    new 2014-08-23T22:10:24Z   sfo1 Ubuntu 14.04 x64
3 2435586 singlehanded    512     1   20   TRUE    new 2014-08-23T22:10:27Z   sfo1 Ubuntu 14.04 x64

$droplets$details
       id region_slug     region_name region_available                              region_sizes region_features image_id image_distribution       image_slug
1 2435583        sfo1 San Francisco 1             TRUE 2gb,4gb,8gb,1gb,16gb,32gb,48gb,512mb,64gb  virtio,backups  5141286             Ubuntu ubuntu-14-04-x64
2 2435584        sfo1 San Francisco 1             TRUE 2gb,4gb,8gb,1gb,16gb,32gb,48gb,512mb,64gb  virtio,backups  5141286             Ubuntu ubuntu-14-04-x64
3 2435586        sfo1 San Francisco 1             TRUE 2gb,4gb,8gb,1gb,16gb,32gb,48gb,512mb,64gb  virtio,backups  5141286             Ubuntu ubuntu-14-04-x64
  image_public                           image_regions     image_created_at
1         TRUE nyc1,ams1,sfo1,nyc2,ams2,sgp1,lon1,nyc3 2014-07-23T17:08:52Z
2         TRUE nyc1,ams1,sfo1,nyc2,ams2,sgp1,lon1,nyc3 2014-07-23T17:08:52Z
3         TRUE nyc1,ams1,sfo1,nyc2,ams2,sgp1,lon1,nyc3 2014-07-23T17:08:52Z
                                                                                                                                                                                                                  image_action_ids
1 29202525,29203474,29204856,29204858,29204860,29204863,29204865,29204868,29209875,29209878,29209902,29209919,29209926,29209929,29209954,29209962,29209964,29209966,29209997,29209999,29210003,29210022,29210030,29210127,29210135
2 29202525,29203474,29204856,29204858,29204860,29204863,29204865,29204868,29209875,29209878,29209902,29209919,29209926,29209929,29209954,29209962,29209964,29209966,29209997,29209999,29210003,29210022,29210030,29210127,29210135
3 29202525,29203474,29204856,29204858,29204860,29204863,29204865,29204868,29209875,29209878,29209902,29209919,29209926,29209929,29209954,29209962,29209964,29209966,29209997,29209999,29210003,29210022,29210030,29210127,29210135
  size_slug size_transfer size_price_monthly size_price_hourly networks_.id networks_ip_address networks_netmask networks_gateway networks_type kernel_id
1     512mb             1                  5           0.00744           v4     107.170.229.251    255.255.255.0    107.170.229.1        public      1682
2     512mb             1                  5           0.00744           v4     198.199.113.180    255.255.255.0    198.199.113.1        public      1682
3     512mb             1                  5           0.00744           v4     192.241.235.225    255.255.255.0    192.241.235.1        public      1682
                                   kernel_name    kernel_version backup_ids snapshot_ids action_ids
1 * Ubuntu 14.04 x64 vmlinuz-3.13.0-32-generic 3.13.0-32-generic         NA           NA   31285248
2 * Ubuntu 14.04 x64 vmlinuz-3.13.0-32-generic 3.13.0-32-generic         NA           NA   31285250
3 * Ubuntu 14.04 x64 vmlinuz-3.13.0-32-generic 3.13.0-32-generic         NA           NA   31285256


$actions
$actions$id
NULL


$links
NULL
```

A single droplet. Pass in a list with details like above or a single droplet id.

```coffee
droplets(2435586)
```

```coffee
$meta
NULL

$droplet_ids
[1] 2435586

$droplets
$droplets$data
       id         name memory vcpus disk locked status           created_at region            image
1 2435586 singlehanded    512     1   20   TRUE    new 2014-08-23T22:10:27Z   sfo1 Ubuntu 14.04 x64

$droplets$details
       id region_slug     region_name region_available                              region_sizes region_features image_id image_distribution       image_slug
1 2435586        sfo1 San Francisco 1             TRUE 2gb,4gb,8gb,1gb,16gb,32gb,48gb,512mb,64gb  virtio,backups  5141286             Ubuntu ubuntu-14-04-x64
  image_public                           image_regions     image_created_at
1         TRUE nyc1,ams1,sfo1,nyc2,ams2,sgp1,lon1,nyc3 2014-07-23T17:08:52Z
                                                                                                                                                                                                                  image_action_ids
1 29202525,29203474,29204856,29204858,29204860,29204863,29204865,29204868,29209875,29209878,29209902,29209919,29209926,29209929,29209954,29209962,29209964,29209966,29209997,29209999,29210003,29210022,29210030,29210127,29210135
  size_slug size_transfer size_price_monthly size_price_hourly networks_.id networks_ip_address networks_netmask networks_gateway networks_type kernel_id
1     512mb             1                  5           0.00744           v4     192.241.235.225    255.255.255.0    192.241.235.1        public      1682
                                   kernel_name    kernel_version backup_ids snapshot_ids action_ids
1 * Ubuntu 14.04 x64 vmlinuz-3.13.0-32-generic 3.13.0-32-generic         NA           NA   31285256


$actions
$actions$id
[1] 31285256


$links
NULL
```

### Spin up a new droplet

To make this as dead simple as possible, you just use one function, without any parameters.

```coffee
droplets_new()
```

```coffee
$droplet
$droplet$id
[1] 2435596

$droplet$name
[1] "copable"

$droplet$memory
[1] 512

$droplet$vcpus
[1] 1

$droplet$disk
[1] 20

$droplet$region
$droplet$region$slug
[1] "sfo1"

$droplet$region$name
[1] "San Francisco 1"

$droplet$region$sizes
[1] "2gb"   "4gb"   "8gb"   "1gb"   "16gb"  "32gb"  "48gb"  "512mb" "64gb"

$droplet$region$available
[1] TRUE

$droplet$region$features
[1] "virtio"  "backups"


...cutoff
```


Alternatively, you can of course pass in lots of options for name of the droplet, RAM size, disk size, ssh keys, etc.

I strongly suggest using SSH keys.

```coffee
droplets_new(name="foo", size = '512mb', image = 'ubuntu-14-04-x64', region = 'sfo1', ssh_keys = 89103)
```


#### Delete a droplet


```coffee
droplets_delete(1707487)
```

```coffee
success: (204) No Content
```

#### Regions, and their details

```coffee
regions()
```

```coffee
$regions
  slug            name                                             sizes available                                  features
1 nyc1      New York 1                                                       FALSE                           virtio, backups
2 ams1     Amsterdam 1                                                       FALSE                           virtio, backups
3 sfo1 San Francisco 1 2gb, 4gb, 8gb, 1gb, 16gb, 32gb, 48gb, 512mb, 64gb      TRUE                           virtio, backups
4 nyc2      New York 2 1gb, 2gb, 4gb, 8gb, 32gb, 64gb, 512mb, 16gb, 48gb      TRUE       virtio, private_networking, backups
5 ams2     Amsterdam 2 512mb, 1gb, 2gb, 4gb, 8gb, 32gb, 48gb, 64gb, 16gb      TRUE       virtio, private_networking, backups
6 sgp1     Singapore 1 1gb, 512mb, 2gb, 4gb, 8gb, 16gb, 32gb, 48gb, 64gb      TRUE virtio, private_networking, backups, ipv6
7 lon1        London 1 512mb, 1gb, 2gb, 4gb, 8gb, 16gb, 32gb, 48gb, 64gb      TRUE virtio, private_networking, backups, ipv6
8 nyc3      New York 3 512mb, 1gb, 2gb, 4gb, 8gb, 16gb, 32gb, 48gb, 64gb      TRUE virtio, private_networking, backups, ipv6

$meta
$meta$total
[1] 8
```

### RAM and disk sizes, and their details

```coffee
sizes()
```

```coffee
$sizes
   slug memory vcpus disk transfer price_monthly price_hourly                                        regions
1 512mb    512     1   20        1             5      0.00744 nyc1, sgp1, ams1, ams2, sfo1, nyc2, lon1, nyc3
2   1gb   1024     1   30        2            10      0.01488 nyc1, nyc2, sgp1, ams1, sfo1, ams2, lon1, nyc3
3   2gb   2048     2   40        3            20      0.02976 nyc1, nyc2, sfo1, ams1, sgp1, ams2, lon1, nyc3
4   4gb   4096     2   60        4            40      0.05952 nyc2, sfo1, ams1, sgp1, ams2, nyc1, lon1, nyc3
5   8gb   8192     4   80        5            80      0.11905 nyc2, sfo1, sgp1, ams1, ams2, nyc1, lon1, nyc3
6  16gb  16384     8  160        6           160      0.23810       sgp1, nyc1, sfo1, lon1, ams2, nyc3, nyc2
7  32gb  32768    12  320        7           320      0.47619       nyc2, sgp1, ams2, nyc1, sfo1, lon1, nyc3
8  48gb  49152    16  480        8           480      0.71429       sgp1, ams2, sfo1, nyc1, lon1, nyc3, nyc2
9  64gb  65536    20  640        9           640      0.95238       sgp1, ams2, nyc1, nyc2, sfo1, lon1, nyc3

$meta
$meta$total
[1] 9
```

### Chaining

Most of the `droplets_*` functions are meant to be chained together using the `%>%` operator.

For example, you can list your droplets, then 

```r

```

```r
xxx
```

### Install RStudio Server


__BEWARE:__ I'm working on updating these scripts so that it all actually works...hold on a bit...

You of course have to have an active droplet to do this. Once you have one, pass in a droplet id.

```coffee
do_install(1746479, what='rstudio', usr='hey', pwd='there')
```

This will install R, RStudio Server and it's dependencies. It will automatically pop open the RStudio server instance in your default browser.
