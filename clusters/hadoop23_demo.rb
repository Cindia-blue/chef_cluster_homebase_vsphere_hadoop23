#
#
# * persistent HDFS --
#
# if you're testing, these recipes *will* work on a t1.micro. just don't use it for anything.
#
ClusterChef.cluster 'hadoop23_demo' do
  cloud(:vsphere) do
    defaults
#    ssh_identity_dir    File.expand_path('~/.ssh/')
#    keypair 'chef'
    #security_group 'default'
    availability_zones ['us-east-1b']
    #flavor 'm1.large'
    #backing 'ebs'
    #image_name 'cluster_chef-natty'
    flavor              'm1.small'#'t1.micro'
    #backing             'ebs'
    image_name          'maverick'
    #bootstrap_distro 'ubuntu10.04-cluster_chef'
#    mount_ephemerals(:tags => {
#        :hadoop_scratch => true,
#        :hadoop_data => true, # remove this if you use the volume at bottom
#      })
  end

  # # uncomment if you want to set your environment.
  # environment :prod

  role :base_role
  role :chef_client
  role :ssh
  #role :nfs_client

#  role :volumes
  role :package_set, :last
  role :dashboard, :last

#  role :org_base
#  role :org_final, :last
#  role :org_users

  role :hadoop
#  role :hadoop_s3_keys
#  role :tuning
  role :jruby
#  role :pig
#  recipe 'hadoop_cluster::cluster_conf', :last

  facet :master do
    instances 1
    role :hadoop_namenode
  end

 facet :master1 do
    instances 1
    role :hadoop_resourcemanager
  end

  facet :worker do
    instances 2
    role :hadoop_datanode
  end

  facet :worker1 do
    instances 1
    role :hadoop_nodemanager
  end

  cluster_role.override_attributes({
      :hadoop => {
        # # adjust these
        # :java_heap_size_max => 1400,
        # :namenode => { :java_heap_size_max => 1000, },
        # :secondarynn => { :java_heap_size_max => 1000, },
        # :jobtracker => { :java_heap_size_max => 3072, },
        # :datanode => { :java_heap_size_max => 1400, },
        # :tasktracker => { :java_heap_size_max => 1400, },
        # # if you decommission nodes for elasticity, crank this up
        # :balancer => { :max_bandwidth => (50 * 1024 * 1024) },
        # # make mid-flight data much smaller -- useful esp. with ec2 network constraints
        :compress_mapout_codec => 'org.apache.hadoop.io.compress.SnappyCodec',
      }
    })

  # Launch the cluster with all of the below set to 'stop'.
  #
  # After initial bootstrap,
  # * set the run_state to 'start' in the lines below
  # * run `knife cluster sync hadoop_demo-master` to push those values up to chef
  # * run `knife cluster kick hadoop_demo-master` to re-converge
  #
  # Once you see 'nodes=1' on jobtracker (host:50030) & namenode (host:50070)
  # control panels, you're good to launch the rest of the cluster.
  #
  facet(:master).facet_role.override_attributes({
      :hadoop => {
        :namenode => { :run_state => :start, },
        :secondarynn => { :run_state => :start, },
        :jobtracker => { :run_state => :start, },
        :resourcemanager => { :run_state => :start, },
        :datanode => { :run_state => :start, },
        :tasktracker => { :run_state => :start, },
        :nodemanager => { :run_state => :start, },
      },
    })

  # #
  # # Attach persistent storage to each node, and use it for all hadoop data_dirs.
  # #
  # # Modify the snapshot ID and attached volume size to suit
  # #
  # volume(:ebs1) do
  # defaults
  # size 200
  # keep true
  # device '/dev/sdj' # note: will appear as /dev/xvdj on natty
  # mount_point '/data/ebs1'
  # attachable :ebs
  # snapshot_name :blank_xfs
  # resizable true
  # tags( :hadoop_data => true, :persistent => true, :local => false, :bulk => true, :fallback => false )
  # create_at_launch true
  # end

end