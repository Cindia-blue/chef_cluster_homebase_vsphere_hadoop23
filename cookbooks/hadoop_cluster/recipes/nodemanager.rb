# To change this template, choose Tools | Templates
# and open the template in the editor.

include_recipe "hadoop_cluster"
include_recipe "runit"

arg2 = `ifconfig eth0 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " "`
node[:hadoop][:nodemanager   ][:addr] = arg2.chomp
puts "private_ip of nodemanager ="
puts node[:hadoop][:nodemanager   ][:addr]

include_recipe "hadoop_cluster::cluster_conf"

#change permission of file directory and prepare for start of nodemanager
script "chown_nodemanager" do
  interpreter "bash"
  cwd "#{node[:hadoop][:common_home_dir]}"
  code <<-EOH
     chown -R mapred:hadoop /home/ubuntu/hadoop/hadoop-0.23.0/logs
     chown -R mapred:hadoop /tmp/nm/local
  EOH
end

#start nodemanager by daemon
script "start_nodemanager" do
  interpreter "bash"
  cwd "#{node[:hadoop][:common_home_dir]}"
  user 'mapred'
  code <<-EOH
   ./bin/yarn-daemon.sh start nodemanager
  EOH
end
