name        "elasticsearch_data_esnode"
description "Elasticsearch Data esnode (holds and indexes data) for elasticsearch cluster."

# List of recipes and roles to apply
run_list(*%w[
  elasticsearch::default
  elasticsearch::install_from_release
  elasticsearch::install_plugins

  elasticsearch::server
])
