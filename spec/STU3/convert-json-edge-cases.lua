package.path = "src/?.lua;"..package.path
local to_json = require("fhirformats").to_json
local to_xml = require("fhirformats").to_xml
local inspect = require("inspect")

io.output("spec/STU3/json-edge-cases (fhir-formats).xml")
io.write(to_xml("spec/STU3/json-edge-cases.json", {file = true}, "STU3"))
io.output("spec/STU3/json-edge-cases (fhir-formats).json")
io.write(to_json("spec/STU3/json-edge-cases.xml", {file=true, pretty = true}, "STU3"))
io.output():close()
