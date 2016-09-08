apt_update 'update' if platform_family?('debian')

include_recipe 'openssh::default'
include_recipe 'ssh_known_hosts::default'
