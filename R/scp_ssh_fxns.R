scp_ssh <- function(file, ip, user='root', verbose){
  # remove known_hosts key
  mssg(verbose, "Removing known host if already present")
  system(sprintf('ssh-keygen -R %s', ip))
  scp(file, ip, user)
  ssh(file, ip, user)
}

scp <- function(file, ip, user='root'){
  scp_cmd <- sprintf('scp -o StrictHostKeyChecking=no %s %s@%s:~/', file, user, ip)
  system(scp_cmd)
}

scp_get <- function(file, ip, user='root', path){
  scp_cmd <- sprintf('scp -o StrictHostKeyChecking=no %s@%s:~/%s %s', user, ip, file, path)
  system(scp_cmd)
}

ssh <- function(file, ip, user='root'){
  ssh_cmd <- sprintf('ssh %s@%s "sh %s"', user, ip, file)
  system(ssh_cmd)
}
