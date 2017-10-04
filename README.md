henk52-graphite
===============

Puppet manifest for Graphite


Installs graphite-web and carbon + whisper on Fedora 20.


## References
* https://github.com/graphite-project/graphite-web
* https://supermarket.chef.io/cookbooks/graphite
* https://docs.djangoproject.com/en/1.11/ref/django-admin/
* https://www.digitalocean.com/community/tutorials/how-to-install-and-use-graphite-on-an-ubuntu-14-04-server
* https://www.vultr.com/docs/how-to-install-and-configure-graphite-on-centos-7

# Installation

1. git clone https://github.com/henk52/henk52-graphite.git graphite
2. cd graphite
3. sudo  puppet apply requirements.pp
4. sudo puppet apply tests/init.pp

now you can point your browser at :80 and see the graphite content.


ls -l /var/lib/graphite-web/graphite.db
sudo tail /var/log/httpd/graphite-web-error.log

python /usr/share/graphite/graphite-web.wsgi
Is this missing: /var/lib/graphite-web/index


Where to look for troubleshooting information:
/opt/graphite/storage/error.log
/opt/graphite/storage/log/webapp/exception.log

# Troubleshooting

#### Error: Evaluation Error: Error while evaluating a Resource Statement, Invalid resource type file_line at graphite_install.pp:40:1
[cadm@f25dev henk52-graphite]$ sudo puppet apply graphite_install.pp

# Error: Evaluation Error: Error while evaluating a Function Call, Could not find class ::stdlib for XXX at graphite_install.pp:20:1 

ln -s /usr/share/puppet/modules/stdlib /etc/puppet/modules/stdlib


#### carbon-aggregator.service: Failed with result 'exit-code'.

Fix: added the file creation to manifests/init.pp

sudo systemctl status carbon-aggregator
● carbon-aggregator.service - Graphite Carbon Aggregator
   Loaded: loaded (/usr/lib/systemd/system/carbon-aggregator.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Tue 2017-09-26 07:29:18 CEST; 2min 17s ago

Sep 26 07:29:18 f25dev systemd[1]: Starting Graphite Carbon Aggregator...
Sep 26 07:29:18 f25dev carbon-aggregator[15625]: Starting carbon-aggregator (instance a)
Sep 26 07:29:18 f25dev carbon-aggregator[15625]: aggregation processor: file does not exist /etc/carbon/aggregation-rules.conf
Sep 26 07:29:18 f25dev systemd[1]: carbon-aggregator.service: Control process exited, code=exited status=1
Sep 26 07:29:18 f25dev systemd[1]: Failed to start Graphite Carbon Aggregator.
Sep 26 07:29:18 f25dev systemd[1]: carbon-aggregator.service: Unit entered failed state.
Sep 26 07:29:18 f25dev systemd[1]: carbon-aggregator.service: Failed with result 'exit-code'.


#### Notice: /Stage[main]/Graphite/Exec[sync_django_db]/returns: python: can't open file '/usr/lib/python2.7/site-packages/graphite/manage.py': [Errno 2] No such file or directory
Error: python /usr/lib/python2.7/site-packages/graphite/manage.py syncdb --noinput returned 2 instead of one of [0]
Error: /Stage[main]/Graphite/Exec[sync_django_db]/returns: change from notrun to 0 failed: python /usr/lib/python2.7/site-packages/graphite/manage.py syncdb --noinput returned 2 instead of one of [0]

https://github.com/graphite-project/graphite-web/issues/568
  python manage.py is equivalent to django-admin.py --settings=graphite.settings.

https://stackoverflow.com/questions/28444614/django-manage-py-unknown-command-syncdb
  syncdb command is deprecated in django 1.7. Use the python manage.py migrate instead.

#### OperationalError: no such table: account_profile
On the web browser...
Graphite encountered an unexpected error while handling your request.
https://github.com/graphite-project/graphite-web/issues/1929
  manage.py migrate --run-syncdb

sudo PYTHONPATH=/usr/share/graphite/webapp django-admin migrate  --run-syncdb --settings=graphite.settings
[sudo] password for cadm:
Operations to perform:
  Synchronize unmigrated apps: account, render, staticfiles, whitelist, metrics, url_shortener, dashboard, composer, events, browser
  Apply all migrations: admin, contenttypes, tagging, auth, sessions
Synchronizing apps without migrations:
  Creating tables...
    Creating table account_profile
    Creating table account_variable
    Creating table account_view
    Creating table account_window
    Creating table account_mygraph
    Creating table dashboard_dashboard
    Creating table dashboard_template
    Creating table events_event
    Creating table url_shortener_link
    Running deferred SQL...
Running migrations:
  No migrations to apply.

#### Graphite only has top banner
https://answers.launchpad.net/graphite/+question/262426

After enabling 'DEBUG = true' to the /etc/graphite-web/local_settings.py
then I saw errors of missing a '/static/' path.
So added 
    Alias /static/ "/usr/share/graphite/webapp/content/"
to
  graphite-web.conf
 and things now works.
