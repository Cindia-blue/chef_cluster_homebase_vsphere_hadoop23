name 'hadoop_resourcemanager'
description 'runs a resourcemanager in fully-distributed mode. There should be exactly one of these per cluster.'

run_list %w[
  role[hadoop]
  hadoop_cluster::resourcemanager
]
