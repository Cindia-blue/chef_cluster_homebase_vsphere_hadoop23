ClusterChef.cluster 'hadoop_dm' do
  cloud(:vsphere) do
    defaults
    availability_zones ['us-east-1b']
    flavor              'm1.small'#'t1.micro'
    image_name          'maverick'
end

  role :base_role
  role :chef_client
  role :ssh
  role :package_set, :last
  role :dashboard, :last
  role :hadoop
  role :jruby

  facet :namenode do
    instances 1
    role :hadoop_namenode
  end

  facet :resourcemanager do
    instances 1
    role :hadoop_resourcemanager
  end

  facet :datanode do
    instances 2
    role :hadoop_datanode
  end

  facet :nodemanager do
    instances 1
    role :hadoop_nodemanager
  end

  cluster_role.override_attributes({
      :hadoop => {
        :compress_mapout_codec => 'org.apache.hadoop.io.compress.SnappyCodec',
      }
    })

  # Launch the cluster with all of the below set to 'stop'.
  facet(:namenode).facet_role.override_attributes({
      :hadoop => {
        :namenode => { :run_state => :start, },
#        :secondarynn => { :run_state => :start, },
#        :jobtracker => { :run_state => :start, },
#        :resourcemanager => { :run_state => :start, },
#        :datanode => { :run_state => :start, },
#        :tasktracker => { :run_state => :start, },
#        :nodemanager => { :run_state => :start, },
      },
    })

end
