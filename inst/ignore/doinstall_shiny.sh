sudo su - \
    -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
sudo apt-get install gdebi-core --yes --force-yes
wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.1.0.10000-amd64.deb
sudo gdebi shiny-server-1.1.0.10000-amd64.deb --non-interactive
