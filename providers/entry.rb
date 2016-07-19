#
# Author:: Seth Vargo (<sethvargo@gmail.com>)
# Provider:: entry
#
# Copyright 2013, Seth Vargo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :create do
  if new_resource.key

    key_type = if new_resource.key_type == 'rsa' || new_resource.key_type == 'dsa'
                 "ssh-#{new_resource.key_type}"
               else
                 new_resource.key_type
               end

    key = "#{new_resource.host} #{key_type} #{new_resource.key}"
  else
    keyscan = shell_out!("ssh-keyscan -t#{node['ssh_known_hosts']['key_type']} -p #{new_resource.port} #{new_resource.host}", timeout: new_resource.timeout)
    key = keyscan.stdout
  end

  comment = key.split("\n").first || ''

  if key_exists?(key, comment)
    Chef::Log.debug "Known hosts key for #{new_resource.name} already exists - skipping"
  else
    require 'English'

    new_keys = (keys + [key]).uniq.sort
    file "ssh_known_hosts-#{new_resource.name}" do
      path node['ssh_known_hosts']['file']
      owner new_resource.owner
      group new_resource.group
      mode new_resource.mode
      action :create
      backup false
      content "#{new_keys.join($RS)}#{$RS}"
    end
  end
end

private

def keys
  unless @keys
    if key_file_exists?
      lines = ::File.readlines(node['ssh_known_hosts']['file'])
      @keys = lines.map(&:chomp).reject(&:empty?)
    else
      @keys = []
    end
  end
  @keys
end

def key_file_exists?
  ::File.exist?(node['ssh_known_hosts']['file'])
end

def key_exists?(key, comment)
  keys.any? do |line|
    line.match(/#{Regexp.escape(comment)}|#{Regexp.escape(key)}/)
  end
end
