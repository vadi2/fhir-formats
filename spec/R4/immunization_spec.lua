--[[
  FHIR Formats

  Copyright (C) 2022 Vadim Peretokin

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
    local positive_example, negative_example, immunization_example,
    positive_example_data, immunization_example_data

    setup(function()
        io.input("spec/R4/immunization-example.json")
        positive_example_data = io.read("*a")
        immunization_example_data = in_fhir_json("spec/R4/immunization-example.xml", {file = true}, "R4")

        -- for same div data test
        assert:set_parameter("TableFormatLevel", -1)
      end)

    before_each(function()
        positive_example = cjson.decode(positive_example_data)
        immunization_example = cjson.decode(immunization_example_data)
      end)

    it("should have the same non-div data", function()
        -- cut out the div's, since the whitespace doesn't matter as much in xml
        positive_example.text.div = nil
        immunization_example.text.div = nil
        assert.same(positive_example, immunization_example)
      end)

    it("should have xml-comparable div data", function()
        local positive_example_div = xml.load(positive_example.text.div)
        local immunization_example_div = xml.load(immunization_example.text.div)
        --print(inspect(positive_example_div))
        --print(inspect(immunization_example_div))
        assert.same(positive_example_div, immunization_example_div)
      end)
  end)

describe("json to xml", function()
    local positive_example, negative_example, immunization_example,
    positive_example_data, immunization_example_data

    setup(function()
        io.input("spec/R4/immunization-example.xml")
        positive_example_data = io.read("*a")
        immunization_example_data = in_fhir_xml("spec/R4/immunization-example.json", {file = true}, "R4")

        -- for same div data test
        assert:set_parameter("TableFormatLevel", -1)
      end)

    it("should have the same data", function()
        -- convert it down to JSON since order of elements doesn't matter in JSON, while it does in XML
        assert.same(cjson.decode(in_fhir_json(positive_example_data, nil, "R4")), cjson.decode(in_fhir_json(immunization_example_data, nil, "R4")))
      end)
  end)
