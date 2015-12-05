## Manifest variables
$user = 'vagrant'
$password = 'password'

## Include the classes list from hiera.
hiera_include ('classes', [])

## Include packages list from hiera.
$packages = hiera_hash('packages', {})
create_resources('package', $packages)

## Define roles in order to created roles before any databases.
class role::psql::roles {
	$roles = hiera('postgresql::server::roles')
	create_resources(postgresql::server::role, $roles)
}
class role::psql::databases {
	$databases = hiera('postgresql::server::databases')
	create_resources(postgresql::server::database, $databases)
}

## postgresql: setup
## DESC Insert roles and creat Rails databases.
class {'role::psql::roles':} ->
class {'role::psql::databases':}

## rbenv: setup
## DESC Install plugins, build ruby versions and then install gems.
# Plugins
$plugins = hiera('rbenv::plugins')
create_resources(rbenv::plugin, $plugins)
# Builds
$builds = hiera('rbenv::builds')
create_resources(rbenv::build, $builds)
# Gems
$gems = hiera('rbenv::gems')
create_resources(rbenv::gem, $gems)
