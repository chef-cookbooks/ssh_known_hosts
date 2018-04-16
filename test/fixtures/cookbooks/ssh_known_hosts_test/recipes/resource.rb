include_recipe 'openssh::default'

group 'knownhosts' do
  gid '9000'
  action :create
end

user 'knownhosts' do
  comment 'Testing user'
  uid '9000'
  gid '9000'
end

ssh_known_hosts_entry 'travis.org' do
  owner 'knownhosts'
  group 'knownhosts'
  mode '0600'
end

# don't do this in production as ssh_known_hosts needs to be world readable
ssh_known_hosts_entry 'github.com' do
  owner 'knownhosts'
  group 'knownhosts'
  mode '0600'
end


# don't do this in production as ssh_known_hosts needs to be world readable
ssh_known_hosts_entry 'github.com for current user' do
  host 'github.com'
  file_location "#{ENV['HOME']}/.ssh/known_hosts"
  owner 'knownhosts'
  group 'knownhosts'
  mode '0600'
end
