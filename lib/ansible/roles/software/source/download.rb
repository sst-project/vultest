# Copyright [2020] [University of Aizu]
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
require 'fileutils'
require 'yaml'

module Ansible
  module Roles
    module Software
      module Source
        class Download
          attr_reader :dir

          def initialize(args)
            @software = {
              name: args[:software]['name'],
              version: args[:software]['version'],
              src_dir: args[:software].fetch('src_dir', '/usr/local/src')
            }

            metadata = YAML.load_file('./metadata.yml')
            @url = metadata['softwares'][@software[:name]]['url']
            @download_file = metadata['softwares'][@software[:name]]['download_file']

            @resource_path = "#{ANSIBLE_ROLES_TEMPLATE_PATH}/software/source/download"
            @role_path = "#{args[:role_dir]}/#{@software[:name]}.download"

            @dir = "#{@software[:name]}.download"
          end

          def create
            @url.gsub!(/{{ version }}/, @software[:version].to_s)
            @url.gsub!(
              /{{ core_version }}/,
              "#{@software[:version].to_s.split('.')[0]}.#{@software[:version].to_s.split('.')[1]}"
            )

            @download_file.gsub!(/{{ version }}/, @software[:version].to_s)
            @download_file.gsub!(
              /{{ core_version }}/,
              "#{@software[:version].to_s.split('.')[0]}.#{@software[:version].to_s.split('.')[1]}"
            )

            FileUtils.mkdir_p(@role_path)

            create_tasks
            create_vars
          end

          private

          def create_tasks
            FileUtils.cp_r("#{@resource_path}/tasks", @role_path)
          end

          def create_vars
            FileUtils.cp_r("#{@resource_path}/vars", @role_path)

            ::File.open("#{@role_path}/vars/main.yml", 'a') do |f|
              f.puts("src_dir: #{@software[:src_dir]}")
              f.puts("url: #{@url}")
              f.puts("download_file: #{@download_file}")
            end
          end
        end
      end
    end
  end
end