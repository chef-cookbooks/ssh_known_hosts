name              'ssh_known_hosts'
maintainer        'Chef Software, Inc.'
maintainer_email  'cookbooks@chef.io'
license           'Apache 2.0'
description       'Dyanmically generates /etc/ssh/known_hosts based on search indexes'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '2.0.0'
recipe            'ssh_known_hosts', 'Provides an LWRP for managing SSH known hosts. Also includes a recipe for automatically adding all nodes to the SSH known hosts.'

recommends "partial_search"
