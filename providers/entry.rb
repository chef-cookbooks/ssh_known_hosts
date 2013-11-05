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

action :create do
  key = (new_resource.key || `ssh-keyscan -H -p #{new_resource.port} #{new_resource.host} 2>&1`)
  comment = key.split("\n").first || ""

  Chef::Application.fatal! "Could not resolve #{new_resource.host}" if key =~ /getaddrinfo/

  # Ensure that the file exists and has minimal content (required by Chef::Util::FileEdit)
  file node['ssh_known_hosts']['file'] do
    action        :create
    backup        false
    content       '# This file must contain at least one line. This is that line.'
    only_if do
      !::File.exists?(node['ssh_known_hosts']['file']) || ::File.new(node['ssh_known_hosts']['file']).readlines.length == 0
    end
  end

  # Use a Ruby block to edit the file
  ruby_block "add #{new_resource.host} to #{node['ssh_known_hosts']['file']}" do
    block do
      file = ::Chef::Util::FileEdit.new(node['ssh_known_hosts']['file'])
      file.insert_line_if_no_match(/#{Regexp.escape(comment)}|#{Regexp.escape(key)}/, key)
      file.write_file
    end
  end
  new_resource.updated_by_last_action(true)
end
