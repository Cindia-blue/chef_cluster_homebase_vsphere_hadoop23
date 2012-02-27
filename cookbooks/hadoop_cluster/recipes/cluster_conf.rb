#
# Cookbook Name::       hadoop_cluster
# Description::         Configure cluster
# Recipe::              cluster_conf
# Author::              Philip (flip) Kromer - Infochimps, Inc
#
# Copyright 2011, Philip (flip) Kromer - Infochimps, Inc
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

#
# Configuration files
#
# Find these variables in ../hadoop_cluster/libraries/hadoop_cluster.rb
#

#node[:hadoop][:namenode   ][:addr] = discover(:hadoop, :namenode   ).public_ip rescue nil
#node[:hadoop][:resourcemanager ][:addr] = discover(:hadoop, :resourcemanager).ip rescue nil
#node[:hadoop][:secondarynn][:addr] = discover(:hadoop, :secondarynn).public_ip rescue nil
#node[:hadoop][:nodemanager][:addr] = discover(:hadoop, :nodemanager).pubiic_ip rescue nil

#db_server = search(:node,"name:hadoop_dm-namenode-0")
#if (db_server[0])
#puts "db_server ="
#puts db_server[0].to_s
#node[:hadoop][:namenode   ][:addr] = "#{db_server[0][:ipaddress]}"
#puts "private_ip of namenode ="
#puts node[:hadoop][:namenode   ][:addr]
#else
#  node[:hadoop][:namenode ][:addr] = '10.112.126.202'
#end
#
#db_server1 = search(:node,"name:hadoop_dm-resourcemanager-0")
#if (db_server1[0])
#puts "db_server1 ="
#puts db_server1[0].to_s
#node[:hadoop][:resourcemanager ][:addr] = "#{db_server1[0][:ipaddress]}"
#puts "private_ip of resourcemanager ="
#puts node[:hadoop][:resourcemanager ][:addr]
#else
#  node[:hadoop][:resourcemanager ][:addr] = '10.112.126.74'
#end
#
#db_server2 = search(:node,"name:hadoop_dm-nodemanager-0")
#if (db_server2[0])
#puts "db_server2 ="
#puts db_server2[0].to_s
#node[:hadoop][:nodemanager ][:addr] = "#{db_server2[0][:ipaddress]}"
#puts "private_ip of nodemanager ="
#puts node[:hadoop][:nodemanager ][:addr]
#else
#  node[:hadoop][:nodemanager ][:addr] = '10.112.126.159'
#end
#
#db_server3 = search(:node,"name:hadoop_dm-datanode-0")
#if (db_server3 [0])
#puts "db_server 3 ="
#puts db_server3[0].to_s
#node[:hadoop][:datanode ][:addr] = "#{db_server3 [0][:ipaddress]}"
#puts "private_ip of datanode ="
#puts node[:hadoop][:datanode ][:addr]
#else
#  node[:hadoop][:datanode ][:addr] = '10.112.126.90'
#end


#if (!node[:hadoop][:resourcemanager   ][:addr])
#  node[:hadoop][:resourcemanager   ][:addr] = '10.112.126.161'
#end
#
#if (!node[:hadoop][:nodemanager   ][:addr])
#  node[:hadoop][:nodemanager   ][:addr] = '10.112.126.26'
#end

%w[ core-site.xml     hdfs-site.xml     yarn-site.xml
    hadoop-env.sh     mapred-site.xml   yarn-env.sh
].each do |conf_file|
  template "#{node[:hadoop][:conf_dir]}/#{conf_file}" do
    owner "root"
    mode "0744"
    variables(:hadoop => hadoop_config_hash)
    source "#{conf_file}.erb"
#    hadoop_services.each do |svc|
#      if startable?(node[:hadoop][svc])
#        notifies :restart, "service[hadoop_#{svc}]", :delayed
#      end
#    end
  end
end


%w[ update.json].each do |conf_file|
  template "/etc/chef/#{conf_file}" do
    owner "root"
    mode "0744"
    #variables(:hadoop => hadoop_config_hash)
    source "#{conf_file}.erb"
  end
end

#template "/etc/default/#{node[:hadoop][:handle]}" do
#  owner "root"
#  mode "0644"
#  variables(:hadoop => hadoop_config_hash)
#  source "etc_default_hadoop.erb"
#end
#
## $HADOOP_NODENAME is set in /etc/default/hadoop
#munge_one_line('use node name in hadoop .log logs', "#{node[:hadoop][:home_dir]}/bin/hadoop-daemon.sh",
#  %q{export HADOOP_LOGFILE=hadoop-.HADOOP_IDENT_STRING-.command-.HOSTNAME.log},
#   %q{export HADOOP_LOGFILE=hadoop-$HADOOP_IDENT_STRING-$command-$HADOOP_NODENAME.log},
#  %q{^export HADOOP_LOGFILE.*HADOOP_NODENAME}
#  )
#
#munge_one_line('use node name in hadoop .out logs', "#{node[:hadoop][:home_dir]}/bin/hadoop-daemon.sh",
#  %q{export _HADOOP_DAEMON_OUT=.HADOOP_LOG_DIR/hadoop-.HADOOP_IDENT_STRING-.command-.HOSTNAME.out},
#  %q{export _HADOOP_DAEMON_OUT=$HADOOP_LOG_DIR/hadoop-$HADOOP_IDENT_STRING-$command-$HADOOP_NODENAME.out},
#  %q{^export _HADOOP_DAEMON_OUT.*HADOOP_NODENAME}
#  )

