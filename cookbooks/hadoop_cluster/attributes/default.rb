# -*- coding: utf-8 -*-

# This file describes
#
#
# See hadoop_cluster/attributes/tunables.rb for the hairy, hairy tuning variables.

#
# Services
#

# What states to set for services.
#
# You want to bring the big daemons up deliberately on initial start.
#   Override in your cluster definition when things are stable.
default[:hadoop][:namenode   ][:data_dirs]       = []
default[:hadoop][:secondarynn][:data_dirs]       = []
#default[:hadoop][:namenode   ][:data_dirs]       = '/home/ubuntu/hadoop/hdfs/name'
#default[:hadoop][:secondarynn][:data_dirs]       = '/home/ubuntu/hadoop/hdfs/secondary'
default[:hadoop][:resourcemanager ][:system_hdfsdir]  = '/home/ubuntu/hadoop/mapred' # note: on the HDFS
default[:hadoop][:resourcemanager ][:staging_hdfsdir] = '/home/ubuntu/hadoop/mapred/job' # note: on the HDFS
default[:hadoop][:datanode   ][:data_dirs]       = []
#default[:hadoop][:nodemanager][:scratch_dirs]    = '/home/ubuntu/hadoop/mapred/task'
default[:hadoop][:nodemanager][:local_dirs] = "/tmp/nm/local"
default[:hadoop][:nodemanager][:remote_app_log_dir] = "/tmp/nm/app-logs"
default[:hadoop][:nodemanager][:log_dirs] = "/tmp/nm/logs"

default[:hadoop][:home_dir] = "/home/ubuntu/hadoop"
default[:hadoop][:conf_dir] = "/home/ubuntu/hadoop/hadoop-0.23.0/conf"
default[:hadoop][:common_home_dir] = "/home/ubuntu/hadoop/hadoop-0.23.0"
default[:hadoop][:hdfs_dir]        = "/home/ubuntu/hadoop/hadoop-0.23.0"
default[:hadoop][:maper_dir] = "/home/ubuntu/hadoop/hadoop-0.23.0/mapred"
default[:hadoop][:pid_dir]  = "/var/run/hadoop"
default[:hadoop][:log_dir]  = nil # set in recipe using volume_dirs
default[:hadoop][:tmp_dir]  = nil # set in recipe using volume_dirs
default[:hadoop][:extractfolder] = "hadoop-0.23.0"

default[:hadoop][:exported_confs] ||= nil  # set in recipe
default[:hadoop][:exported_jars]  ||= nil  # set in recipe

default[:hadoop][:namenode   ][:port]              =  8020
default[:hadoop][:resourcemanager ][:resource_tracker_port]              =  8025
default[:hadoop][:resourcemanager ][:scheduler_port]              =  8030
default[:hadoop][:resourcemanager ][:port]              =  8040
default[:hadoop][:nodemanager ][:port]              =  45454

default[:hadoop][:datanode   ][:port]              = 50010
default[:hadoop][:datanode   ][:ipc_port]          = 50020

default[:hadoop][:namenode   ][:dash_port]         = 50070
default[:hadoop][:secondarynn][:dash_port]         = 50090
default[:hadoop][:resourcemanager ][:dash_port]         = 50030
default[:hadoop][:datanode   ][:dash_port]         = 50075
default[:hadoop][:nodemanager][:dash_port]         = 50060

default[:hadoop][:namenode   ][:jmx_dash_port]     = 8004
default[:hadoop][:secondarynn][:jmx_dash_port]     = 8005
default[:hadoop][:resourcemanager ][:jmx_dash_port]     = 8008
default[:hadoop][:datanode   ][:jmx_dash_port]     = 8006
default[:hadoop][:nodemanager][:jmx_dash_port]     = 8009
default[:hadoop][:balancer   ][:jmx_dash_port]     = 8007

default[:hadoop][:java][:java_home] = "/usr/lib/jvm/java-6-sun/jre"

#
# Users
#

default[:groups]['hadoop'     ][:gid]   = 300

default[:groups]['supergroup' ][:gid]   = 301

default[:users ]['hdfs'       ][:uid]   = 302
default[:groups]['hdfs'       ][:gid]   = 302

default[:users ]['mapred'     ][:uid]   = 303
default[:groups]['mapred'     ][:gid]   = 303

default[:hadoop][:user]                 = 'hdfs'
default[:hadoop][:namenode    ][:user]  = 'hdfs'
default[:hadoop][:secondarynn ][:user]  = 'hdfs'
default[:hadoop][:resourcemanager  ][:user]  = 'mapred'
default[:hadoop][:datanode    ][:user]  = 'hdfs'
default[:hadoop][:nodemanager][:user]  = 'mapred'

#
# Install
#

default[:hadoop][:handle]               = 'hadoop-0.23.0'#lixh
default[:hadoop][:deb_version]          = '0.20.2+923.142-1~maverick-cdh3'
# set to nil to pull name from actual machine's distro --
# note however that cloudera is very conservative to update its distro support
default[:apt][:cloudera][:force_distro] = 'maverick'
default[:apt][:cloudera][:release_name] = 'cdh3u2'

#
# System
#

default[:tuning][:ulimit]['hdfs']   = { :nofile => { :both => 32768 }, :nproc => { :both => 50000 } }
default[:tuning][:ulimit]['mapred'] = { :nofile => { :both => 32768 }, :nproc => { :both => 50000 } }

#
# Integration
#

# Other recipes can add to this under their own special key, for instance
#  node[:hadoop][:extra_classpaths][:hbase] = '/usr/lib/hbase/hbase.jar:/usr/lib/hbase/lib/zookeeper.jar:/usr/lib/hbase/conf'
default[:hadoop][:extra_classpaths]  = { }
