class graphite {
  include stdlib
# 
# operatingsystem: Ubuntu / 
# osfamily: Debian /
if ( $osfamily == 'Debian' ) {
  $szCarbonPkg = 'graphite-carbon'
  $szGraphiteWebCfgDir = '/etc/graphite'
  $szWebConfDir = '/etc/apache2/conf-available'
  $szPathToManagePy = '/usr/lib/python2.7/dist-packages/graphite'
  $szPathToGraphiteDb = '/var/lib/graphite/graphite.db'
  $szHttpdServiceName = 'apache2'
  $szHttpdPackageName = 'apache2'
} else {
  $szCarbonPkg = 'python-carbon'
  $szGraphiteWebCfgDir = '/etc/graphite-web'
  $szWebConfDir = '/etc/httpd/conf.d'
  $szPathToManagePy = '/usr/lib/python2.7/site-packages/graphite'
  $szPathToGraphiteDb = '/var/lib/graphite-web/graphite.db'
  $szHttpdServiceName = 'httpd'
  $szHttpdPackageName = 'httpd'
}

package { 'graphite-web':
  ensure => present,
}

package { "$szCarbonPkg":
  ensure => present,
}

package { 'python-whisper':
  ensure => present,
}


## /usr/lib/python2.7/site-packages/graphite/settings.py

# This is the file that should be edited.
# /etc/graphite-web/local_settings.py
$szGraphiteLocalSettingFile = "$szGraphiteWebCfgDir/local_settings.py"

#SECRET_KEY = 'UNSAFE_DEFAULT'
file_line { 'local_settings_secret_key':
  ensure => present,
  line   => "SECRET_KEY = 'WhatIsThisSecretKeyUsedFor'",
  path   => "$szGraphiteLocalSettingFile",
  require => Package[ 'graphite-web' ],
}


#EMAIL_HOST_USER = ''
file_line { 'local_settings_email_host_user':
  ensure => present,
  line   => "EMAIL_HOST_USER = 'root'",
  path   => "$szGraphiteLocalSettingFile",
  require => Package[ 'graphite-web' ],
}

#EMAIL_HOST_PASSWORD = ''
file_line { 'local_settings_email_host_password':
  ensure => present,
  line   => "EMAIL_HOST_PASSWORD = 'SuperSecret'",
  path   => "$szGraphiteLocalSettingFile",
  require => Package[ 'graphite-web' ],
}



file { '/etc/carbon/storage-schemas.conf':
  ensure => present,
  content => "# from henk52-graphite.\n[performance_date]\npattern=.*\nretentions = 5s:7d,1m:30d,15m:1y",
  require => Package[ "$szCarbonPkg" ],
}

file_line { 'MAX_CREATES_PER_MINUTE':
  ensure => present,
  line    => "MAX_CREATES_PER_MINUTE = 8000",
  match   => "^MAX_CREATES_PER_MINUTE =*",
  path    => '/etc/carbon/carbon.conf',
  require => Package[ "$szCarbonPkg" ],
  notify  => Service["carbon-cache"],
}

file_line { 'MAX_UPDATES_PER_SECOND':
  ensure => present,
  line    => "MAX_UPDATES_PER_SECOND = 45000",
  match   => "^MAX_UPDATES_PER_SECOND =*",
  path    => '/etc/carbon/carbon.conf',
  require => Package[ "$szCarbonPkg" ],
  notify  => Service["carbon-cache"],
}




# See also: https://github.com/miguno/puppet-graphite/blob/master/manifests/web/install.pp
# sudo python /usr/lib/python2.7/site-packages/graphite/manage.py syncdb
# sudo chown apache:apache /var/lib/graphite-web/graphite.db

# it seems the Ubuntu does not have this.
if ( $osfamily == 'Debian' ) {
  file { '/etc/carbon/aggregation-rules.conf':
    ensure => present,
    source => '/usr/share/doc/graphite-carbon/examples/aggregation-rules.conf.example',
    require => Package[ "$szCarbonPkg" ],
#    notify  => Service['carbon-aggregator'],
  }

# for raspberrypi this fails.
#  service { 'carbon-aggregator':
#    ensure => running,
#    enable => true,
#    require => File['/etc/carbon/aggregation-rules.conf'],
#  #  require => Package[ "$szCarbonPkg" ],
#  }
} else {
  file { '/etc/carbon/aggregation-rules.conf':
    source => '/usr/share/doc/python2-carbon/conf/aggregation-rules.conf.example',
    ensure => present,
    require => Package[ "$szCarbonPkg" ],
    notify  => Service['carbon-aggregator'],
  }

  service { 'carbon-aggregator':
    ensure => running,
    enable => true,
    require => File['/etc/carbon/aggregation-rules.conf'],
  #  require => Package[ "$szCarbonPkg" ],
  }
}

service { 'carbon-cache':
  ensure => running,
  enable => true,
  require => File['/etc/carbon/storage-schemas.conf'],
#  require => Package[ "$szCarbonPkg" ],
}

file { "$szWebConfDir/graphite-web.conf":
  ensure => present,
  source => '/etc/puppet/code/modules/graphite/graphite-web.conf',
  require => Package[ 'graphite-web' ],
  notify  => Service[ "$szHttpdServiceName" ],
}

if (  $osfamily != 'Debian' ) {
  $arDjangoDependServiceList = ['carbon-cache','carbon-aggregator']
} else {
  $arDjangoDependServiceList = 'carbon-cache'
}



#file { '/var/lib/graphite-web/index':

# TODO figure out what this acutally creates, because running this(even when it fails, then it mean it works.
#exec { 'some_run':
#  command => 'python /usr/share/graphite/graphite-web.wsgi',
#  path    => '/usr/bin',  
#  user    => 'apache',
#  require => Exec['sync_django_db'], 
#}

# /var/lib/graphite-web/graphite.db
#  https://www.vultr.com/docs/how-to-install-and-configure-graphite-on-centos-7
#    PYTHONPATH=/usr/share/graphite/webapp django-admin migrate --settings=graphite.settings
#  command => "django-admin migrate   --run-syncdb  --settings=graphite.settings; chown apache:apache $szPathToGraphiteDb",
#  creates => "$szPathToGraphiteDb",
exec { 'sync_django_db':
  command => "django-admin migrate   --run-syncdb  --settings=graphite.settings",
  environment => ['PYTHONPATH=/usr/share/graphite/webapp'],
  path    => ['/usr/bin','/bin'],
  creates => '/home',
  user    => 'apache',
  require => [ 
               File_line['local_settings_secret_key','local_settings_email_host_user','local_settings_email_host_password'],
               Package['graphite-web'],
               Service["$arDjangoDependServiceList"],
# This only works for RedHat family.
#               Service['carbon-cache','carbon-aggregator'],
             ],
}

package { "$szHttpdPackageName":
  ensure => present,
}

#
if ( $osfamily == 'Debian' ) {
  # See https://www.digitalocean.com/community/tutorials/how-to-install-and-use-graphite-on-an-ubuntu-14-04-server
  package { 'libapache2-mod-wsgi':
    ensure => present,
  }
  # TODO sudo a2dissite 000-default
  file { '/etc/apache2/sites-enabled/000-default.conf':
    ensure => absent,
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  file { '/etc/apache2/sites-available/apache2-graphite.conf':
    ensure => present,
    source => '/usr/share/graphite-web/apache2-graphite.conf',
    require => Package['apache2'],
  }
  # sudo a2ensite apache2-graphite
  file { '/etc/apache2/sites-enabled/apache2-graphite.conf':
    ensure => link,
    target => '../sites-available/apache2-graphite.conf',
    require => [Package['apache2'],File['/etc/apache2/sites-available/apache2-graphite.conf']],
    notify  => Service['apache2'],
  }
  service { 'apache2':
    ensure => running,
    enable => true,
    require => [
                 Exec['sync_django_db'],
                 Package['apache2','libapache2-mod-wsgi'],
               ],
  }
} else {
  file { '/etc/httpd/conf.d/welcome.conf':
    ensure => present,
    content => '# Disabled for graphite',
    require => Package["$szHttpdPackageName"],
    notify  => Service["$szHttpdServiceName"],
  }

  
  service { "$szHttpdServiceName":
    ensure => running,
    enable => true,
    require => Exec['sync_django_db'],
#  require => [ Exec['sync_django_db'], File['/var/lib/graphite-web/index'] ],
  }
}

 # TODO maybe create /var/lib/graphite-web/index file, owned by apache.
}
