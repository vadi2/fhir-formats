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

local in_fhir_json = require("fhirformats").to_json
local in_fhir_xml = require("fhirformats").to_xml
local cjson = require("cjson")
local xml = require("xml")
local inspect = require("inspect")
local tablex = require("pl.tablex")

local data = {
  {"json-edge-cases.json", "json-edge-cases.xml"},
  {"patient-example-good.json", "patient-example.xml"}
}

for _, testcase in ipairs(data) do
  local json_file = testcase[1]
  local xml_file = testcase[2]
  local case_name = json_file:gsub("%.json", '')

  describe(case_name.." xml to json", function()
      -- do the setup outside of setup(), as setup() can't handle creating it()'s within it
      local t = {}
      io.input("spec/"..json_file)
      t.json_data = io.read("*a")
      t.xml_data = in_fhir_json("spec/"..xml_file, {file = true})

      t.json_example = cjson.decode(t.json_data)
      t.xml_example = cjson.decode(t.xml_data)

      t.keys_in_both_tables = tablex.keys(tablex.merge(t.json_example, t.xml_example))
      -- for same div data test
      assert:set_parameter("TableFormatLevel", -1)

      for _, key in ipairs(t.keys_in_both_tables) do
        it("should have the same "..key.." objects", function()
            -- cut out the div's, since the whitespace doesn't matter as much in xml
            t.json_example.text.div = nil
            t.xml_example.text.div = nil
            assert.same(t.json_example[key], t.xml_example[key])
          end)
      end

      before_each(function()
          t.json_example = cjson.decode(t.json_data)
          t.xml_example = cjson.decode(t.xml_data)
        end)


      pending("should have xml-comparable div data", function()
          local json_example_div = xml.load(t.json_example.text.div)
          local xml_example_div = xml.load(t.xml_example.text.div)
          assert.same(json_example_div, xml_example_div)
        end)
    end)



  describe(case_name.. " json to xml", function()
      local t = {}

      setup(function()
          io.input("spec/"..xml_file)
          t.xml_data = io.read("*a")
          t.json_data = in_fhir_xml("spec/"..json_file, {file = true})

          -- for same div data test
          assert:set_parameter("TableFormatLevel", -1)
        end)

      it("should have the same data", function()
          -- convert it down to JSON since order of elements doesn't matter in JSON, while it does in XML
          assert.same(cjson.decode(in_fhir_json(t.xml_data)), cjson.decode(in_fhir_json(t.json_data)))
        end)
    end)
end