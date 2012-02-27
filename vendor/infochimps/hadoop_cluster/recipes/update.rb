script "update_json" do
  interpreter "bash"
  code <<-EOH
   gem list
   gem install json json_pure -v 1.6.1 --no-ri --no-rdoc
   gem uninstall json json_pure -v 1.6.5
   gem list
  EOH
end
