
# Install the Graphite Puppet module.
exec { 'install_graphite_modul':
  command => 'puppet module install dwerder-graphite',
  creates => '/etc/puppet/modules/graphite',
  path    => '/usr/bin',
}

# Install the apache module.
exec { 'install_apache_modul':
  command => 'puppet module install puppetlabs-apache',
  creates => '/etc/puppet/modules/apache',
  path    => '/usr/bin',
}


class { 'graphite':
  gr_max_updates_per_second => 100,
  gr_timezone               => 'Europe/Berlin',
  secret_key                => 'CHANGE_IT!',
  require    => Exec['install_apache_modul','install_graphite_modul'],
}
