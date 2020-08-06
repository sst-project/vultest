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
require 'erb'
require 'fileutils'

module Ansible
  module Roles
    module User
      class << self
        def create(args)
          role_dir = args[:role_dir]
          user = args[:user]
          create_tasks(role_dir, user)
          create_vars(role_dir, user)
        end

        private

        def create_tasks(role_dir, user)
          FileUtils.mkdir_p("#{role_dir}/#{user}-user/tasks")
          erb = ERB.new(
            File.read("#{ANSIBLE_ROLES_TEMPLATE_PATH}/user/tasks/main.yml.erb"),
            trim_mode: 2
          )

          File.open("#{role_dir}/#{user}-user/tasks/main.yml", 'w') do |f|
            f.puts(erb.result(binding))
          end
        end

        def create_vars(role_dir, user)
          FileUtils.mkdir_p("#{role_dir}/#{user}-user/vars")
          erb = ERB.new(
            File.read("#{ANSIBLE_ROLES_TEMPLATE_PATH}/user/vars/main.yml.erb"),
            trim_mode: 2
          )

          File.open("#{role_dir}/#{user}-user/vars/main.yml", 'w') do |f|
            f.puts(erb.result(binding))
          end
        end
      end
    end
  end
end