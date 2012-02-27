#
# Cookbook Name::       hadoop_cluster
# Description::         Installs Hadoop Datanode service
# Recipe::              datanode
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

include_recipe "hadoop_cluster::cluster_conf"

#change permission of file directory and prepare for start of datanode
script "chown_datanode" do
  interpreter "bash"
  cwd "#{node[:hadoop][:common_home_dir]}"
  code <<-EOH
     chown -R hdfs:hadoop /home/ubuntu/hadoop/hadoop-0.23.0/logs
     chown -R hdfs:hadoop /home/ubuntu/hadoop/hdfs/data
  EOH
end

#start data node by daemon
script "start_datanode" do
  interpreter "bash"
  cwd "#{node[:hadoop][:common_home_dir]}"
  user 'hdfs'
  code <<-EOH 
   ./sbin/hadoop-daemon.sh start datanode
  EOH
end
#./bin/hadoop --config #{node[:hadoop][:conf_dir]} datanode -format
#./sbin/hadoop-daemons.sh --config #{node[:hadoop][:conf_dir]} start datanode
