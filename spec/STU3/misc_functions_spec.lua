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
local get_fhir_definition = require("fhirformats").get_fhir_definition
local cjson = require("cjson")
local xml = require("xml")
local inspect = require("inspect")

describe("get_fhir_definition() suite", function()
  it("should return a value for an available element", function()
      local data = get_fhir_definition('Patient', 'animal', 'species')
      assert.same(data._min, 1)
      assert.same(data._max, '1')
      assert.same(data._type, 'CodeableConcept')
      assert.same(data._type_json, nil)
      assert.same(data._kind, nil)
  end)

  it("should return the proper type_json number value", function()
      local data = get_fhir_definition('positiveInt', 'value')
      assert.same(data._type_json, 'number')
  end)

  it("should return a type_json string value", function()
      local data = get_fhir_definition('id', 'value')
      assert.same(data._type_json, 'string')
  end)

  it("should return a kind 'primitive-type' value", function()
      local data = get_fhir_definition('positiveInt')
      assert.same(data._kind, 'primitive-type')
  end)

  it("should return a kind 'Resource' value", function()
      local data = get_fhir_definition('CodeSystem')
      assert.same(data._kind, 'resource')
  end)

  it("should return a kind 'complex-type' value", function()
      local data = get_fhir_definition('Quantity')
      assert.same(data._kind, 'complex-type')
  end)

  it("should return nil for an invalid element", function()
      local data = get_fhir_definition('NotExistingElement')
      assert.same(data, nil)
  end)
end)