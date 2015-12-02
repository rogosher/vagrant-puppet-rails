stage { 'pre':
	before => Stage['main'],
}

augeas { "sshd_config":
	context	=> "/files/etc/ssh/sshd_config",
	changes	=>	[
		"set ClientAliveInterval 1048",
		"set ClientAliveCountMax 30"
	],
	notify	=> Service["sshd"],
}

service { "sshd":
	name => "ssh",
	require => Augeas["sshd_config"],
	enable  => true,
	ensure  => running,
}

$user = 'vagrant'
$password = 'password'

# include the classes list from hiera
hiera_include ('classes', [])

#include packages list from hiera
$packages = hiera_hash('packages', {})
create_resources('package', $packages)

class { '::nodejs':
	manage_package_repo       => false,
	nodejs_dev_package_ensure => 'present',
	npm_package_ensure        => 'present',
}

## Install contrib modules
class { 'postgresql::server::contrib':
	package_ensure => 'present',
}

#file { '/etc/default/locale':
#	ensure  => 'file',
#	owner   => 'root',
#	group   => 'root',
#	content => "LANG=en_US.UTF-8\n",
#} ->

#class { 'postgresql::globals':
#  encoding => 'UTF-8',
#  locale   => 'en_US.UTF-8',
#} ->

class { 'postgresql::server':
	ip_mask_deny_postgres_user => '0.0.0.0/32',
	ip_mask_allow_all_users => '0.0.0.0/0',
	listen_addresses => '*',
	ipv4acls => ['host all all 0.0.0.0/0 md5'],
	postgres_password => $password,
} ->

postgresql::server::role { $user:
	password_hash => postgresql_password($user, $password),
} ->

postgresql::server::database { 'rails_database_development':
	owner => $user,
} ->

postgresql::server::database { 'rails_database_test':
	owner => $user,
} ->

postgresql::server::database { 'rails_database_production':
	owner => $user,
} ->

class {'rbenv':
	latest => true,
} ->

rbenv::plugin { [ 'sstephenson/rbenv-vars', 'sstephenson/ruby-build' ]:
	latest => true,
}

rbenv::build { '2.2.3':
	global => true,
	env => ['RUBY_CONFIGURE_OPTS=--disable-install-doc'],
} ->

rbenv::gem { 'rails':
	ruby_version => '2.2.3',
	skip_docs => true,
} ->
rbenv::gem { 'pg':
	ruby_version => '2.2.3',
	skip_docs => true,
} ->
rbenv::gem { 'uwsgi':
	gem => 'uwsgi -V',
	ruby_version => '2.2.3',
	skip_docs => true,
}

#postgresql::server::db { 'dummy_development':
#	user => $user,
#	password => postgresql_password($user, $password),
#}
#
#postgresql::server::db { 'dummy_test':
#	user => $user,
#	password => postgresql_password($user, $password),
#}
#
#postgresql::server::db { 'dummy_production':
#	user => $user,
#	password => postgresql_password($user, $password),
#}

#postgresql::server::database_grant { 'rails_database_development':
#	privilege => 'ALL',
#	db        => 'rails_database_development',
#	role      => $user,
#}
