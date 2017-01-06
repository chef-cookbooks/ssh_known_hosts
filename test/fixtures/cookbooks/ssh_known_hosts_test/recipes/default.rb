apt_update 'update'

include_recipe 'openssh::default'
include_recipe 'ssh_known_hosts::default'
