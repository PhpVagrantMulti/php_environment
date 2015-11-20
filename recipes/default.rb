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

package "php5-mysql" do
    action :remove
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
    command "sudo php5enmod mcrypt"
    action :run
end

cookbook_file "pvm-overrides.ini" do
    path "/etc/php5/mods-available/pvm-overrides.ini"
    action :create
end

cookbook_file "vm_mode.sh" do
    path "/home/vagrant/vm_mode.sh"
    action :create
    mode '0744'
end

execute "enable_pvm_overrides_apache" do
    not_if { File.exists?("/etc/php5/apache2/conf.d/99-pvm-overrides.ini") }
    command "sudo ln -s /etc/php5/mods-available/pvm-overrides.ini /etc/php5/apache2/conf.d/99-pvm-overrides.ini"
    action :run
end

execute "enable_pvm_overrides_cli" do
    not_if { File.exists?("/etc/php5/cli/conf.d/99-pvm-overrides.ini") }
    command "sudo ln -s /etc/php5/mods-available/pvm-overrides.ini /etc/php5/cli/conf.d/99-pvm-overrides.ini"
    action :run
end
