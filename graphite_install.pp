# 
package { 'graphite-web':
  ensure => present,
}

package { 'python-carbon':
  ensure => present,
}

package { 'python-whisper':
  ensure => present,
}


## /usr/lib/python2.7/site-packages/graphite/settings.py

# This is the file that should be edited.
# /etc/graphite-web/local_settings.py
$szGraphiteLocalSettingFile = '/etc/graphite-web/local_settings.py'

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






# See also: https://github.com/miguno/puppet-graphite/blob/master/manifests/web/install.pp
# sudo python /usr/lib/python2.7/site-packages/graphite/manage.py syncdb
# sudo chown apache:apache /var/lib/graphite-web/graphite.db

service { 'carbon-aggregator':
  ensure => running,
  enable => true,
  require => Package[ 'python-carbon' ],
}

service { 'carbon-cache':
  ensure => running,
  enable => true,
  require => Package[ 'python-carbon' ],
}

file { '/etc/httpd/conf.d/graphite-web.conf':
  ensure => present,
  source => '/vagrant/graphite-web.conf',
  require => Package[ 'graphite-web' ],
  notify  => Service[ 'httpd' ],
}

exec { 'sync_django_db':
  command => 'python /usr/lib/python2.7/site-packages/graphite/manage.py syncdb --noinput',
  path    => '/usr/bin',  
  require => File_line['local_settings_secret_key','local_settings_email_host_user','local_settings_email_host_password'],
}

service { 'httpd':
  ensure => running,
  enable => true,
  require => Exec['sync_django_db'],
}
