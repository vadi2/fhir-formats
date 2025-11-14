--[[
  FHIR Formats

  Copyright (C) 2025 Vadim Peretokin

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
]]

package.path = "src/?.lua;"..package.path
local get_fhir_definition = require("fhirformats").get_fhir_definition

describe("R5 FHIR definition lookup", function()
    it("should load R5 schema and find Patient resource", function()
        local patient_def = get_fhir_definition('Patient', 'R5')
        assert.is_not_nil(patient_def)
        assert.equal('resource', patient_def._kind)
      end)

    it("should find Patient.contact element in R5", function()
        local contact_def = get_fhir_definition('Patient', 'contact', 'R5')
        assert.is_not_nil(contact_def)
      end)
  end)
