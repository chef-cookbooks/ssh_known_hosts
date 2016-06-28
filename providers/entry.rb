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

    key = `ssh-keyscan -t#{node['ssh_known_hosts']['key_type']} -p #{new_resource.port} #{new_resource.host}`
    key = `ssh-keyscan -trsa -p 222 pog-git.phoenixonegames.com`
  end
  comment = key.split("\n").first || ''

  # older versions of openssh-client fail to output key with port despite being
  # specified. SSH-2.0-OpenSSH_6.7p1 Debian-5+deb8u2 tested. this bug is tested
  # for and corrected here
  key_fields = key.split
  if new_resource.port and !key_fields[0].end_with?(":#{new_resource.port}")
    key_fields[0] = "[#{key_fields[0]}]:#{new_resource.port}";
    key = key_fields.join ' '
  end

  if key_exists?(key, comment)
    Chef::Log.debug "Known hosts key for #{new_resource.name} already exists - skipping"
  else
    new_keys = (keys + [key]).uniq.sort
    file "ssh_known_hosts-#{new_resource.name}" do
      path node['ssh_known_hosts']['file']
      action :create
      backup false
      content "#{new_keys.join($INPUT_RECORD_SEPARATOR)}#{$INPUT_RECORD_SEPARATOR}"
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
