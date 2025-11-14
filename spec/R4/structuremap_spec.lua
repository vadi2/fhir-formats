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

describe("StructureMap with nested rules - xml to json", function()
    local step7a_json, step_my_json

    setup(function()
        io.input("spec/R4/step7a.xml")
        local step7a_xml = io.read("*a")
        step7a_json = in_fhir_json(step7a_xml, {fhirversion = "R4"})

        io.input("spec/R4/step-my.xml")
        local step_my_xml = io.read("*a")
        step_my_json = in_fhir_json(step_my_xml, {fhirversion = "R4"})
    end)

    it("should convert step7a.xml without errors", function()
        assert.is_not_nil(step7a_json)
        local data = cjson.decode(step7a_json)
        assert.equal("StructureMap", data.resourceType)
        assert.equal("tutorial-step7a", data.id)
    end)

    it("should have nested rule with correct structure in step7a", function()
        local data = cjson.decode(step7a_json)
        assert.is_not_nil(data.group)
        assert.is_not_nil(data.group[1].rule)
        assert.is_not_nil(data.group[1].rule[1].rule)

        -- Check nested rule has arrays for source and target
        local nested_rule = data.group[1].rule[1].rule[1]
        assert.equal("rule_ab", nested_rule.name)
        assert.is_table(nested_rule.source)
        assert.is_table(nested_rule.target)
        assert.equal("s_aa", nested_rule.source[1].context)
        assert.equal("t_aa", nested_rule.target[1].context)
    end)

    it("should convert step-my.xml without errors", function()
        assert.is_not_nil(step_my_json)
        local data = cjson.decode(step_my_json)
        assert.equal("StructureMap", data.resourceType)
    end)

    it("should handle deeply nested rules in step-my", function()
        local data = cjson.decode(step_my_json)
        assert.is_not_nil(data.group)
        assert.is_not_nil(data.group[1].rule)

        -- Find a rule with nested rules
        local found_nested = false
        for _, rule in ipairs(data.group[1].rule) do
            if rule.rule then
                found_nested = true
                -- Nested rule should have proper structure
                for _, nested_rule in ipairs(rule.rule) do
                    if nested_rule.source then
                        assert.is_table(nested_rule.source)
                    end
                    if nested_rule.target then
                        assert.is_table(nested_rule.target)
                    end
                end
            end
        end
        assert.is_true(found_nested, "Should have found at least one nested rule")
    end)

    it("should match HAPI server output for step7a", function()
        io.input("spec/R4/step7a.json")
        local hapi_json = io.read("*a")
        local hapi_data = cjson.decode(hapi_json)
        local our_data = cjson.decode(step7a_json)

        -- Remove id field for comparison (HAPI adds server-generated IDs)
        our_data.id = nil

        -- Compare structure
        assert.same(hapi_data, our_data)
    end)
end)

describe("StructureMap with nested rules - json to xml", function()
    local step7a_xml, step_my_xml

    setup(function()
        io.input("spec/R4/step7a.xml")
        local original_xml = io.read("*a")
        local json_version = in_fhir_json(original_xml, {fhirversion = "R4"})
        step7a_xml = in_fhir_xml(json_version, {fhirversion = "R4"})

        io.input("spec/R4/step-my.xml")
        original_xml = io.read("*a")
        json_version = in_fhir_json(original_xml, {fhirversion = "R4"})
        step_my_xml = in_fhir_xml(json_version, {fhirversion = "R4"})
    end)

    it("should round-trip step7a without data loss", function()
        assert.is_not_nil(step7a_xml)
        -- Convert back to JSON to compare structure
        local json_again = in_fhir_json(step7a_xml, {fhirversion = "R4"})
        assert.is_not_nil(json_again)
        local data = cjson.decode(json_again)
        assert.equal("tutorial-step7a", data.id)
        assert.is_not_nil(data.group[1].rule[1].rule)
    end)

    it("should round-trip step-my without data loss", function()
        assert.is_not_nil(step_my_xml)
        -- Convert back to JSON to compare structure
        local json_again = in_fhir_json(step_my_xml, {fhirversion = "R4"})
        assert.is_not_nil(json_again)
        local data = cjson.decode(json_again)
        assert.equal("StructureMap", data.resourceType)
    end)
end)
