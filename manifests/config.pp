class curator::config {
  file { $curator::config_file:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/config.erb"),
    require => Package[$curator::package_name],
  }

  concat { $curator::actions_file:
    owner => 'root',
    group => 'root',
    mode  => '0644'
  }

  concat::fragment { 'curator.config.header':
    target  => $curator::actions_file,
    content => template("${module_name}/actions_header.erb"),
    order   => '00',
  }
}
