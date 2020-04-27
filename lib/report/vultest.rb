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

require 'lib/report/base'
require 'lib/report/section/attack'
require 'lib/report/section/vulenv'
require 'lib/report/section/vulnerability'

module Report
  class Vultest < Base
    attr_reader :cve, :vulenv, :attack_env

    def initialize(args)
      super(args[:report_dir])

      @vulenv = args[:vulenv]
      @attack_env = args[:attack_env]

      @cve = vulenv.cve
    end

    private

    def report_details
      sections = []
      sections.push("# Vultest Report\n\n")
      sections.push(create_vulenv_section)
      sections.push(create_attack_section)
      sections.push(create_vulnerability_section)

      sections
    end

    def create_vulenv_section
      section = Section::Vulenv.new(vulenv: vulenv)
      section.create
    end

    def create_attack_section
      section = Section::Attack.new(attack_env: attack_env)
      section.create
    end

    def create_vulnerability_section
      section = Section::Vulnerability.new(cve: cve)
      section.create
    end
  end
end