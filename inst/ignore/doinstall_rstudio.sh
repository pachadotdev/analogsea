sudo apt-get install gdebi-core --yes --force-yes
sudo apt-get install libapparmor1 --yes --force-yes
wget http://download2.rstudio.org/rstudio-server-0.98.507-amd64.deb
sudo gdebi rstudio-server-0.98.507-amd64.deb --non-interactive
adduser scott2 --disabled-password --gecos ""
echo "scott2:scott2"|chpasswd
