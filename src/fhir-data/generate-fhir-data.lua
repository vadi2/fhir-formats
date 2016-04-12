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

local from_json = require("cjson").decode
local pretty = require "resty.prettycjson"

local default_file = "fhir-elements.json"

local function read_json(filename)
  io.input(filename)
  return from_json(io.read("*a"))
end

-- capitalise first letter only, leaving rest intact
function string.title(word)
  return word:gsub("(%a)([%w_']*)", function (first, rest)
      return first:upper()..rest
    end)
end

-- handles a choice of types by expanding them all in place
local function handle_choice(output, element)
  for _, type in ipairs(element.type) do
    output[#output+1] = {path = element.path:gsub("%[x%]", type.code:title()), type = type.code, min = tostring(element.min), max = tostring(element.max)}
  end

  return output
end

-- handles a simple element
local function handle_simple(output, element)
  local path, type, type_json, type_xml, min, max

  -- in case there's no type - such as Element itself
  if element.type then
    type = element.type[1].code

    -- if it's a primitive, save its xml and json representation
    if element.type[1]._code and element.type[1]._code.extension then
      for _, extension in ipairs(element.type[1]._code.extension) do
        if extension.url == "http://hl7.org/fhir/StructureDefinition/structuredefinition-json-type" then
          type_json = extension.valueString
        elseif extension.url == "http://hl7.org/fhir/StructureDefinition/structuredefinition-xml-type" then
          type_xml = extension.valueString
        end
      end
    end
  end

  local min = tostring(element.min)
  local max = element.max
  output[#output+1] = {path = element.path, type = type, min = min, max = max, type_xml = type_xml, type_json = type_json}

  return output
end

local function parse_data(data, output, resources_map)

  for _, datatype_root in ipairs(data.entry) do
    if datatype_root.resource.resourceType == "StructureDefinition" then
      for i, element in ipairs(datatype_root.resource.snapshot.element) do
        -- if this is a choice, expand all the possibilities in place
        if element.path:find("[x]", -3, true) then
          output = handle_choice(output, element)
        else
          output = handle_simple(output, element)
        end

        if i == 1 then
          local latest_element = output[#output]
          resources_map[latest_element.path] = latest_element
        end
      end
    end
  end

  return output, resources_map
end

local function save(output)
  io.output(default_file)
  io.write(pretty(output))
  io.close()
end

-- create links from resources to their parents, so we can handle
-- Element.contained.Element, where Element is something that
-- derives from Resource
local function update_backlinks(resources_map)
  for resource_name, resource in pairs(resources_map) do
    local parent = resources_map[resource.type]
    if parent then -- Element has no parent
      parent.derivations = parent.derivations or {}
      parent.derivations[#parent.derivations+1] = resource_name
    end
  end
end

local output, resources_map = {}, {}
output, resources_map = parse_data(read_json("profiles-types.json"), output, resources_map)
output, resources_map = parse_data(read_json("profiles-resources.json"), output, resources_map)

update_backlinks(resources_map)

save(output)
