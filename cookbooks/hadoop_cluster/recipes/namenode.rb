#
# Cookbook Name::       hadoop_cluster
# Description::         Installs Hadoop Namenode service
# Recipe::              namenode
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

include_recipe "hadoop_cluster"
include_recipe "runit"

#get local IP
arg = `ifconfig eth0 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " "`
node[:hadoop][:namenode   ][:addr] = arg.chomp
puts "private_ip of namenode ="
puts node[:hadoop][:namenode   ][:addr]

include_recipe "hadoop_cluster::cluster_conf"


#change permission of file directory and prepare for start of namenode
script "chown_Namenode" do
  interpreter "bash"
  cwd "#{node[:hadoop][:common_home_dir]}"
  code <<-EOH
     chown -R hdfs:hadoop /home/ubuntu/hadoop/hadoop-0.23.0/logs
     chown -R hdfs:hadoop /home/ubuntu/hadoop/hdfs/name
  EOH
end

#format namenode
script "Format_Namenode" do
  interpreter "bash"
  cwd "#{node[:hadoop][:common_home_dir]}"
  user 'hdfs'
  code <<-EOH
     ./bin/hadoop namenode -format <<!
Y
!
  EOH
end

#start namenode
script "start_Namenode" do
  interpreter "bash"
  cwd "#{node[:hadoop][:common_home_dir]}"
  user 'hdfs'
  code <<-EOH
     ./libexec/hadoop-config.sh
     ./libexec/hdfs-config.sh
     ./sbin/hadoop-daemon.sh start namenode
  EOH
end


#./bin/hadoop namenode -format <<!
#     Y
#     !
