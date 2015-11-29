# vagrant-puppet-rails

Simple vagrant box that uses Puppet. The r10k plugin provides module support for Puppet.

Puppet Modules
- stdlib
- concat
- rbenv (ruby 2.2.3)
- postgresql

## Installing

Before installing please make sure the requirements in the section below are met.

### Requirements
Install Vagrant 1.7.4.

Required Vagrant plugins:
```
$ vagrant plugin install r10k
```
Recommended Vagrant plugins
```
$ vagrant plugin install rsync-back
```

## Usage
After cloning this repository, use the command below so start the Vagrant environment.
```
$ vagrant up
```
### Using Rsync
To sync changes on the host to the `/vagrant` folder shared to the guest:
- Open a new teminal/Powershell session.
- Type `$ vagrant rsync-auto`.

The rsync-auto process will run in in the terminal until `Ctrl-C` is pressed.

#### rsync-back
While it is possible to watch for file changes on the host machine and sync to the Vagrant guest, it is not possible to watch for file changes on the guest and sync to the host. A manual solution is to use the Vagrant plugin rsync-back.

```
$ vagrant rsync-back
```  
