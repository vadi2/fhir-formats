# FHIR Formats

# Copyright (C) 2016 Vadim Peretokin

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#      http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

rm *.json

# September 2016 snapshot
wget http://hl7.org/fhir/2016Sep/profiles-types.json
wget http://hl7.org/fhir/2016Sep/profiles-resources.json

# Latest Continuous Build
# wget http://hl7-fhir.github.io/profiles-resources.json
# wget http://hl7-fhir.github.io/profiles-types.json
