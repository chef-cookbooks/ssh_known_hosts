include_recipe "::default"

# read in all the old information
lines = ::File.readlines(node['ssh_known_hosts']['file'])
hosts = lines.map(&:chmop).reject(&:empty).map do |line|
  fields = line.split(/\s+/)
  {
    "fqdn" => fields[0],
    "key_type" => fields[1],
    "key" => fields[2]
  }
end
ssh_known_hosts_entries hosts

# force a sync to disk right now
ruby_block "force ssh_known_hosts sync" do
  block do
    find_resource(:file, "update ssh known hosts file").run_action(:create)
  end
end
