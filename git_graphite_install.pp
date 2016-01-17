# Validate graphite-web have what it needs: ./check-dependencies.py

# Error log ? /opt/graphite/storage/error.log

#  $szPathToManagePy = '/usr/lib/python2.7/site-packages/graphite'
#  $szPathToGraphiteDb = '/var/lib/graphite-web/graphite.db'
$szPathToGraphiteDb = '/opt/graphite/storage/graphite.db'
$szHttpdServiceName = 'httpd'


# Download the https://github.com/graphite-project/graphite-web.git
# download the other two as well
#  https://github.com/graphite-project/carbon
#  https://github.com/graphite-project/whisper
#  https://github.com/graphite-project/ceres

# Graphite web needs:
package { 'pytz': ensure => present }
package { 'pyparsing': ensure => present }

# 
file { '/opt/graphite/conf/graphite.wsgi': 
  ensure => present,
  source => '/opt/graphite/conf/graphite.wsgi.example',
}

file { '/opt/graphite/storage/log':
  ensure => directory,
  owner  => 'apache',
}
file { '/opt/graphite/storage/log/webapp':
  ensure => directory,
  require => File['/opt/graphite/storage/log'],
  owner  => 'apache',
}


exec { 'sync_django_db':
  command => "python /opt/graphite/webapp/manage.py syncdb --noinput",
  path    => '/usr/bin',  
  creates => "$szPathToGraphiteDb",
  user    => 'apache',
}
#  require => [ 
#               Service["$arDjangoDependServiceList"],
#             ],
#               File_line['local_settings_secret_key','local_settings_email_host_user','local_settings_email_host_password'],
#               Package['graphite-web'],

file { "$szPathToGraphiteDb":
  ensure => file,
  owner  => 'apache',
  require => Exec['sync_django_db'],
}

service { "$szHttpdServiceName":
  ensure  => running,
  enable  => true,
  require => File["$szPathToGraphiteDb"],
}

