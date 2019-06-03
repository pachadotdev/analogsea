analogsea 0.7.0
===============

### NEW FEATURES

* Now using package `ssh` to do ssh operations instead of shelling out via `system`/etc. (#143) (#160) & various fixes for ssh (#154)
* New functions for working with DO certificates API routes: `certificate`, `certificate_create`, `certificate_delete`, `certificates`, and `as.certificate` (#156)
* New functions for working with DO firewalls API routes: `firewall`, `firewall_add_droplets`, `firewall_add_tags`, `firewall_create`, `firewall_delete`, `firewall_remove_droplets`, `firewall_remove_tags`, `firewall_update`, `firewalls`, and `as.firewall` (#157)

### MINOR IMPROVEMENTS

* Changed default droplet size from "1gb" to "s-1vcpu-2gb" (#149) (#152)
* Changed default droplet image from "ubuntu-14-04-x64" (Ubuntu 14) to "ubuntu-18-04-x64" (Ubuntu 18) (#151)
* fix `docklet_create()` to use by default the image "docker-18-04" instead of "docker" (#174)
* Add more documentation for how to deal with droplet object not have the IP address. Happens when the DO API tells R that the droplet is up, but they haven't given us the IP address yet (#166)
* Package gains new manual page `?droplet_functions` to help the user navigate the many functions for working with the DO API
* `droplet_ssh` gains new parameters `keyfile` and `ssh_passwd` for specifying the user's optional private key file, and the optional passphrase or callback function for authentication

### BUG FIXES

* fix to user and password params for `docklet_rstudio()`: at first thanks @nielsaka for (#170) (#171) but then we decided better to go with (#172) and make both params required with no default so the user is forced to set their own values
* Change default value for `ssh_keys` param in `droplet_create()` and related functions to `NULL` (#144)


analogsea 0.6.0
===============

### NEW FEATURES

* `as.key` function changed to `as.sshkey` to avoid collision with `openssl`
package (#126)
* Gains new functions `domain_record_update` to update a domain record
and `domain_record` to get a domain record by id (#124)
* `domain_record_create` gains paramater `ttl` for time to live for the
domain record, in seconds (#124)

### MINOR IMPROVEMENTS

* Fixed some typos (#131) thanks @patperu
* `docklet_rstudio`, `docklet_shinyserver`, and `docklet_shinyapp`
now return a droplet instead of a URL so they can be piped - docs
now contain how to construct the URL for the rstudio or shiny server
instance in case user sets `browse = FALSE` (#134)
* `domain_record_create` and `domain_record_update` gain parameters
`flags` and `tag` for CAA support for Domain Record resources (#137)
* `docklet_images` gets an `all` param, with default value of
`TRUE` (#135)
* Added examples to docs for how to install specific R versions
easily with docker, see `?docklet_create` (#106)

### BUG FIXES

* Fix to `droplet_create`: it couldn't generate a random name without
first loading the package via `library` (#125) thanks @trestletech
* `debian_add_swap` adds swap memory, but was not persisted across
reboots. fixed now (#127) thanks @trestletech
* In `droplet_create`, the parameters `ssh_keys` and `tags` now default
to `list()` instead of `NULL` as they path pass to `I()` that warns
now on `NULL` (#129)

### DEPRECATED AND DEFUNCT

* `tag_rename` is now defunct as is you can no longer rename tags (#123)


analogsea 0.5.0
===============

### NEW FEATURES

* New function `docklets_create()` to create many docklets at once
(similar to `droplets_create()`)  (#120)
* New volumes methods for the new block storage (aka volumes)
<https://www.digitalocean.com/products/storage/>: `volume`, `volume_action`,
`volume_actions`, `volume_attach`, `volume_create`, `volume_delete`, `volume_detach`,
`volume_resize`, `volume_snapshot_create`, `volume_snapshots`, `volumes`,
`as.volume` (#121)
* New methods for new unified snapshots DO endpoints: `snapshot`,
`snapshots`, `snapshot_delete`, and `as.shapshot` (#121)

### MINOR IMPROVEMENTS

* You can now pass `tags` to the parameter of the same name when creating
droplets, with either `droplet_create`, `droplets_create`,
`docklet_create`, or `docklets_create`. The tags can be existing ones,
or if not they will be created (#122)
* Added more help on ssh keys to pkg level man file and to vignette (#115)


analogsea 0.4.0
===============

### NEW FEATURES

* Suite of new functions for tags: `tag()`, `tag_create()`,
`tag_delete()`, `tag_rename()`, `tag_resource()`,
`tag_resource_delete()`, `tags()`, and `as.tag()` (#117)
* Related to last bulllet: `droplet_delete()` gains new parameter `tag`;
`droplets()` gains new parameter `tag`, and examples added to its man file
for tag usage.
* New functions `docklet_shinyserver()` and `docklet_shinyapp()`
to spin up Shiny server and a Shiny app, respectively. (#100)
* New function `droplet_enable_backups()` (#110)
* New function `droplets_create()` to create many droplets at once (#112)
* New function `droplets_cost()` to calculate cost of droplets across
one or more droplets.

### MINOR IMPROVEMENTS

* Added `floating_ip_limit` field to `account()` print method (#111)
* Improved description of `name` parameter for `droplet_create()` and
`docklet_create()`

### BUG FIXES

* Fixed problem with `docklet_create()` when port 22 is not open
before further action is taken on the droplet. We now check if
port 22 is open and error with informative message about waiting
a bit for it to open (#113) thanks @fmichonneau @hrbrmstr
* Fixed problem in the `print.droplet` due to problem in `droplet_ip()` internal function (#109)
* Fix to `*_create` to allow flexibility in how often DO API is pinged.
Previously we pinged every second, meaning you could hit your API rate limit
fastish. Now you can set an option `do.wait_time` to tweak time
bewtween pings to check for droplet creation (or other actions).
See <https://github.com/sckott/analogsea/issues/108#issuecomment-151519855>
for example of doing droplet creation in parallel. (#108) thanks @simecek !
* Fixed parsing bug in `sizes()` (#119)

analogsea 0.3.0
===============

### NEW FEATURES

* Released to CRAN.
