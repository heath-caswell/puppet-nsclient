# Author::    Paul Stack  (mailto:pstack@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: nsclient::service
#
# This private class is meant to be called from `nsclient`.
# It manages the nsclient service
#
class nsclient::service(
  $service_state   = $nsclient::service_state,
  $service_enable  = $nsclient::service_enable,
  $allowed_hosts   = $nsclient::allowed_hosts,
  $config_template = $nsclient::config_template,
  $install_path    = $nsclient::install_path,
  $use_inline_template = $nsclient::use_inline_template
) {

  case downcase($::osfamily) {
    'windows': {
	  if $use_inline_template {
	    $file_content = inline_template($config_template)
	  } else {
	    $file_content = template($config_template)
	  }
      file { "${install_path}\\nsclient.ini":
        ensure  => file,
        owner   => 'SYSTEM',
        mode    => '0664',
        content => $file_content,
        notify  => Service['nscp'],
      }

      service { 'nscp':
        ensure  => $service_state,
        enable  => $service_enable,
        require => File["${install_path}\\nsclient.ini"],
      }
    }
    default: {
      fail('This module only works on Windows based systems.')
    }
  }
}
