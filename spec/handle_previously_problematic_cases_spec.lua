local in_fhir_json = require("fhirformats").to_json
local in_fhir_xml = require("fhirformats").to_xml
local cjson = require("cjson")
local xml = require("xml")

describe("previously failing conversions", function()
    pending("should convert a problematic ValueSet", function()
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
    <codeSystem>
        <system value="http://acme.com/config/fhir/codesystems/cholesterol"/>
        <version value="4.2.3"/>
        <caseSensitive value="true"/>
        <concept>
            <code value="chol-mmol"/>
            <display value="SChol (mmol/L)"/>
            <definition value="Serum Cholesterol, in mmol/L"/>
            <designation>
                <use>
                    <system value="http://snomed.info/sct"/>
                    <code value="900000000000550004"/>
                    <display value="Definition (core metadata concept)"/>
                </use>
                <value value="From ACME POC Testing"/>
            </designation>
        </concept>
        <concept>
            <code value="chol-mass"/>
            <display value="SChol (mg/L)"/>
            <definition value="Serum Cholesterol, in mg/L"/>
            <designation>
                <use>
                    <system value="http://snomed.info/sct"/>
                    <code value="900000000000550004"/>
                    <display value="Definition (core metadata concept)"/>
                </use>
                <value value="From Paragon Labs"/>
            </designation>
        </concept>
        <concept>
            <code value="chol"/>
            <display value="SChol"/>
            <definition value="Serum Cholesterol"/>
            <designation>
                <use>
                    <system value="http://snomed.info/sct"/>
                    <code value="900000000000550004"/>
                    <display value="Definition (core metadata concept)"/>
                </use>
                <value value="Obdurate Labs uses this with both kinds of units..."/>
            </designation>
        </concept>
    </codeSystem>
</ValueSet>]])
      end)

    it("should convert a previously failing Appointment", function()
        in_fhir_xml([[{"resource":{"status":"proposed","resourceType":"Appointment","slot":[{"reference":"Slot\/example"}],"text":{"status":"generated","div":"<div xmlns='http:\/\/www.w3.org\/1999\/xhtml'>Discuss results of Peter James Chalmers recent MRI<\/div>"},"minutesDuration":15,"reason":{"text":"Clinical Review","coding":[{"code":"413095006","system":"http:\/\/snomed.info\/sct"}]},"identifier":[{"value":"205829917224247","system":"http:\/\/happyvalley.com\/appointment"}],"participant":[{"status":"needs-action","required":"required","actor":{"reference":"Patient\/example","display":"Peter James Chalmers"}},{"type":[{"coding":[{"display":"attender","code":"ATND","system":"http:\/\/hl7.org\/fhir\/v3\/ParticipationType"}]}],"required":"required","status":"needs-action"},{"status":"accepted","required":"required","actor":{"reference":"Location\/1","display":"South Wing, second floor"}}],"type":{"coding":{"display":"Preventive medicine","code":"409968004","system":"http:\/\/snomed.info\/sct"}},"comment":"Further expand on the results of the MRI and determine the next actions that may be appropriate.","priority":5,"description":"Discuss results of Peter James Chalmers recent MRI"}}]])
    end)
end)