--[[
  FHIR Formats

  Copyright (C) 2016-2017 Vadim Peretokin

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
local function handle_choice(output, element, weight_counter)
  for _, type in ipairs(element.type) do
    output[#output+1] = {
      path = element.path:gsub("%[x%]", type.code:title()),
      type = type.code,
      min = element.min,
      max = tostring(element.max),
      weight = weight_counter
    }
  end

  return output
end

-- handles a simple element
local function handle_simple(output, element, weight_counter, resource_type, resource_kind)
  local path, type, type_json, type_xml, min, max

  -- in case there's no type - such as Element itself
  if element.type then
    type = element.type[1].code

    -- if it's a primitive, save its xml and json representation
    if element.type[1]._code and element.type[1]._code.extension then
      for _, extension in ipairs(element.type[1]._code.extension) do
        if extension.url == "http://hl7.org/fhir/StructureDefinition/structuredefinition-json-type" then
          type_json = extension.valueString
          if type_json == "true | false" then type_json = "boolean" end
        elseif extension.url == "http://hl7.org/fhir/StructureDefinition/structuredefinition-xml-type" then
          type_xml = extension.valueString
        end
      end
    end
  end

  -- since 1.6.0, resource types aren't shown in the first element anymore - so get those from the baseDefinition
  type = type or resource_type

  min = element.min
  max = tostring(element.max)
  output[#output+1] = {
    path = element.path,
    type = type,
    kind = resource_kind,
    min = min,
    max = max,
    type_xml = type_xml,
    type_json = type_json,
    weight = weight_counter
  }

  return output
end

local function parse_data(data, output, resources_map, weight_counter)

  for _, datatype_root in ipairs(data.entry) do
    if datatype_root.resource.resourceType == "StructureDefinition" then
      -- ignore derivations of a type that only add validation rules, like Money for Quantity
      if datatype_root.resource.id == datatype_root.resource.snapshot.element[1].path then

        -- since 1.6.0, resource type is not shown in the first element anymore - so deduce it from the baseDefition URL
        local resource_type
        if datatype_root.resource.baseDefinition then -- Element itself doesn't have a baseDefinition
          resource_type = datatype_root.resource.baseDefinition:match("http://hl7.org/fhir/StructureDefinition/(%w+)")
        end

        -- save the resource kind as well - ie 'resource', 'complex-type' (for datatypes), and so on
        local resource_kind
        if datatype_root.resource.kind then
          resource_kind = datatype_root.resource.kind
        end

        for i, element in ipairs(datatype_root.resource.snapshot.element) do
          -- if this is a choice, expand all the possibilities in place
          if element.path:find("[x]", -3, true) then
            output = handle_choice(output, element, weight_counter)
          else
            output = handle_simple(output, element, weight_counter, (i == 1 and resource_type or nil), (i == 1 and resource_kind or nil))
          end

          if i == 1 then
            local latest_element = output[#output]
            resources_map[latest_element.path] = latest_element
          end

          weight_counter = weight_counter + 1
        end
      end
    end
  end

  return output, resources_map, weight_counter
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
      table.sort(parent.derivations) -- TODO: optimise this outside of the loop
    end
  end
end

-- output is the data store for the resources so far
-- resources_map is used to compute derivations (who extends Resource and then DomainResource)
-- weight_counter is for sorting elements for the XML format
local output, resources_map, weight_counter = {}, {}, 1
output, resources_map, weight_counter = parse_data(read_json("profiles-types.json"), output, resources_map, weight_counter)
output, resources_map, weight_counter = parse_data(read_json("profiles-resources.json"), output, resources_map, weight_counter)

update_backlinks(resources_map)

save(output)
