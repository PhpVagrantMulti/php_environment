##
# default.rb
# Installs and configures the php environment
# Cookbook Name:: php_environment
# Recipe:: default
# AUTHORS::   Seth Griffin <griffinseth@yahoo.com>
# Copyright:: Copyright 2015 Authors
# License::   GPLv3
#
# This file is part of PhpVagrantMulti.
# PhpVagrantMulti is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# PhpVagrantMulti is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with PhpVagrantMulti.  If not, see <http://www.gnu.org/licenses/>.
##

# Install php-fpm if required

if node["phpEnvironment"]["use_fpm"] == true
    php_fpm_pool 'default' do
        action :install
    end
    
    apache_conf "php7.0-fpm" do
        enable true
    end
end

# Install php packages

node["phpEnvironment"]["packages"].each do |pkg|
    package pkg do
        action :install
    end
end

# Install phing via pear

php_pear_channel "pear.phing.info" do
  action :discover
end

execute "pear_install_phing" do
    not_if { File.exists?("/usr/bin/phing") }
    command "sudo pear install phing/phing"
    action :run
end

execute "enable_mcrypt" do
    command "sudo phpenmod mcrypt"
    action :run
end

cookbook_file "pvm-overrides.ini" do
    path "/etc/php/7.0/mods-available/pvm-overrides.ini"
    action :create
end

cookbook_file "vm_mode.sh" do
    path "/home/vagrant/vm_mode.sh"
    action :create
    mode '0744'
    owner 'vagrant'
    group 'vagrant'
end

# Create an extra-large couch for composer's enormous ass
bash "create_couch" do
  not_if { File.exists?("/var/swap.1") }
  code <<-EOH
    mkdir -p /var/cache/swap/
    dd if=/dev/zero of=/var/cache/swap/composers_couch bs=1M count=1024
    chmod 0600 /var/cache/swap/composers_couch
    /sbin/mkswap /var/cache/swap/composers_couch 
    /sbin/swapon /var/cache/swap/composers_couch
    echo "/var/cache/swap/composers_couch    none    swap    sw    0   0" >> /etc/fstab
    EOH
end

execute "enable_pvm_overrides_apache" do
    not_if { File.exists?("/etc/php/7.0/cgi/conf.d/99-pvm-overrides.ini") }
    command "sudo ln -s /etc/php/7.0/mods-available/pvm-overrides.ini /etc/php/7.0/cgi/conf.d/99-pvm-overrides.ini"
    action :run
end

execute "enable_pvm_overrides_cli" do
    not_if { File.exists?("/etc/php/7.0/cli/conf.d/99-pvm-overrides.ini") }
    command "sudo ln -s /etc/php/7.0/mods-available/pvm-overrides.ini /etc/php/7.0/cli/conf.d/99-pvm-overrides.ini"
    action :run
end
