# FHIR Formats
FHIR XML to/from JSON converter in Lua.

## Installation
To install FHIR-Formats, run:
```sh
$ luarocks install fhir-formats
```

## API
```lua
local to_json = require("fhir-formats").to_json

resource_in_json = to_json([[
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
]])

```


## Note

Only FHIR XML to FHIR JSON conversion is supported at the moment.

## TODO

* add JSON to XML conversion
* add command-line utility for Windows, OSX, and Linux
* add Javascript version
