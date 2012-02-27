# To change this template, choose Tools | Templates
# and open the template in the editor.

include_recipe "hadoop_cluster"
include_recipe "runit"

arg1 = `ifconfig eth0 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " "`
puts "ip ="
puts arg1
node[:hadoop][:resourcemanager ][:addr] = arg1.chomp
puts "private_ip of resourcemanager ="
puts node[:hadoop][:resourcemanager ][:addr]

include_recipe "hadoop_cluster::cluster_conf"

#hadoop_service(:resourcemanager)

script "chown_Resourcemanager" do
  interpreter "bash"
  cwd "#{node[:hadoop][:common_home_dir]}"
  code <<-EOH
     chown -R mapred:hadoop /home/ubuntu/hadoop/hadoop-0.23.0/logs
  EOH
end

script "start_resourcemanager" do
  interpreter "bash"
  cwd "#{node[:hadoop][:common_home_dir]}"
  user 'mapred'
  code <<-EOH
   ./bin/yarn-daemon.sh start resourcemanager
  EOH
end
