name = random_name()
size = getOption("do_size", "s-1vcpu-1gb")
image = getOption("do_image", "ubuntu-22-04-x64")
region = getOption("do_region", "sfo3")
ssh_keys = getOption("do_ssh_keys", NULL)
backups = getOption("do_backups", NULL)
ipv6 = getOption("do_ipv6", NULL)
private_networking = getOption("do_private_networking", NULL)
tags = list()
user_data = NULL
cloud_config = NULL
wait = TRUE