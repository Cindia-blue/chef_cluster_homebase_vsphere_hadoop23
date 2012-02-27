#
# Cookbook Name::       hadoop_cluster
# Description::         Base configuration for hadoop_cluster
# Recipe::              default
# Author::              Philip (flip) Kromer - Infochimps, Inc
#
# Copyright 2009, Opscode, Inc.
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

include_recipe "java::sun"
include_recipe "apt"

class Chef::Recipe; include HadoopCluster ; end

#produce user for later daemon execution
daemon_user(:hadoop){ user(:hdfs)   }
daemon_user(:hadoop){ user(:mapred) }

#create security group for later daemon execution
group 'hadoop' do
  group_name 'hadoop'
  gid         node[:groups]['hadoop'][:gid]
  action      [:create, :manage, :modify]
  append     true
  members     ['hdfs', 'mapred']
end

# Create the group hadoop uses to mean 'can act as filesystem root'
group 'supergroup' do
  group_name 'supergroup'
  gid        node[:groups]['supergroup'][:gid]
  action     [:create, :manage, :modify]
  append     true
end

#create directory
standard_dirs('hadoop') do
  directories   :home_dir
end

#download apache Hadoop 23 package
script "download_and_extract_hadoop" do
  interpreter "bash"
  cwd node[:hadoop][:home_dir]
    code <<-EOH
    if [ ! -f /home/ubuntu/hadoop/hadoop-0.23.0.tar.gz ]
    then
       wget 'http://apache.mirrors.hoobly.com//hadoop/core/hadoop-0.23.0/hadoop-0.23.0.tar.gz'
       tar -zxf 'hadoop-0.23.0.tar.gz'
    fi
    EOH
end

standard_dirs('hadoop') do
  directories   :pid_dir, :maper_dir
end

#directory ("#{node[:hadoop][:home_dir]}"){ action(:create) ; owner 'hdfs' ; group "hadoop"; mode "0775" }

#%w[conf].each{|svc| directory("#{node[:hadoop][:home_dir]}/#{svc}"){ action(:create) ; owner 'hdfs' ; group "hadoop"; mode "0775" } }

#%w[tmp log].each{|svc| directory("#{node[:hadoop][:home_dir]}/#{svc}"){ action(:create) ; owner 'mapred' ; group "hadoop"; mode "0775" } }


%w[tmp logs].each{|svc| directory("#{node[:hadoop][:common_home_dir]}/#{svc}"){ action(:create) ; owner 'hdfs' ; group "hadoop"; mode "0775" } }

%w[hdfs].each{|svc| directory("#{node[:hadoop][:home_dir]}/hdfs"){ action(:create) ; owner 'hdfs' ; group "hadoop"; mode "0775" } }

%w[name secondary data].each{|svc| directory("#{node[:hadoop][:home_dir]}/hdfs/#{svc}"){ action(:create) ; owner 'hdfs' ; group "hadoop"; mode "0775" } }

%w[local].each{|svc| directory("#{node[:hadoop][:maper_dir]}/#{svc}"){ action(:create) ; owner 'mapred' ; group "hadoop"; mode "0775" } }

#%w[logs].each{|svc| directory("#{node[:hadoop][:common_home_dir]}/#{svc}"){ action(:create) ; owner 'mapred' ; group "hadoop"; mode "0775" } }

# Namenode metadata striped across all persistent dirs
#volume_dirs('hadoop.namenode.data') do
#  type          :persistent
#  selects       :all
#  path          'hadoop/hdfs/name'
#  mode          "0700"
#end
#
## Secondary Namenode metadata striped across all persistent dirs
#volume_dirs('hadoop.secondarynn.data') do
#  type          :persistent
#  selects       :all
#  path          'hadoop/hdfs/secondary'
#  mode          "0700"
#end
#
## Datanode data striped across all persistent dirs
#volume_dirs('hadoop.datanode.data') do
#  type          :persistent
#  selects       :all
#  path          'hadoop/hdfs/data'
#  mode          "0700"
#end
#
## Mapred job scratch space striped across all scratch dirs
#volume_dirs('hadoop.tasktracker.scratch') do
#  type          :local
#  selects       :all
#  path          'hadoop/mapred/local'
#  mode          "0755"
#end
#
## Hadoop tmp storage on a single scratch dir
#volume_dirs('hadoop.tmp') do
#  type          :local
#  selects       :single
#  path          'hadoop/tmp'
#  group         'hadoop'
#  mode          "0777"
#end
#
## Hadoop log storage on a single scratch dir
#volume_dirs('hadoop.log') do
#  type          :local
#  selects       :single
#  path          'hadoop/log'
#  group         'hadoop'
#  mode          "0777"
#end

#%w[namenode secondarynn datanode].each{|svc| directory("#{node[:hadoop][:common_home_dir]}/logs/#{svc}"){ action(:create) ; owner 'hdfs'   ; group "hadoop"; mode "0775" } }
#%w[resourcemanager nodemanager].each{|svc| directory("#{node[:hadoop][:common_home_dir]}/logs/#{svc}"){ action(:create) ; owner 'mapred' ; group "hadoop"; mode "0775" } }

directory ("/tmp/nm"){ action(:create) ; owner 'mapred' ; group "hadoop"; mode "0775" }
%w[local app-logs  logs].each{|svc| directory("/tmp/nm/#{svc}"){ action(:create) ; owner 'mapred' ; group "hadoop"; mode "0775" } }

# JMX should listen on the public interface
node[:hadoop][:jmx_dash_addr] = public_ip_of(node)

# Make /var/log/hadoop point to the logs (which is on the first scratch dir),
# and /var/run/hadoop point to the actual pid dir
force_link("/var/log/hadoop",                    node[:hadoop][:log_dir] )
force_link("/var/log/#{node[:hadoop][:handle]}", node[:hadoop][:log_dir] )
force_link("/var/run/#{node[:hadoop][:handle]}", node[:hadoop][:pid_dir] )

node[:hadoop][:exported_jars] = [
  "#{node[:hadoop][:home_dir]}/#{node[:hadoop][:handle]}/share/hadoop/common/hadoop-common-0.23.0.jar",
  "#{node[:hadoop][:home_dir]}/#{node[:hadoop][:handle]}/share/hadoop/common/hadoop-common-0.23.0-tests.jar",
  "#{node[:hadoop][:home_dir]}/#{node[:hadoop][:handle]}/share/hadoop/common/hadoop-0.23.0-gridmix.jar",
  "#{node[:hadoop][:home_dir]}/#{node[:hadoop][:handle]}/hadoop-0.23.0-streaming.jar",
  "#{node[:hadoop][:home_dir]}/#{node[:hadoop][:handle]}/hadoop-mapreduce-0.23.0.jar",
  "#{node[:hadoop][:home_dir]}/#{node[:hadoop][:handle]}/hadoop-mapreduce-examples-0.23.0.jar",
  "#{node[:hadoop][:home_dir]}/#{node[:hadoop][:handle]}/hadoop-mapreduce-test-0.23.0.jar",
  "#{node[:hadoop][:home_dir]}/#{node[:hadoop][:handle]}/hadoop-mapreduce-tools-0.23.0.jar ",

]

node[:hadoop][:exported_libs] = Dir["#{node[:hadoop][:home_dir]}/#{node[:hadoop][:handle]}/lib/*.*"].sort.reject{|ff| File.directory?(ff) }

#Chef::Log.info( [ 'hadoop native libs', node[:hadoop][:exported_libs] ].inspect )

node[:hadoop][:exported_confs]  = [
  "#{node[:hadoop][:conf_dir]}/core-site.xml",
  "#{node[:hadoop][:conf_dir]}/hdfs-site.xml",
  "#{node[:hadoop][:conf_dir]}/mapred-site.xml",
  "#{node[:hadoop][:conf_dir]}/yarn-site.xml",
]