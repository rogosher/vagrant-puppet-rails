class { 'rbenv': }

rbenv::plugin { 'sstephenson/ruby-build':}

rbenv::build { '2.2.3':
	global => true,
	env => ['RUBY_CONFIGURE_OPTS=--disable-install-doc']
}

rbenv::gem { 'rails': ruby_version => '2.2.3' }
rbenv::gem { 'pg': ruby_version => '2.2.3' }

package {'libpq-dev':
	ensure => 'installed',
}
$user = 'dev'
$password = 'password'

file { '/etc/default/locale':
	ensure  => 'file',
	owner   => 'root',
	group   => 'root',
	content => "LANG=en_US.UTF-8\n",
} ->
class { 'postgresql::server':
	ip_mask_deny_postgres_user => '0.0.0.0/32',
	ip_mask_allow_all_users => '0.0.0.0/0',
	listen_addresses => '*',
	ipv4acls => ['host all all 0.0.0.0/0 md5'],
	postgres_password => $password,
}

# Install contrib modules
class { 'postgresql::server::contrib':
	package_ensure => 'present',
}

postgresql::server::role { $user:
	password_hash => postgresql_password($user, $password),
}

postgresql::server::db { 'rails_database_development':
	user => $user,
	password => postgresql_password($user, $password),
}

postgresql::server::db { 'rails_database_test':
	user => $user,
	password => postgresql_password($user, $password),
}

postgresql::server::db { 'rails_database_production':
	user => $user,
	password => postgresql_password($user, $password),
}

postgresql::server::database_grant { 'test1':
	privilege => 'ALL',
	db        => 'rails_database_development',
	role      => $user,
}
