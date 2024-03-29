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

describe("auto-version xml to json", function()
    local positive_example, negative_example, immunization_example,
    positive_example_data, immunization_example_data

    setup(function()
        io.input("spec/R4/stu3-immunization.json")
        positive_example_data = io.read("*a")
        immunization_example_data = in_fhir_json("spec/R4/stu3-immunization.xml", {file = true, fhirversion = "auto"})

        -- for same div data test
        assert:set_parameter("TableFormatLevel", -1)
      end)

    before_each(function()
        positive_example = cjson.decode(positive_example_data)
        immunization_example = cjson.decode(immunization_example_data)
      end)

    it("should have the same non-div data", function()
        assert.same(positive_example, immunization_example)
      end)
  end)

describe("auto-version json to xml", function()
    local positive_example, negative_example, immunization_example,
    positive_example_data, immunization_example_data

    setup(function()
        io.input("spec/R4/stu3-immunization.xml")
        positive_example_data = io.read("*a")
        immunization_example_data = in_fhir_xml("spec/R4/stu3-immunization.json", {file = true, fhirversion = "auto"})

        -- for same div data test
        assert:set_parameter("TableFormatLevel", -1)
      end)

    it("should have the same data, order included", function()
        assert.same(positive_example_data, immunization_example_data)
      end)
  end)
