package.path = "src/?.lua;"..package.path
local to_json = require("fhir-formats").to_json
local to_xml = require("fhir-formats").to_xml
local inspect = require("inspect")

io.output("spec/json-edge-cases (fhir-formats).xml")
io.write(to_xml("spec/json-edge-cases.json", {file = true}))
--io.output("spec/json-edge-cases (fhir-formats).json")
--io.write(to_json(to_xml("spec/json-edge-cases.json", {file = true})))
io.output():close()