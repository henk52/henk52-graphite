package {'puppetlabs-stdlib': ensure => present }

file { '/etc/puppet/modules/stdlib':
  ensure => link,
  target => '/usr/share/puppet/modules/stdlib',
  require => Package['puppetlabs-stdlib'],
}
