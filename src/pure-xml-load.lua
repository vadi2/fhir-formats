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

-- pure Lua parser to load XML into Lua data structures compatible with Lubyk XML

local SLAXML = require 'slaxml'

-- upvalue to store output
local output = {}
-- upvalue to keep track of indenting / where to write to
local xml_output_levels = {output}
-- upvalue to keep track of current namespace
local current_namespace = {}

local startElement = function(name, nsURI, nsPrefix)
  -- obtain pointer to the output table we're currently writing to
  local current_output_table = xml_output_levels[#xml_output_levels]

  -- only repeat namespace on changes - SAXML always passes us the namespace in nsURI
  if nsURI ~= current_namespace[#current_namespace] then
    current_namespace[#current_namespace+1] = nsURI
  else
    nsURI = nil
  end

  -- add new table within the said output table
  current_output_table[#current_output_table+1] = {xml = name, xmlns = nsURI}

  -- update our pointer to point to the newly-created table that we'll now be writing data to
  xml_output_levels[#xml_output_levels+1] = current_output_table[#current_output_table]
end

local attribute = function(name, value)
  local current_output_table = xml_output_levels[#xml_output_levels]
  current_output_table[name] = value
end

local closeElement = function(name, nsURI)
  -- stepping back out, remove pointer from stack
  table.remove(xml_output_levels)

  -- remove pointer from namespace stack as well
  if nsURI ~= current_namespace[#current_namespace] then
    current_namespace[#current_namespace] = nil
  end
end

local text = function(text)
  local current_output_table = xml_output_levels[#xml_output_levels]
  current_output_table[#current_output_table+1] = text
end

local parser = SLAXML:parser{
  startElement = startElement,
  attribute    = attribute,
  closeElement = closeElement,
  text = text
}

local function load(myxml)
  output = {}
  xml_output_levels = {output}
  current_namespace = {}

  parser:parse(myxml, {stripWhitespace = true})

  return select(2, next(output))
end

return load

