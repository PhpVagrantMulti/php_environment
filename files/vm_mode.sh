#!/bin/bash

##
# vm_mode.sh
# Allows us to switch between performance and development mode for performance sanity checks
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

if [ "$(id -u)" != "0" ]; then
    echo "Only root likes to do that"
    exit 1
fi

if [ "$1" != "perf" -a "$1" != "dev" ]; then
    echo "This script takes one argument (perf or dev) and tunes the php configuration for either performance or development, respectively."
    exit
fi

if [ "$1" == "perf" ]; then
    php5dismod xdebug
    # xhprof is not active as of php7 at least for the time being
    #php5dismod xhprof
    php5enmod opcache
fi

if [ "$1" == "dev" ]; then
    php5dismod opcache
    # xhprof is not active as of php7 at least for the time being
    #php5enmod xhprof
    php5enmod xdebug
fi

service apache2 restart

exit 0
