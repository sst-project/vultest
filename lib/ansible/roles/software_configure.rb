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

module Ansible
  module Roles
    class SoftwareConfigure
      def initialize(args)
        @role_dir = args[:role_dir]

        @software = {
          name: args[:software_name],
          version: args[:software_version],
          src_dir: args[:software_src_dir],
          configure: args[:software_configure]
        }
      end

      def create
        FileUtils.mkdir_p("#{@role_dir}/#{@software[:name]}.configure")

        FileUtils.cp_r(
          "#{ANSIBLE_ROLES_TEMPLATE_PATH}/software.configure/tasks",
          "#{@role_dir}/#{@software[:name]}.configure"
        )

        FileUtils.cp_r(
          "#{ANSIBLE_ROLES_TEMPLATE_PATH}/software.configure/vars",
          "#{@role_dir}/#{@software[:name]}.configure"
        )

        File.open("#{@role_dir}/#{@software[:name]}.configure/vars/main.yml", 'a') do |f|
          f.puts("src_dir: #{@software[:src_dir]}/#{@software[:name]}-#{@software[:version]}")
          f.puts("configure: #{@software[:configure]}")
        end
      end
    end
  end
end
