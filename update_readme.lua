#!/usr/bin/lua
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

--[[ simple script to update README with possible FHIR values from the API ]]

local cjson = require("cjson")
local inspect = require("inspect")
local tablex = require("pl.tablex")
local fhir_elements_location = "src/fhir-data/fhir-elements.json"
local unique_types, unique_types_json, unique_kinds = {}, {}, {}

-- credit: http://stackoverflow.com/a/4991602/72944
file_exists = function(name)
  local f = io.open(name,"r")
  if f ~= nil then io.close(f) return true else return false end
end

if not file_exists(fhir_elements_location) then
  error("fhir-elements.json not found at '"..fhir_elements_location.."'")
end

io.input(fhir_elements_location)
data = cjson.decode(io.read("*a"))

for i = 1, #data do
  local element = data[i]
  if element.type then unique_types[element.type] = true end
  if element.type_json then unique_types_json[element.type_json] = true end
  if element.kind then unique_kinds[element.kind] = true end
end

io.input("README.md")
readme = io.read("*a")

local unique_types_keys = tablex.keys(unique_types)
table.sort(unique_types_keys)

readme = string.gsub(readme, "%-%- _type_json %(string%): JSON rendering type. Possible values are:[^%-`]+",
  "-- _type_json (string): JSON rendering type. Possible values are: "..table.concat(tablex.keys(unique_types_json), ', ')..'\n')

readme = string.gsub(readme, "%-%- _kind %(string%): FHIR element kind. Possible values are:[^%-`]+",
  "-- _kind (string): FHIR element kind. Possible values are: "..table.concat(tablex.keys(unique_kinds), ', ')..'\n')

readme = string.gsub(readme, "%-%- _type %(string%): FHIR element type. Possible values are:[^%-`]+",
  "-- _type (string): FHIR element type. Possible values are: "..table.concat(unique_types_keys, ', ')..'\n')

file = io.open("README.md", "w")
io.output(file)
io.write(readme)
io.close(file)