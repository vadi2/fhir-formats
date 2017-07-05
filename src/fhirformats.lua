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

local rapidjson, datafile, lunajson, xml

-- when loading via Web, load the pure-Lua libraries
if js and js.global then
  xml = {}
  xml.dump = require("pure-xml-dump")
  xml.load = require("pure-xml-load")

  lunajson = require("lunajson")

  -- fake out cjson.safe for prettycjson, which insists on loading it
  package.loaded["cjson.safe"] = { encode = function() end }
else
  -- otherwise load the libraries with native code for perf
  xml = require("xml")
  rapidjson = require("rapidjson")
  -- datafile is used by LuaRocks exclusively
  datafile = require("datafile")
end
local prettyjson = require("resty.prettycjson")

local ipairs, pairs, type, print, tonumber, gmatch, tremove, sformat, tsort, tconcat
= ipairs, pairs, type, print, tonumber, string.gmatch, table.remove, string.format, table.sort, table.concat

local get_fhir_definition, read_fhir_data, getindex, map_fhir_data, fhir_typed
local get_json_datatype, print_data_for_node, convert_to_lua_from_xml, handle_div
local convert_to_json, file_exists, read_filecontent, read_file, make_json_datatype
local handle_json_recursively, print_simple_datatype, convert_to_lua_from_json
local convert_to_xml, print_complex_datatype, list_to_map

local fhir_data

local null_value
local json_decode, json_encode

if rapidjson then
  null_value = rapidjson.null
  json_decode, json_encode = rapidjson.decode, rapidjson.encode
elseif lunajson then
  null_value = function() end -- a blank table didn't work since sometimes we check for the table type
  json_decode = function(data)
    return lunajson.decode(data, nil, null_value)
  end
  json_encode = function(data)
    return lunajson.encode(data, null_value)
  end
else
  error("neither rapidjson nor luajson libraries found to do JSON encoding/decoding with")
end

-- credit: http://stackoverflow.com/a/4991602/72944
file_exists = function(name)
  local f = io.open(name,"r")
  if f ~= nil then io.close(f) return true else return false end
end

-- find the location of the running instance of fhirformats.lua, so the error messages can be more informative
local PATH = (... and (...):match("(.+)%.[^%.]+$") or (...)) or "(path of the script unknown)"

read_fhir_data = function(filename)
  -- prefer the filename, but substitute the nil if not given
  local locations = {(filename or ""), "fhir-data/fhir-elements.json", "src/fhir-data/fhir-elements.json", "../src/fhir-data/fhir-elements.json", "fhir-data/fhir-elements.json"}
  local data

  for _, file in ipairs(locations) do
    if file_exists(file) then
      io.input(file)
      data = json_decode(io.read("*a"))
      break
    end
  end

  -- if installed as a LuaRock, try the data directory
  local dataf, datafileerr, useddatafile
  if not data and datafile then
    useddatafile = true
    dataf, datafileerr = datafile.open("src/fhir-data/fhir-elements.json", "r")
    if dataf then data = json_decode(dataf:read("*a")) end
  end

  if not data and require_resource then
    data = json_decode(require_resource("fhir-data/fhir-elements.json"))
  end


  assert(data, string.format("read_fhir_data: FHIR Schema could not be found in these locations starting from %s:  %s\n\n%s%s", PATH, tconcat(locations, "\n  "), useddatafile and ("Datafile could not find LuaRocks installation as well; error is: \n"..datafileerr) or '', require_resource and "Embedded JSON data could not be found as well." or ''))
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

slice = function(array, start, stop)
  local t = {}
  for i = (start and start or 1), (stop and stop or #array) do
    t[i] = array[i]
  end

  return t
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
    previouselement._min = element.min
    previouselement._max = element.max
    previouselement._type = element.type
    previouselement._type_json = element.type_json
    previouselement._weight = element.weight
    previouselement._kind = element.kind
    previouselement._derivations = list_to_map(element.derivations, function(value) return fhir_data[value] end)
    flatten_derivations(previouselement)

    if type(fhir_data[element.type]) == "table" then
      previouselement[1] = fhir_data[element.type]
    end
  end

  -- pulls up nested derivations into the given element, mainly so
  -- things deriving from DomainResource are available at Resource level
  flatten_derivations = function(root_element, nested_element)
    if not (root_element and root_element._derivations) then return end

    local derivations = nested_element and nested_element._derivations or root_element._derivations
    for derivation, data in pairs(derivations) do
      if data._derivations then
        for nested_derivation, nested_data in pairs(data._derivations) do
          if root_element ~= nested_data then
            root_element._derivations[nested_derivation] = nested_data
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

  -- and lastly, to ensure all derivations are in (as the order of resources could affect it
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
    print(string.format("Warning: %s is not a known FHIR element; couldn't check its FHIR type to decide the JSON type.", tconcat(output_stack, ".")))
    return value
  end

  local json_type = fhir_definition._type or fhir_definition._type_json

  if json_type == "boolean" then
    if node.value == "true" then return true
    elseif node.value == "false" then return false
    else
      print(string.format("Warning: %s.%s is of type %s in FHIR JSON - its XML value of %s is invalid.", tconcat(output_stack), node.xml, json_type, node.value))
    end
  elseif json_type == "integer" or
  json_type == "unsignedInt" or
  json_type == "positiveInt" or
  json_type == "decimal" then
    return tonumber(node.value)
  else return value end
end

-- given a path to the element in the format of {indexed table} and the element name,
-- returns the FHIR definition from the FHIR schema
get_fhir_definition = function (output_stack, element_to_check)
  local fhir_data_pointer

  -- +1 since element_to_check isn't on the stack
  for i = 1, #output_stack+1 do
    local element = (output_stack[i] or element_to_check)

    if not fhir_data_pointer then
      fhir_data_pointer = fhir_data[element]
    elseif fhir_data_pointer[element] then
      fhir_data_pointer = fhir_data_pointer[element]
    elseif fhir_data_pointer[1] then
      fhir_data_pointer = fhir_data_pointer[1][element] or (fhir_data_pointer[1]._derivations and fhir_data_pointer[1]._derivations[element] or nil)
    else
      fhir_data_pointer = nil
      break -- bail out of the for loop if we didn't find the element we're looking for
    end
  end

  return fhir_data_pointer
end

-- returns true/false if the given string is a valid FHIR resource
is_fhir_resource = function (resourcename)
  return (fhir_data[resourcename] and 
    (fhir_data[resourcename]._kind == "resource" or fhir_data[resourcename]._type == "Resource")) and true or false
end

-- accepts the path as a set of strings instead of a table+string, and is exposed publicly
-- returns a copy of the fhir element with underscores removed
get_fhir_definition_public = function(...)
  local output_stack = {...}
  local element_to_check = output_stack[#output_stack]
  output_stack[#output_stack] = nil

  local fhir_element = get_fhir_definition(output_stack, element_to_check)
  if not fhir_element then
    return nil, string.format("No element %s found", tconcat({...}, '.'))
  else
    return fhir_element
  end
end

make_json_datatype = function(output_stack, element_to_check)
  local newtable, pointer_inside_table

  local fhir_definition = get_fhir_definition(output_stack, element_to_check)

  if not fhir_definition then
    print(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.", tconcat(output_stack, "."), element_to_check))
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

-- returns whenever the given FHIR element should be an object or an array in JSON
get_json_datatype = function(output_stack, element_to_check)
  local fhir_data_pointer = get_fhir_definition(output_stack, element_to_check)

  if fhir_data_pointer == nil then
    print(string.format("Warning: %s.%s is not a known FHIR element; couldn't check max cardinality for it to decide on a JSON object or array.", tconcat(output_stack, "."), element_to_check))
  end

  if fhir_data_pointer and fhir_data_pointer._max == "*" then
    return "array"
  end

  return "object"
end

get_xml_weight = function(output_stack, element_to_check)
  local fhir_definition = get_fhir_definition(output_stack, element_to_check)
  if not fhir_definition then
    print(string.format("Warning: %s.%s is not a known FHIR element; won't be able to sort it properly in the XML output.", tconcat(output_stack, "."), element_to_check))
    return 0
  else
    return fhir_definition._weight
  end
end

-- returns the FHIR value of 'kind' for the given element
get_datatype_kind = function(output_stack, element_to_check)
  local fhir_definition = get_fhir_definition(output_stack, element_to_check)
  if not fhir_definition then
    print(string.format("Warning: %s.%s is not a known FHIR element; might not convert it to a proper JSON 'element' or '_element' representation.", tconcat(output_stack, "."), element_to_check))
    return 0
  else
    local datatype_fhir_definition = get_fhir_definition({}, fhir_definition._type)
    return datatype_fhir_definition._kind
  end
end

print_xml_value = function(node, current_level, output_stack, need_shadow_element)
  -- if we're processing a primitive value, add it to the right place
  -- in output{}. Right place is given to us by looking at the last
  -- place in the 2D stack
  if not current_level[node.xml] then
    local fhir_value
    if get_json_datatype(output_stack, node.xml) == "array" then
      fhir_value = {}
      -- if something created the shadow element previously, then pad this out
      -- with appropriate amount of null's
      local shadow_element = current_level["_"..node.xml]
      if shadow_element then
        for i = 1, #shadow_element do
          fhir_value[#fhir_value+1] = null_value
        end
      end
      fhir_value[#fhir_value+1] = fhir_typed(output_stack, node)
    else
      fhir_value = fhir_typed(output_stack, node)
    end

    current_level[node.xml] = fhir_value
  else -- if there's something there already, then that means we have more values for the array
    local existing_array = current_level[node.xml]
    existing_array[#existing_array+1] = fhir_typed(output_stack, node)

    -- add a null to the corresponding _ prefix if it's there and we
    -- don't have data for the shadow element
    local _value = current_level["_"..node.xml]
    if _value and not need_shadow_element then
      _value[#_value+1] = null_value
    end
  end
end

-- peek down to see if we need to create a '_value' table to hold the 'id' or 'extension'
-- properties.
-- node[#node] might not be necessary, but currently having an id creates 2 tables
need_shadow_element = function(level, node, output_stack)
  if level ~= 1 and node[1]
  and output_stack[#output_stack] ~= "extension" and node.xml ~= "extension" -- don't create shadow tables if we're inside an extension though
  and get_datatype_kind(output_stack, node.xml) ~= "complex-type" -- or if this is a complex type
  then
    if node.id then return true
    else
      for i = 1, #node do
        if node[i].xml == "extension" then return true end
      end
    end
  end
end

print_data_for_node = function(node, level, output, output_levels, output_stack)
  assert(node.xml, "error from parsed xml: node.xml is missing")
  local previouslevel = level - 1
  local need_shadow_element = need_shadow_element(level, node, output_stack)
  local current_level

  if level ~= 1 then
    current_level = output_levels[previouslevel][#output_levels[previouslevel]]
  end

  -- in JSON, resource type is embedded within the object.resourceType,
  -- unlike at root level in FHIR XML. Do this for the root level
  if level == 1 then
    output.resourceType = node.xml
  -- do the same for embedded resources as well
  elseif is_fhir_resource(node.xml) then
    current_level.resourceType = node.xml

    output_levels[level] = output_levels[level] or {}
    output_levels[level][#output_levels[level]+1] = current_level

    return
  elseif node.value then


    print_xml_value(node, current_level, output_stack, need_shadow_element)
  end

  -- embedded table - create a table in the output and add it to the right place
  -- in the output_stack, so when we're inserting the primitive values above,
  -- we know which table to add the value to
  if type(node[1]) == "table" and level ~= 1 then -- don't create another table for level 1
    -- since in FHIR JSON the resource name is 'inside' as a resourceType property
    local newtable, pointer_inside_table


    -- if this is a recurring XML element, and not an embedded id or extension,
    -- create another array in an existing array for it
    if type(current_level[node.xml]) == "table" and not need_shadow_element then
      local existing_array = current_level[node.xml]
      existing_array[#existing_array+1] = {}
      pointer_inside_table = existing_array[#existing_array]
    elseif not current_level[node.xml] and (node[1] or node.value) and not need_shadow_element then
      -- create a new table in output using our stack pointer, if we
      -- haven't created already - could've been created by node.value above
      -- and what we're now looking at is an extension within
      newtable, pointer_inside_table = make_json_datatype(output_stack, node.xml)
      current_level[node.xml] = newtable
    end


    -- if it's an id or an extension element of a datatype, create a fix with a _ prefix for it
    if need_shadow_element  then
      newtable, pointer_inside_table = make_json_datatype(output_stack, node.xml)
      local _node_xml = sformat('_%s', node.xml)
      local added_shadow_element
      if not current_level[_node_xml] then
        current_level[_node_xml] = newtable
        added_shadow_element = true
      else
        current_level[_node_xml][#current_level[_node_xml]+1] = pointer_inside_table
      end

      -- see if we need to pad the new '_value' table out with null's in case we've got
      -- multiple values (https://hl7-fhir.github.io/json.html#primitive)
      -- only do this if we've created the shadow table for the first time
      local pos = getindex(current_level[node.xml], node.value)
      if added_shadow_element and pos and pos > 1 then
        newtable[1] = nil -- remove the first {} that json_object_or_array added, as we need to pre-pad
        for _ = 1, pos-1 do
          newtable[#newtable+1] = null_value
        end
        newtable[#newtable+1] = {} -- re-insert the first {} deleted earlier
        pointer_inside_table = newtable[#newtable]
      end

      -- and on the other end, see if we need to pad the original 'value' table in case
      -- we only have an id/extension and no @value
      if not node.value and current_level[node.xml] then
        -- wipe the nested {} that gets created, as it's unnecessary
        if type(current_level[node.xml][#current_level[node.xml]]) == "table" then
          current_level[node.xml][#current_level[node.xml]] = nil
        end
        current_level[node.xml][#current_level[node.xml]+1] = null_value
      end
    end

    -- update stack with a pointer to the table we made above
    output_levels[level] = output_levels[level] or {}
    output_levels[level][#output_levels[level]+1] = pointer_inside_table
  end


  -- lastly, handle extension URLs and id's by creating them not at the current level, but at the
  -- nested level down as FHIR JSON likes it
  if node.url then
    output_levels[level][#output_levels[level]].url = node.url
  end
  if node.id then
    output_levels[level][#output_levels[level]].id = node.id
  end

  return output
end

handle_div = function(output_levels, node, level)
  output_levels[level][#output_levels[level]][node.xml] = xml.dump(node)
end

-- converts from XML to JSON, xml_data is input in Lua tables
convert_to_lua_from_xml = function(xml_data, level, output, output_levels, output_stack)
  -- level is the nesting level inside raw xml_data from our xml parser
  level = (level and (level+1) or 1)

  output = print_data_for_node(xml_data, level, output, output_levels, output_stack)

  output_stack[#output_stack+1] = xml_data.xml
  for _, value in ipairs(xml_data) do
    if value.xml == "div" and value.xmlns == "http://www.w3.org/1999/xhtml" then
      handle_div(output_levels, value, level)
    else
      assert(type(value) == "table", sformat("unexpected type value encountered: %s (%s), expecting table", tostring(value), type(value)))
      convert_to_lua_from_xml(value, level, output, output_levels, output_stack)
    end
  end
  tremove(output_stack)

  return output
end

-- credit: http://stackoverflow.com/questions/28312409/how-can-i-implement-a-read-only-table-in-lua
local proxies = setmetatable( {}, { __mode = "k" } )
function read_only( t )
  if type( t ) == "table" then
    -- check whether we already have a readonly proxy for this table
    local p = proxies[ t ]
    if not p then
      -- create new proxy table for t
      p = setmetatable( {}, {
        __index = function( _, k )
          -- apply `readonly` recursively to field `t[k]`
          return readOnly( t[ k ] )
        end,
        __newindex = function()
          error( "table is readonly", 2 )
        end,
      } )
      proxies[ t ] = p
    end
    return p
  else
    -- non-tables are returned as is
    return t
  end
end

convert_to_json = function(data, options)
  fhir_data = fhir_data or map_fhir_data(read_fhir_data())

  assert(next(fhir_data), "convert_to_json: FHIR Schema could not be parsed in.")
  read_only(fhir_data)

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

  return (options and options.pretty) and prettyjson(data_in_lua, nil, '  ', nil, json_encode)
  or json_encode(data_in_lua)
end

-- prints a simple datatype to the right place in the output table,
-- as indicated by the last pointer in the xml_output_level stack
print_simple_datatype = function(element, simple_type, xml_output_levels, output_stack, extra_data)
  -- ignore if this is a _value, as those will be handled when handling their
  -- respective 'value' element
  if element:find("_", 1, true) then return end

  -- obtain pointer to the output table we're currently writing to
  local current_output_table = xml_output_levels[#xml_output_levels]

  -- divs are a special case - load the XML from JSON and place it inline
  if element == "div" then
    current_output_table[#current_output_table+1] = xml.load(simple_type)
  elseif element == "url" and (output_stack[#output_stack] == "extension" or output_stack[#output_stack] == "modifierExtension") then -- some things are attributes: https://hl7-fhir.github.io/xml.html#1.17.1, "extension URLs in the url"
    current_output_table.url = simple_type
  elseif element == "id" then
    local parent_type = get_fhir_definition(slice(output_stack, 1, #output_stack-1), output_stack[#output_stack])._type
    if parent_type ~= "Resource" and parent_type ~= "DomainResource" then
      current_output_table.id = simple_type
    else
      current_output_table[#current_output_table+1] = {xml = element, value = tostring(simple_type)}
    end
  elseif simple_type == null_value then
    current_output_table[#current_output_table+1] = {xml = element}
  else
    current_output_table[#current_output_table+1] = {xml = element, value = tostring(simple_type)}
  end

  -- only add weights for elements and not attributes (like url)
  local new_element = current_output_table[#current_output_table]
  if new_element then
    new_element._weight = get_xml_weight(output_stack, element)
    new_element._count = #current_output_table
  end

  if extra_data then
    xml_output_levels[#xml_output_levels+1] = current_output_table[#current_output_table]
    output_stack[#output_stack+1] = current_output_table[#current_output_table].xml
    handle_json_recursively(extra_data, xml_output_levels, output_stack)
    tremove(xml_output_levels)
    tremove(output_stack)
  end
end

-- prints a complex datatype to the right place in the output table,
-- as indicated by the last pointer in the xml_output_level stack,
-- and recurses down to handle more available values
print_complex_datatype = function(element, complex_type, xml_output_levels, output_stack)
  -- ignore if this is a _value, as those will be handled when handling their
  -- respective 'value' element
  if element:find("_", 1, true) then return end

  -- obtain pointer to the output table we're currently writing to
  local current_output_table = xml_output_levels[#xml_output_levels]

  -- add new table within the said output table
  current_output_table[#current_output_table+1] = {xml = element}
  local new_element = current_output_table[#current_output_table]

  -- record the weight for later sorting
  new_element._weight = get_xml_weight(output_stack, element)
  new_element._count = #current_output_table

  -- update our pointer to point to the newly-created table that we'll now be writing data to
  xml_output_levels[#xml_output_levels+1] = new_element

  -- update our stack of FHIR elements
  output_stack[#output_stack+1] = new_element.xml

  -- recurse down to write any more complex or primitive values
  handle_json_recursively(complex_type, xml_output_levels, output_stack)

  -- stepping back out, remove pointers from stacks
  tremove(xml_output_levels)
  tremove(output_stack)
end

print_contained_resource = function(json_data, xml_output_levels, output_stack)
  -- same as above
  local current_output_table = xml_output_levels[#xml_output_levels]
  current_output_table[#current_output_table+1] = {xml = json_data.resourceType}
  xml_output_levels[#xml_output_levels+1] = current_output_table[#current_output_table]
  output_stack[#output_stack+1] = current_output_table[#current_output_table].xml
  json_data.resourceType = nil
end

handle_json_recursively = function(json_data, xml_output_levels, output_stack)
  -- handle contained resources
  local had_contained_resource
  if json_data.resourceType then
    print_contained_resource(json_data, xml_output_levels, output_stack)
    had_contained_resource = true
  end

  -- use pairs since this is a JSON object with key-value pairs
  for element, data in pairs(json_data) do
    -- TODO: change type(data) to lua_data_type
    if type(data) == "table" then -- handle arrays with in-place expansion (one array is many xml objects)
      if type(data[1]) == "table" then -- array of resources/complex types
        for _, array_complex_element in ipairs(data) do
          if array_complex_element ~= null_value then
            print_complex_datatype(element, array_complex_element, xml_output_levels, output_stack)
          end
        end

      elseif data[1] and type(data[1]) ~= "table" then -- array of simple datatypes
        for i, array_primitive_element in ipairs(data) do
          -- handle extra values (id and extension) stored in _element by looking up
          -- the appropriate array, and if it exists, pass the correct value within
          -- the said array to print function
          local _array, _value = json_data[sformat("_%s", element)]
          if _array then
            _value = _array[i]
            -- don't process if it's JSON null
            if _value == null_value then _value = nil end
          end
          print_simple_datatype(element, array_primitive_element, xml_output_levels, output_stack, _value)
        end
      elseif data ~= null_value then
        print_complex_datatype(element, data, xml_output_levels, output_stack)
      end
    elseif data ~= null_value then -- not an array, handle object property
      print_simple_datatype(element, data, xml_output_levels, output_stack, json_data[sformat("_%s", element)])
    end

    -- handle a special case: there is an '_element' in JSON but no corresponding 'element'
    if element:sub(1,1) == '_' and not json_data[element:sub(2)] then
      print_complex_datatype(element:sub(2), data, xml_output_levels, output_stack)
    end
  end

  -- sort XML elements at this level according to the FHIR element sorting
  local current_output_table = xml_output_levels[#xml_output_levels]
  tsort(current_output_table, function(a,b)
      -- if it's many elements repeated, then keep their previous JSON order
      -- otherwise sort by FHIR schema
      return (a.xml == b.xml) and (a._count < b._count) or (a._weight < b._weight)
    end)

  -- remove temporary weight and order data
  for i = 1, #current_output_table do
    local element = current_output_table[i]
    element._weight = nil
    element._count = nil
  end

  if had_contained_resource then
    tremove(xml_output_levels)
    tremove(output_stack)
  end
end

-- entry point for converting from JSON to XML
convert_to_lua_from_json = function(json_data, output, xml_output_levels, output_stack)
  -- strip out the root resourceType
  if json_data.resourceType then
    output.xmlns = "http://hl7.org/fhir"
    output.xml = json_data.resourceType
    json_data.resourceType = nil
    output_stack[#output_stack+1] = output.xml
  end

  -- continue processing rest of resource
  return handle_json_recursively(json_data, xml_output_levels, output_stack)
end

convert_to_xml = function(data, options)
  fhir_data = fhir_data or map_fhir_data(read_fhir_data())

  assert(next(fhir_data), "convert_to_xml: FHIR Schema could not be parsed in.")
  read_only(fhir_data)

  local json_data
  if options and options.file then
    json_data = read_file(data, json_decode)
  else
    json_data = read_filecontent(data, json_decode)
  end

  local output, output_stack = {}, {}
  local xml_output_levels = {output}

  convert_to_lua_from_json(json_data, output, xml_output_levels, output_stack)

  return xml.dump(output)
end

map_fhir_data(read_fhir_data())
read_only(fhir_data)

return {
  to_json = convert_to_json,
  to_xml = convert_to_xml,
  get_fhir_definition = get_fhir_definition_public
}
