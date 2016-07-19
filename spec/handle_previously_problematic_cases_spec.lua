package.path = "src/?.lua;"..package.path
local in_fhir_json = require("fhirformats").to_json
local in_fhir_xml = require("fhirformats").to_xml
local cjson = require("cjson")
local xml = require("xml")

describe("previously failing conversions", function()
    describe("should convert a problematic ValueSet", function()
        local in_json = in_fhir_json([[
        <?xml version="1.0" encoding="UTF-8"?>
<ValueSet xmlns="http://hl7.org/fhir">
    <meta>
        <profile value="http://hl7.org/fhir/StructureDefinition/shareablevalueset"/>
    </meta>
    <text>
        <status value="generated"/>
        <div xmlns="http://www.w3.org/1999/xhtml">
            <p>Value set "ACME Codes for Cholesterol": This is an example value set that includes all the codes for serum cholesterol defined by ACME inc.</p>
            <p>Developed by: FHIR project team (example)</p>
            <p>Published for testing on 13-June 2012</p>
            <p>This value set includes all the ACME codes for serum cholesterol:</p>
            <table class="grid">
                <tr>
                    <td>
                        <b>Code</b>
                    </td>
                    <td>
                        <b>Display</b>
                    </td>
                    <td>
                        <b>Definition</b>
                    </td>
                </tr>
                <tr>
                    <td>chol-mmol</td>
                    <td>SChol (mmol/L)</td>
                    <td>Serum Cholesterol, in mmol/L</td>
                </tr>
                <tr>
                    <td>chol-mass</td>
                    <td>SChol (mg/L)</td>
                    <td>Serum Cholesterol, in mg/L</td>
                </tr>
                <tr>
                    <td>chol</td>
                    <td>SChol</td>
                    <td>Serum Cholesterol</td>
                </tr>
            </table>
        </div>
    </text>
    <url value="http://hl7.org/fhir/ValueSet/example-inline"/>
    <identifier>
        <system value="http://acme.com/identifiers/valuesets"/>
        <value value="loinc-cholesterol-inl-7dkcyKMpm"/>
    </identifier>
    <version value="20150622"/>
    <name value="ACME Codes for Cholesterol in Serum/Plasma"/>
    <status value="draft"/>
    <experimental value="true"/>
    <publisher value="HL7 International"/>
    <contact>
        <name value="FHIR project team"/>
        <telecom>
            <system value="other"/>
            <value value="http://hl7.org/fhir"/>
        </telecom>
    </contact>
    <date value="2015-06-22"/>
    <description value="This is an example value set that includes all the ACME codes for serum/plasma cholesterol from v2.36."/>
</ValueSet>]])
    end)
  
    describe("should handle ValueSet.url correctly", function()
        local in_xml = in_fhir_xml([[{
  "resourceType": "ValueSet",
  "id": "example-extensional",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/StructureDefinition/valueset-shareable-definition"
    ],
    "_profile": [
      {
        "fhir_comments": [
          "    shareable value sets are fully described, and can be put in the HL7 registry    "
        ]
      }
    ]
  },
  "text": {
    "status": "generated",
    "div": "<div>\n      <p>Value set &quot;LOINC Codes for Cholesterol&quot;: This is an example value set that includes \n        all the  codes for serum cholesterol from LOINC v2.36.</p>\n      <p>Developed by: FHIR project team (example)</p>\n      <p>Published for testing on 13-June 2012</p>\n      <p>This value set includes the following LOINC codes:</p>\n      <ul>\n        <li>14647-2: Cholesterol [Moles/Volume]</li>\n        <li>2093-3: Cholesterol [Mass/Volume]</li>\n        <li>35200-5: Cholesterol [Mass Or Moles/Volume] </li>\n        <li>9342-7: Cholesterol [Percentile]</li>\n      </ul>\n      <p>This content from LOINC® is copyright © 1995 Regenstrief Institute, Inc. and the LOINC Committee, and available at no cost under the license at http://loinc.org/terms-of-use.</p>\n    </div>"
  },
  "url": "http://hl7.org/fhir/ValueSet/example-extensional",
  "_url": {
    "fhir_comments": [
      "    \n\t  for this example, we use a real URI, since this example does have a canonical address\n\t\tat which it's posted. Alternatively, We could have used an OID, or a UUID.\n \n    Mote that this isn't the identifier for the LOINC codes themeselves - they belong to LOINC, and \n\t\tit has it's own identifier. This is the identifier for this set of codes, and that doesn't \n\t\tchange the codes.\n     "
    ]
  },
  "identifier": {
    "fhir_comments": [
      "    an imaginary identifier. This is a non FHIR identifier - might be used in a \n\t  v2 context (though you always need to translate namespaces for v2)    "
    ],
    "system": "http://acme.com/identifiers/valuesets",
    "value": "loinc-cholesterol-int"
  },
  "version": "20150622",
  "_version": {
    "fhir_comments": [
      "    for version, we are going to simply use the day of publication. This is also \n    arbitrary - whatever is here is what people use to refer to the version. \n    Could also be a UUID too    "
    ]
  },
  "name": "LOINC Codes for Cholesterol in Serum/Plasma",
  "_name": {
    "fhir_comments": [
      "    set of loinc codes for cholesterol for LONC 2.36    "
    ]
  },
  "status": "draft",
  "experimental": true,
  "publisher": "HL7 International",
  "contact": [
    {
      "name": "FHIR project team",
      "telecom": [
        {
          "system": "other",
          "value": "http://hl7.org/fhir"
        }
      ]
    }
  ],
  "date": "2015-06-22",
  "lockedDate": "2012-06-13",
  "_lockedDate": {
    "fhir_comments": [
      "    \n\t  if we didn't specify the version of LOINC on the include, then\n\t  we could specify it implicitly by specifying the locked date for the value set\n\t\t\n\t\tSo we show this example here, but it's not actually necessary since we also \n    have LOINC version. Note: if you do what this example does, and specify both,\n\t\tyou better get it right, and specify the current version of LOINC at the time\n     "
    ]
  },
  "description": "This is an example value set that includes all the LOINC codes for serum/plasma cholesterol from v2.36.",
  "copyright": "This content from LOINCÂ® is copyright Â© 1995 Regenstrief Institute, Inc. and the LOINC Committee, and available at no cost under the license at http://loinc.org/terms-of-use."}]])  
      end)
    
end)