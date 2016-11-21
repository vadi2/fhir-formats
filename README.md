# FHIR Formats
FHIR XML to/from JSON converter library in Lua.

Online version available at [https://fhir-formats.github.io](https://fhir-formats.github.io).

## Installation
To install FHIR-Formats, run:
```sh
$ luarocks install fhirformats
```

## API
```lua
local to_json = require("fhirformats").to_json
local to_xml = require("fhirformats").to_xml

-- convert given XML content as a string to JSON
to_json("xml content")
-- convert an XML file given as a location to JSON
to_json("/path/to/file", {file = true})
-- convert XML content as a string to JSON and prettyprint it
to_json("xml content", {pretty = true})
-- convert an XML file given as a location to JSON and prettyprint it
to_json("/path/to/file", {file = true, pretty = true})

-- convert given JSON content as a string to XML
to_xml("json content")
-- convert an JSON file given as a location to XML
to_xml("/path/to/file", {file = true})

-- get the FHIR definition of an element
get_fhir_definition('Patient', 'animal', 'species')
-- returns a table with metadata about the element. Do not modify this table. Keys are:
-- _min (int): minimum cardinality
-- _max (string): maximum cardinality, either a number or *
-- _type_json (string): JSON rendering type. Possible values are: number, string, boolean
-- _weight (string): arbitrary number assigned to an element - higher the number, the lower in the XML structure it is
-- _kind (string): FHIR element kind. Possible values are: complex-type, resource, primitive-type
-- _type (string): FHIR element type. Possible values are: Address, Age, Annotation, Attachment, BackboneElement, CodeableConcept, Coding, ContactDetail, ContactPoint, Contributor, Count, DataRequirement, Distance, DomainResource, Duration, Element, ElementDefinition, Extension, HumanName, Identifier, Meta, Money, Narrative, ParameterDefinition, Period, Quantity, Range, Ratio, Reference, RelatedResource, Resource, SampledData, Signature, Timing, TriggerDefinition, UsageContext, base64Binary, boolean, code, date, dateTime, decimal, id, instant, integer, markdown, oid, positiveInt, string, time, unsignedInt, uri, xhtml
-- [1]: if present, this is a link to the base type of the resource
-- _derivations: if present, this is a map of resources that extend on this resource
```

### Examples
```lua
> to_json = require("fhirformats").to_json
> print(to_json([[
  <?xml version="1.0" encoding="UTF-8"?>
  <Patient xmlns="http://hl7.org/fhir">
    <id value="1"/>
    <meta>
      <versionId value="1"/>
      <lastUpdated value="2016-04-01T03:22:46Z"/>
    </meta>
    <text>
      <status value="generated"/>
      <div xmlns="http://www.w3.org/1999/xhtml">
        <h1>Eve Everywoman</h1> </div>
    </text>
    <active value="true"/>
    <name>
      <text value="Eve Everywoman"/>
      <family value="Everywoman1"/>
      <given value="Eve"/>
    </name>
    <telecom>
      <system value="phone"/>
      <value value="555-555-2003"/>
      <use value="work"/>
    </telecom>
    <gender value="female"/>
    <birthDate value="1955-01-06"/>
    <address>
      <use value="home"/>
      <line value="2222 Home Street"/>
    </address>
  </Patient>
]]))
{"active":true,"id":"1","text":{"status":"generated","div":"<div xmlns='http:\/\/www.w3.org\/1999\/xhtml'>\n  <h1>Eve Everywoman<\/h1>\n<\/div>"},"telecom":[{"value":"555-555-2003","use":"work","system":"phone"}],"resourceType":"Patient","name":[{"family":["Everywoman1"],"text":"Eve Everywoman","given":["Eve"]}],"address":[{"line":["2222 Home Street"],"use":"home"}],"birthDate":"1955-01-06","gender":"female","meta":{"versionId":"1","lastUpdated":"2016-04-01T03:22:46Z"}}

> print(to_json([[
  <?xml version="1.0" encoding="UTF-8"?>
  <Patient xmlns="http://hl7.org/fhir">
    <id value="1"/>
    <meta>
      <versionId value="1"/>
      <lastUpdated value="2016-04-01T03:22:46Z"/>
    </meta>
    <text>
      <status value="generated"/>
      <div xmlns="http://www.w3.org/1999/xhtml">
        <h1>Eve Everywoman</h1> </div>
    </text>
    <active value="true"/>
    <name>
      <text value="Eve Everywoman"/>
      <family value="Everywoman1"/>
      <given value="Eve"/>
    </name>
    <telecom>
      <system value="phone"/>
      <value value="555-555-2003"/>
      <use value="work"/>
    </telecom>
    <gender value="female"/>
    <birthDate value="1955-01-06"/>
    <address>
      <use value="home"/>
      <line value="2222 Home Street"/>
    </address>
  </Patient>
]], {pretty = true}))
{
	"active": true,
	"id": "1",
	"text": {
		"status": "generated",
		"div": "<div xmlns='http:\/\/www.w3.org\/1999\/xhtml'>\n  <h1>Eve Everywoman<\/h1>\n<\/div>"
	},
	"telecom": [
		{
			"value": "555-555-2003",
			"use": "work",
			"system": "phone"
		}
	],
	"resourceType": "Patient",
	"name": [
		{
			"family": [
				"Everywoman1"
			],
			"text": "Eve Everywoman",
			"given": [
				"Eve"
			]
		}
	],
	"address": [
		{
			"line": [
				"2222 Home Street"
			],
			"use": "home"
		}
	],
	"birthDate": "1955-01-06",
	"gender": "female",
	"meta": {
		"versionId": "1",
		"lastUpdated": "2016-04-01T03:22:46Z"
	}
}
>
```


## Note

Decimal precision is up to 14 significant digits.

## TODO

* add command-line utility for Windows, OSX, and Linux
* add a stand-alone Postman-like app
* add FHIR graph visualisations
