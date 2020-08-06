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
require 'lib/print'

module Command
  module Report
    class << self
      def exec(args)
        core = args[:core]
        report_dir = args[:report_dir]

        if core.nil?
          Print.error('There is no a vulnerable environment')
          return
        end

        core.create_report(report_dir: report_dir)

        # Print.error('Execute exploit command')
      end
    end
  end
end