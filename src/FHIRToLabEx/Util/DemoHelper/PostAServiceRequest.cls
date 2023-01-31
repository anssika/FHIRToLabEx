Class FHIRToLabEx.Util.DemoHelper.PostAServiceRequest Extends FHIRToLabEx.Util.DemoHelper
{

ClassMethod OnBody() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	#Dim tJSON As %String

	Try {

		&Html<<p><a href="FHIRToLabEx.Util.DemoHelper.cls">Home</a></p>>

		Do ..ListPatients()

		Do ..ListRequests()

		&Html<<h2>To POST a new ServiceRequest resource:</h2>>
		&Html<<p>base URL = http://localhost:52775/fhirtolabex/fhir/r4/</p>>
		&Html<<p>Use Content-Type <strong>application/fhir+json</strong></p>>
		&Html<<p>Check that the <strong>identifier(s)</strong> are unique and <strong>subject</strong> refers to a Patient resource that exists</p>>

		Set tXData = ##class(%Dictionary.XDataDefinition).%OpenId(..%ClassName(1) _ "||ServiceRequestMinimal",, .tStatus)
		If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
		Set tJSON = tXData.Data.Read()
		&Html<<p>A "minimal" ServiceRequest resource:<br>
				<textarea id="mp" name="mp" rows="18" cols="70">#(tJSON)#</textarea></p>>
	}
	Catch tException {
		//Set tStatus = tException.AsStatus()
		#Dim tError As %String = tException.DisplayString()
		&Html<<p>#(tError)#</p>>
	}

	Return tStatus
}

XData ServiceRequestMinimal [ MimeType = application/json ]
{
{
  "resourceType": "ServiceRequest",
  "identifier": [
    {
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "PLAC"
          }
        ],
        "text": "Placer"
      },
      "system": "urn:oid:1.3.4.5.6.7",
      "value": "1111"
    }
  ],
  "status": "active",
  "intent": "original-order",
  "code": {
    "coding": [
      {
        "system": "http://acme.org/tests",
        "code": "LIPID"
      }
    ],
    "text": "Lipid Panel"
  },
  "subject": {
    "reference": "Patient/1"
  },
  "encounter": {
    "reference": "Encounter/1"
  },
  "occurrenceDateTime": "2012-11-25T16:16:00-07:00",
  "requester": {
    "reference": "Practitioner/1"
  },
  "performer": [
    {
      "reference": "Practitioner/2"
    }
  ],
  "reasonCode": [
    {
      "coding": [
        {
          "system": "http://hl7.org/fhir/sid/icd-9",
          "code": "V173",
          "display": "Fam hx-ischem heart dis"
        }
      ]
    }
  ]
}
}

}
