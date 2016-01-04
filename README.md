henk52-graphite
===============

Puppet manifest for Graphite


Installs graphite-web and carbon + whisper on Fedora 20.

sudo puppet apply graphite_install.pp
sudo service httpd restart



ls -l /var/lib/graphite-web/graphite.db
sudo tail /var/log/httpd/graphite-web-error.log

python /usr/share/graphite/graphite-web.wsgi
Is this missing: /var/lib/graphite-web/index
