name              'ssh_known_hosts'
maintainer        'Chef Software, Inc.'
maintainer_email  'cookbooks@chef.io'
license           'Apache 2.0'
description       'Dyanmically generates /etc/ssh/ssh_known_hosts based on search indexes'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '3.1.0'
recipe            'ssh_known_hosts', 'Provides an LWRP for managing SSH known hosts. Also includes a recipe for automatically adding all nodes to the SSH known hosts.'

source_url 'https://github.com/chef-cookbooks/ssh_known_hosts' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/ssh_known_hosts' if respond_to?(:issues_url)
