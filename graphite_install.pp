
# Install the Graphite Puppet module.
#exec { 'install_graphite_modul':
#  command => 'puppet module install dwerder-graphite',
#  creates => '/etc/puppet/modules/graphite',
#  path    => '/usr/bin',
#}
exec { 'get_graphite_modul':
  command => 'wget http://dm/storage/puppet/dwerder-graphite-5.15.0.tar.gz',
  cwd     => '/etc/puppet/modules',
  creates => '/etc/puppet/modules/dwerder-graphite-5.15.0.tar.gz',
  path    => '/usr/bin',
}

exec { 'unpack_graphite_modul':
  command => 'tar -zxf dwerder-graphite-5.15.0.tar.gz',
  cwd     => '/etc/puppet/modules',
  creates => '/etc/puppet/modules/dwerder-graphite-5.15.0',
  path    => '/usr/bin',
  require => Exec['get_graphite_modul'],
}

file { '/etc/puppet/modules/graphite':
  ensure  => link,
  target  => '/etc/puppet/modules/dwerder-graphite-5.15.0',
  require => Exec['unpack_graphite_modul'],
}

$szApacheTarName = "puppetlabs-apache-1.7.1.tar.gz"
$szApacheDirName = "puppetlabs-apache-1.7.1"
exec { 'get_apache_module':
  command => "wget http://dm/storage/puppet/$szApacheTarName",
  cwd     => '/etc/puppet/modules',
  creates => "/etc/puppet/modules/$szApacheTarName",
  path    => '/usr/bin',
}

exec { 'unpack_apache_module':
  command => "tar -zxf $szApacheTarName",
  cwd     => '/etc/puppet/modules',
  creates => "/etc/puppet/modules/$szApacheDirName",
  path    => '/usr/bin',
  require => Exec['get_apache_module'],
}

file { '/etc/puppet/modules/apache':
  ensure  => link,
  target  => "/etc/puppet/modules/$szApacheDirName",
  require => Exec['unpack_apache_module'],
}

$szConcatDirName = 'puppetlabs-concat-1.2.5'
$szConcatTarName = "$szConcatDirName.tar.gz"

exec { 'get_concat_module':
  command => "wget http://dm/storage/puppet/$szConcatTarName",
  cwd     => '/etc/puppet/modules',
  creates => "/etc/puppet/modules/$szConcatTarName",
  path    => '/usr/bin',
}

exec { 'unpack_concat_module':
  command => "tar -zxf $szConcatTarName",
  cwd     => '/etc/puppet/modules',
  creates => "/etc/puppet/modules/$szConcatDirName",
  path    => '/usr/bin',
  require => Exec['get_concat_module'],
}

file { '/etc/puppet/modules/concat':
  ensure  => link,
  target  => "/etc/puppet/modules/$szConcatDirName",
  require => Exec['unpack_concat_module'],
}



