# Copyright [2019] [University of Aizu]
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

require_relative './local'
require_relative './user'
require_relative './related_software'
require_relative './vul_software'
require_relative './content'
require_relative './prepare'
require_relative '../../ui'

module Const
  include Local
  include User
  include RelatedSoftware
  include VulSoftware
  include Content
  include Prepare
end
