--[[
  FHIR Formats

  Copyright (C) 2016 Vadim Peretokin

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

describe("xml to json", function()
    local positive_example, negative_example, patient_example,
    positive_example_data, patient_example_data

    setup(function()
        io.input("spec/patient-example-good.json")
        positive_example_data = io.read("*a")
        patient_example_data = in_fhir_json("spec/patient-example.xml", {file = true})

        -- for same div data test
        assert:set_parameter("TableFormatLevel", -1)
      end)

    before_each(function()
        positive_example = cjson.decode(positive_example_data)
        patient_example = cjson.decode(patient_example_data)
      end)

    it("should have the same non-div data", function()
        -- cut out the div's, since the whitespace doesn't matter as much in xml
        positive_example.text.div = nil
        patient_example.text.div = nil
        assert.same(positive_example, patient_example)
      end)

    it("should have xml-comparable div data", function()
        local positive_example_div = xml.load(positive_example.text.div)
        local patient_example_div = xml.load(patient_example.text.div)
        --print(inspect(positive_example_div))
        --print(inspect(patient_example_div))
        assert.same(positive_example_div, patient_example_div)
      end)
  end)

describe("json to xml", function()
    local positive_example, negative_example, patient_example,
    positive_example_data, patient_example_data

    setup(function()
        io.input("spec/patient-example.xml")
        positive_example_data = io.read("*a")
        patient_example_data = in_fhir_xml("spec/patient-example-good.json", {file = true})

        -- for same div data test
        assert:set_parameter("TableFormatLevel", -1)
      end)

    it("should have the same data", function()
        -- convert it down to JSON since order of elements doesn't matter in JSON, while it does in XML
        assert.same(cjson.decode(in_fhir_json(positive_example_data)), cjson.decode(in_fhir_json(patient_example_data)))
      end)
  end)