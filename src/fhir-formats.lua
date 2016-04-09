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

local xml = require("xml")
local prettyjson = require "resty.prettycjson"
local cjson = require "cjson"
local ipairs, pairs, type, print, tonumber, gmatch
= ipairs, pairs, type, print, tonumber, string.gmatch

local get_fhir_definition, read_fhir_data, getindex, map_fhir_data, fhir_typed
local get_json_datatype, print_data_for_node, convert_to_lua_from_xml, handle_div
local convert_to_json, file_exists, read_xml, read_xml_file, make_json_datatype

local _M = {}

local fhir_data

-- credit: http://stackoverflow.com/a/4991602/72944
file_exists = function(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

read_fhir_data = function(filename)
  -- credit to http://lua-users.org/lists/lua-l/2010-04/msg00693.html
  local path = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]]
  
  -- prefer the filename, but substitute the nil if not given
  local locations = {(filename or ""), "fhir-data/fhir-elements.json", "src/fhir-data/fhir-elements.json", "../src/fhir-data/fhir-elements.json", path.."fhir-data/fhir-elements.json"}
  local data

  for _, file in ipairs(locations) do
    if file_exists(file) then
      io.input(file)
      data = cjson.decode(io.read("*a"))
    end
  end

  assert(data, string.format("read_fhir_data: FHIR Schema could not be found in these locations:\n  %s", table.concat(locations, " ")))
  return data
end

-- returns the index of the value in a list
getindex = function(list, value)
  for i = 1, #list do
    if list[i] == value then return i end
  end
end

-- return a map with the path (as string) and an array or list for the JSON element to create
map_fhir_data = function(raw_fhir_data)
  local fhir_data = {}

  local function parse_element(element)
    local previouselement = fhir_data
    for word in gmatch(element.path, "([^%.]+)") do
      previouselement[word] = previouselement[word] or {}
      previouselement = previouselement[word]
    end
    previouselement._max = element.max
    previouselement._type = element.type
    previouselement._type_json = element.type_json

    if type(fhir_data[element.type]) == "table" then
      previouselement[1] = fhir_data[element.type]
    end
  end

  -- parse once to ensure all datatypes are in
  for i = 1, #raw_fhir_data do
    local element = raw_fhir_data[i]
    parse_element(element)
  end

  -- parse again to ensure all resources are in
  for i = 1, #raw_fhir_data do
    local element = raw_fhir_data[i]
    parse_element(element)
  end

  return fhir_data
end

read_xml = function(filecontent)
  return xml.load(filecontent)
end

read_xml_file = function(filename)
  io.input(filename)
  local filecontent = io.read("*a")
  io.input():close()

  return xml.load(filecontent)
end

-- returns FHIR JSON-typed version of the input
-- input: a node with an xml and a value key
-- output: JSON-typed node.value
fhir_typed = function(output_stack, node)
  local value = node.value

  local fhir_definition = get_fhir_definition(output_stack, node.xml)
  local json_type = fhir_definition._type or fhir_definition._type_json

  if json_type == "boolean" then
    if node.value == "true" then return true
    elseif node.value == "false" then return false
    else
      print(string.format("Warning: %s.%s is of type %s in FHIR JSON - its XML value of %s is invalid.", table.concat(output_stack), node.xml, json_type, node.value))
    end
  elseif json_type == "number" then return tonumber(node.value)
  else return value
  end
end

-- given an element and a path to it, returns the FHIR definition from
-- the FHIR schema
get_fhir_definition = function (output_stack, element_to_check)
  local fhir_data_pointer

  -- +1 since element_to_checkk; isn't on the stack
  for i = 1, #output_stack+1 do
    local element = (output_stack[i] or element_to_check)

    if not fhir_data_pointer then
      fhir_data_pointer = fhir_data[element]
    elseif fhir_data_pointer[element] then
      fhir_data_pointer = fhir_data_pointer[element]
    elseif fhir_data_pointer[1] then
      fhir_data_pointer = fhir_data_pointer[1][element]
    else
      fhir_data_pointer = nil
      break -- bail out of the for loop if we didn't find the element we're looking for
    end
  end

  return fhir_data_pointer
end

make_json_datatype = function(output_stack, element_to_check)
  local newtable, pointer_inside_table

  local fhir_definition = get_fhir_definition(output_stack, element_to_check)

  if not fhir_definition then
    print(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.", table.concat(output_stack, "."), element_to_check))
  end

  if fhir_definition and fhir_definition._max == "*" then
    newtable = {{}}
    pointer_inside_table = newtable[1]
  else
    newtable = {}
    pointer_inside_table = newtable
  end

  return newtable, pointer_inside_table
end


get_json_datatype = function(output_stack, element_to_check)
  local fhir_data_pointer

  -- +1 since nodexml isn't on the stack
  for i = 1, #output_stack+1 do
    local element = (output_stack[i] or element_to_check)

    if not fhir_data_pointer then
      fhir_data_pointer = fhir_data[element]
    elseif fhir_data_pointer[element] then
      fhir_data_pointer = fhir_data_pointer[element]
    elseif fhir_data_pointer[1] then
      fhir_data_pointer = fhir_data_pointer[1][element]
    else
      fhir_data_pointer = nil
      break -- bail out of the for loop if we didn't find the element we're looking for
    end
  end

  if fhir_data_pointer == nil then
    print(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.", table.concat(output_stack, "."), element_to_check))
  end

  if fhir_data_pointer and fhir_data_pointer._max == "*" then
    return "array"
  end

  return "object"
end

print_data_for_node = function(node, level, output, output_levels, output_stack)
  assert(node.xml, "error from parsed xml: node.xml is missing")
  local previouslevel = level - 1

  -- in JSON, resource type is embedded within the object.resourceType,
  -- unlike at root level in FHIR XML
  if level == 1 then
    output.resourceType = node.xml
  elseif node.value then
    -- if we're processing a primitive value, add it to the right place
    -- in output{}. Right place is given to us by looking at the last
    -- place in the 2D stack
    if not output_levels[previouslevel][#output_levels[previouslevel]][node.xml] then
      output_levels[previouslevel][#output_levels[previouslevel]][node.xml] = (get_json_datatype(output_stack, node.xml) == "array" and {fhir_typed(output_stack, node)} or fhir_typed(output_stack, node))
    else -- if there's something there already, then that means we have more values for the array
      local existing_array = output_levels[previouslevel][#output_levels[previouslevel]][node.xml]

      existing_array[#existing_array+1] = fhir_typed(output_stack, node)

      -- add a null to the corresponding _ prefix if it's there
      local _value = output_levels[previouslevel][#output_levels[previouslevel]]["_"..node.xml]
      if _value then
        _value[#_value+1] = cjson.null
      end
    end
  elseif node.xmlns then
    -- no namespaces in JSON, for now just eat the value
  end

  -- embedded table - create a table in the output and add it to the right place
  -- in the output_stack, so when we're inserting the primitive values above,
  -- we know which table to add the value to
  if type(node[1]) == "table"
  and level ~= 1 then -- don't create another table for level 1, since in FHIR JSON the
    -- resource name is 'inside' as a resourceType property

    local newtable, pointer_inside_table

    -- if this is a recurring XML element, and not an embedded id or extension,
    -- create another array in an existing array for it (TODO: fix this mess with below)
    if type(output_levels[previouslevel][#output_levels[previouslevel]][node.xml]) == "table"
    and not (level ~= 1 and node[1] and (node[1].xml == "id" or node[1].xml == "extension")) then
      local existing_array = output_levels[previouslevel][#output_levels[previouslevel]][node.xml]
      existing_array[#existing_array+1] = {}
      pointer_inside_table = existing_array[#existing_array]
    elseif not output_levels[previouslevel][#output_levels[previouslevel]][node.xml] then
      -- create a new table in output using our stack pointer, if we
      -- haven't created already - could've been created by node.value above
      -- and what we're now looking at is an extension within
      newtable, pointer_inside_table = make_json_datatype(output_stack, node.xml)
      output_levels[previouslevel][#output_levels[previouslevel]][node.xml] = newtable
    end


    -- if it's an id or an extension element of a datatype, create a fix with a _ prefix for it
    if level ~= 1 and node[1] and (node.id or node[1].xml == "extension") then
      newtable, pointer_inside_table = make_json_datatype(output_stack, node.xml)
      output_levels[previouslevel][#output_levels[previouslevel]]['_'..node.xml] = newtable

      -- see if we need to pad the _value table out with null's in case we've got
      -- multiple values (https://hl7-fhir.github.io/json.html#primitive)
      local pos = getindex(output_levels[previouslevel][#output_levels[previouslevel]][node.xml], node.value)
      if pos and pos > 1 then
        newtable[1] = nil -- remove the first {} that json_object_or_array added, as we need to pre-pad
        for _ = 1, pos-1 do
          newtable[#newtable+1] = cjson.null
        end
        newtable[#newtable+1] = {} -- re-insert the first {} deleted earlier
        pointer_inside_table = newtable[#newtable]
      end
    end

    -- update stack with a pointer to the table we made above
    output_levels[level] = output_levels[level] or {}
    output_levels[level][#output_levels[level]+1] = pointer_inside_table
  end


  -- lastly, handle extension URLs by creating them not at the current level, but at the
  -- nested level down as FHIR JSON likes it
  if node.url then
    output_levels[level][#output_levels[level]].url = node.url
  end

  return output
end

handle_div = function(output_levels, node, level)
  output_levels[level][#output_levels[level]][node.xml] = xml.dump(node)
end

convert_to_lua_from_xml = function(xml_data, level, output, output_levels, output_stack)
  -- level is the nesting level inside raw xml_data from our xml parser
  level = (level and (level+1) or 1)

  output = print_data_for_node(xml_data, level, output, output_levels, output_stack)

  output_stack[#output_stack+1] = xml_data.xml
  for _, value in ipairs(xml_data) do
    if value.xml == "div" and value.xmlns == "http://www.w3.org/1999/xhtml" then
      handle_div(output_levels, value, level)
    else
      assert(type(value) == "table", string.format("unexpected type value encountered: %s (%s), expecting table", tostring(value), type(value)))
      convert_to_lua_from_xml(value, level, output, output_levels, output_stack)
    end
  end
  table.remove(output_stack)

  return output
end

convert_to_json = function(data, options)
  fhir_data = fhir_data or map_fhir_data(read_fhir_data())

  assert(next(fhir_data), "convert_to_json: FHIR Schema could not be parsed in.")

  local xml_data
  if options and options.file then
    xml_data = read_xml_file(data)
  else
    xml_data = read_xml(data)
  end

  local output = {}
  local output_levels = {[1] = {output}}
  local output_stack = {}

  local data_in_lua = convert_to_lua_from_xml(xml_data, nil, output, output_levels, output_stack)

  return (options and options.pretty) and prettyjson(data_in_lua)
  or cjson.encode(data_in_lua)
end

_M.to_json = convert_to_json
return _M
