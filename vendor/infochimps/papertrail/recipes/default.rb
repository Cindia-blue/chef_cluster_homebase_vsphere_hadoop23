#
# Cookbook Name::       papertrail
# Description::         Base configuration for papertrail
# Recipe::              default
# Author::              Mike Heffner, Librato, Inc.
#
# Copyright 2011, Librato, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

return unless node[:papertrail][:logger] == "rsyslog"

syslogger = "rsyslog"

include_recipe "rsyslog"
package "rsyslog-gnutls"

remote_file node[:papertrail][:cert_file] do
  source node[:papertrail][:cert_url]
  mode "0444"
end

syslogdir = "/etc/rsyslog.d"

if node[:papertrail][:watch_files] && node[:papertrail][:watch_files].length > 0
  template "#{syslogdir}/60-watch-files.conf" do
    source "watch-files.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({:watch_files => node[:papertrail][:watch_files]})
    notifies  :restart, resources(:service => syslogger)
  end
end

hostname_name = node[:papertrail][:hostname_name].to_s
hostname_cmd = node[:papertrail][:hostname_cmd].to_s

unless hostname_name.empty? && hostname_cmd.empty?
  node[:papertrail][:fixhostname] = true

  if !hostname_name.empty?
    name = hostname_name
  else
    name = %x{#{hostname_cmd}}.chomp
  end

  template "#{syslogdir}/61-fixhostnames.conf" do
    source "fixhostnames.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({:name => name})
    notifies  :restart, resources(:service => syslogger)
  end
end

template "#{syslogdir}/65-papertrail.conf" do
  source "papertrail.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({ :cert_file => node[:papertrail][:cert_file],
              :host => node[:papertrail][:remote_host],
              :port => node[:papertrail][:remote_port],
              :fixhostname => node[:papertrail][:fixhostname]
            })
  notifies  :restart, resources(:service => syslogger)
end
