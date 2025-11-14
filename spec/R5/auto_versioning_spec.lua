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
local in_fhir_json = require("fhirformats").to_json
local in_fhir_xml = require("fhirformats").to_xml
local cjson = require("cjson")
local xml = require("xml")
local inspect = require("inspect")

describe("R5 auto-version xml to json", function()
    local positive_example, patient_example,
    positive_example_data, patient_example_data

    setup(function()
        io.input("spec/R5/patient-example.json")
        positive_example_data = io.read("*a")
        -- Use auto versioning - should detect R5
        patient_example_data = in_fhir_json("spec/R5/patient-example.xml", {file = true, fhirversion = "auto"})

        -- for same div data test
        assert:set_parameter("TableFormatLevel", -1)
      end)

    before_each(function()
        positive_example = cjson.decode(positive_example_data)
        patient_example = cjson.decode(patient_example_data)
      end)

    it("should auto-detect R5 and have the same non-div data", function()
        -- cut out the div's, since the whitespace doesn't matter as much in xml
        positive_example.text.div = nil
        patient_example.text.div = nil
        assert.same(positive_example, patient_example)
      end)
  end)

describe("R5 auto-version json to xml", function()
    local positive_example, patient_example,
    positive_example_data, patient_example_data

    setup(function()
        io.input("spec/R5/patient-example.xml")
        positive_example_data = io.read("*a")
        -- Use auto versioning - should detect R5
        patient_example_data = in_fhir_xml("spec/R5/patient-example.json", {file = true, fhirversion = "auto"})

        -- for same div data test
        assert:set_parameter("TableFormatLevel", -1)
      end)

    it("should auto-detect R5 and have the same data", function()
        -- convert it down to JSON since order of elements doesn't matter in JSON, while it does in XML
        assert.same(
          cjson.decode(in_fhir_json(positive_example_data, {fhirversion = "auto"})),
          cjson.decode(in_fhir_json(patient_example_data, {fhirversion = "auto"})))
      end)
  end)
