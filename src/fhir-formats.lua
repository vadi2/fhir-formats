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
local prettyjson = require("resty.prettycjson")
local cjson = require("cjson")
local datafile = require("datafile")
local ipairs, pairs, type, print, tonumber, gmatch, tremove, sformat
= ipairs, pairs, type, print, tonumber, string.gmatch, table.remove, string.format

local get_fhir_definition, read_fhir_data, getindex, map_fhir_data, fhir_typed
local get_json_datatype, print_data_for_node, convert_to_lua_from_xml, handle_div
local convert_to_json, file_exists, read_filecontent, read_file, make_json_datatype
local handle_json_recursively, print_simple_datatype, convert_to_lua_from_json
local convert_to_xml, print_complex_datatype

local fhir_data

-- credit: http://stackoverflow.com/a/4991602/72944
file_exists = function(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

read_fhir_data = function(filename)
  -- prefer the filename, but substitute the nil if not given
  local locations = {(filename or ""), "fhir-data/fhir-elements.json", "src/fhir-data/fhir-elements.json", "../src/fhir-data/fhir-elements.json", "fhir-data/fhir-elements.json"}
  local data

  for _, file in ipairs(locations) do
    if file_exists(file) then
      io.input(file)
      data = cjson.decode(io.read("*a"))
    end
  end

  -- if installed as a LuaRock, try the data directory
  if not data then
    local file, err = datafile.open("src/fhir-data/fhir-elements.json", "r")
    data = cjson.decode(file:read("*a"))
  end

  assert(data, string.format("read_fhir_data: FHIR Schema could not be found in these locations nor as a LuaRock data file:\n  %s", table.concat(locations, " ")))
  return data
end

-- returns the index of the value in a list
getindex = function(list, value)
  if not list then return nil end

  for i = 1, #list do
    if list[i] == value then return i end
  end
end

-- returns a list as a key-value map, value can be a value
-- to assign or a function to evaluate before assignment.
-- Function will have the processed list value as first argument
list_to_map = function(list, value)
  if not list then return nil end

  local map = {}

  if type(value) == "function" then
    for i = 1, #list do
      local element = list[i]
      map[element] = value(element)
    end
  else
    for i = 1, #list do
      map[list[i]] = value
    end
  end

  return map
end

-- return a map with the path (as string) and an array or list for the JSON element to create
map_fhir_data = function(raw_fhir_data)
  fhir_data = {}
  local flatten_derivations, parse_element

  parse_element = function(element)
    local previouselement = fhir_data
    for word in gmatch(element.path, "([^%.]+)") do
      previouselement[word] = previouselement[word] or {}
      previouselement = previouselement[word]
    end
    previouselement._max = element.max
    previouselement._type = element.type
    previouselement._type_json = element.type_json
    previouselement._derivations = list_to_map(element.derivations, function(value) return fhir_data[value] end)
    flatten_derivations(previouselement)

    if type(fhir_data[element.type]) == "table" then
      previouselement[1] = fhir_data[element.type]
    end
  end

  flatten_derivations = function(root_element, nested_element)
    if not (root_element and root_element._derivations) then return end

    local derivations = nested_element and nested_element._derivations or root_element._derivations
    for derivation, data in pairs(derivations) do
      if data._derivations then
        for nested_derivation, nested_data in pairs(data._derivations) do
          if root_element ~= nested_data then
            root_element._derivations[nested_derivation] = nested_data

-- TODO: fix me to be recursive and not just one level down
--            flatten_derivations(root_element, nested_data)
          end
        end
      end
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

read_filecontent = function(filecontent, f)
  return f(filecontent)
end

read_file = function(filename, f)
  io.input(filename)
  local filecontent = io.read("*a")
  io.input():close()

  return f(filecontent)
end

-- returns FHIR JSON-typed version of the input
-- input: a node with an xml and a value key
-- output: JSON-typed node.value
fhir_typed = function(output_stack, node)
  local value = node.value

  local fhir_definition = get_fhir_definition(output_stack, node.xml)

  if not fhir_definition then
    print(string.format("Warning: %s is not a known FHIR element; couldn't check its FHIR type to decide the JSON type.", table.concat(output_stack, ".")))
    return value
  end

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

  if element_to_check == "id" and output_stack[#output_stack] == "Organization" then
    print()
  end

  -- +1 since element_to_checkk; isn't on the stack
  for i = 1, #output_stack+1 do
    local element = (output_stack[i] or element_to_check)

    if not fhir_data_pointer then
      fhir_data_pointer = fhir_data[element]
    elseif fhir_data_pointer[element] then
      fhir_data_pointer = fhir_data_pointer[element]
    elseif fhir_data_pointer[1] then
      fhir_data_pointer = fhir_data_pointer[1][element] or fhir_data_pointer[1]._derivations[element]
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
  local fhir_data_pointer = get_fhir_definition(output_stack, element_to_check)

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
    -- elseif node.xmlns then
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
  tremove(output_stack)

  return output
end

convert_to_json = function(data, options)
  fhir_data = fhir_data or map_fhir_data(read_fhir_data())

  assert(next(fhir_data), "convert_to_json: FHIR Schema could not be parsed in.")

  local xml_data
  if options and options.file then
    xml_data = read_file(data, xml.load)
  else
    xml_data = read_filecontent(data, xml.load)
  end

  local output = {}
  local output_levels = {[1] = {output}}
  local output_stack = {}

  local data_in_lua = convert_to_lua_from_xml(xml_data, nil, output, output_levels, output_stack)

  return (options and options.pretty) and prettyjson(data_in_lua)
  or cjson.encode(data_in_lua)
end

-- prints a simple datatype to the right place in the output table,
-- as indicated by the last pointer in the xml_output_level stack
print_simple_datatype = function(element, simple_type, xml_output_levels, extra_data)
  -- obtain pointer to the output table we're currently writing to
  local current_output_table = xml_output_levels[#xml_output_levels]

  -- divs are a special case - load the XML from JSON and place it inline
  if element == "div" then
    current_output_table[#current_output_table+1] = xml.load(simple_type)
  else
    current_output_table[#current_output_table+1] = {xml = element, value = tostring(simple_type)}
  end

  if extra_data then
    xml_output_levels[#xml_output_levels+1] = current_output_table[#current_output_table]
    handle_json_recursively(extra_data, xml_output_levels)
    tremove(xml_output_levels)
  end
end

-- prints a complex datatype to the right place in the output table,
-- as indicated by the last pointer in the xml_output_level stack,
-- and recurses down to handle more available values
print_complex_datatype = function(element, complex_type, xml_output_levels)
  -- ignore if this is a _value, as those will be handled when handling their
  -- respective 'value' element
  if element:find("_", 1, true) then return end

  -- obtain pointer to the output table we're currently writing to
  local current_output_table = xml_output_levels[#xml_output_levels]

  -- add new table within the said output table
  current_output_table[#current_output_table+1] = {xml = element}

  -- update our pointer to point to the newly-created table that we'll now be writing data to
  xml_output_levels[#xml_output_levels+1] = current_output_table[#current_output_table]

  -- recurse down to write any more complex or primitive values
  handle_json_recursively(complex_type, xml_output_levels)

  -- stepping back out, remove pointer from stack
  tremove(xml_output_levels)
end

handle_json_recursively = function(json_data, xml_output_levels)
  -- pairs since this is a JSON object with key-value pairs
  for element, data in pairs(json_data) do
    if type(data) == "table" then -- handle arrays with in-place expansion (one array is many xml pbjects)
      if type(data[1]) == "table" then -- array of resources/complex types
        for _, array_complex_element in ipairs(data) do
          if type(array_complex_element) ~= "userdata" then
            print_complex_datatype(element, array_complex_element, xml_output_levels)
          end
        end

      elseif data[1] and type(data[1]) ~= "table" then -- array of simple datatypes
        for i, array_primitive_element in ipairs(data) do

          -- handle extra values (id and extension) stored in _element by looking up
          -- the appropriate array, and if it exists, pass the correct value within
          -- said array to print function
          local _value
          local _array = json_data[sformat("_%s", element)]
          if _array then
            _value = _array[i]
            -- don't process if it's JSON null
            if _value == cjson.null then _value = nil end
          end
          print_simple_datatype(element, array_primitive_element, xml_output_levels, _value)
        end
      elseif type(data) ~= "userdata" then
        print_complex_datatype(element, data, xml_output_levels)
      end
    elseif type(data) ~= "userdata" then -- not an array, handle object property
      print_simple_datatype(element, data, xml_output_levels, json_data[sformat("_%s", element)])
    end
  end
end

-- entry point for converting from JSON to XML
convert_to_lua_from_json = function(json_data, output, xml_output_levels)
  -- strip out the resourceType
  if json_data.resourceType then
    output.xmlns = "http://hl7.org/fhir"
    output.xml = json_data.resourceType
    json_data.resourceType = nil
  end

  -- continue processing rest of resource
  return handle_json_recursively(json_data, xml_output_levels)
end

convert_to_xml = function(data, options)
  fhir_data = fhir_data or map_fhir_data(read_fhir_data())

  assert(next(fhir_data), "convert_to_xml: FHIR Schema could not be parsed in.")

  local json_data
  if options and options.file then
    json_data = read_file(data, cjson.decode)
  else
    json_data = read_filecontent(data, cjson.decode)
  end

  local output = {}
  local xml_output_levels = {output}

  convert_to_lua_from_json(json_data, output, xml_output_levels)


  return xml.dump(output)
end

return {
  to_json = convert_to_json,
  to_xml = convert_to_xml
}
