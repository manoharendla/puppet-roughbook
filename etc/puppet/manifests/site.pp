node default {
  file { '/etc/temp':
    content => "Temp file",
    ensure => 'present', 
  }

service { 'postfix':
   ensure => 'stopped',
   enable => 'false',
}

}
