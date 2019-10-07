name              'ssh_known_hosts'
maintainer        'Chef Software, Inc.'
maintainer_email  'cookbooks@chef.io'
license           'Apache-2.0'
description       'Dyanmically generates /etc/ssh/ssh_known_hosts based on search indexes'
version           '7.0.0'

%w(ubuntu debian redhat centos suse opensuse opensuseleap scientific oracle amazon zlinux).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/ssh_known_hosts'
issues_url 'https://github.com/chef-cookbooks/ssh_known_hosts'
chef_version '>= 14.4'
