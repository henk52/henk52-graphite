

class { 'graphite':
  gr_max_updates_per_second => 100,
  gr_timezone               => 'Europe/Berlin',
  secret_key                => 'CHANGE_IT!',
}
