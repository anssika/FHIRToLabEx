Class FHIRToLabEx.Util.DemoHelper.PostAPatient Extends FHIRToLabEx.Util.DemoHelper
{

ClassMethod OnBody() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	#Dim tJSON As %String

	Try {

		&Html<<p><a href="FHIRToLabEx.Util.DemoHelper.cls">Home</a></p>>

		Do ..ListPatients()

		&Html<<h2>To POST a new Patient resource with unique identifier:</h2>>
		&Html<<p>base URL = http://localhost:52775/fhirtolabex/fhir/r4/</p>>
		&Html<<p>Use Content-Type <strong>application/fhir+json</strong></p>>
		&Html<<p>Check that the identifier(s) are unique</p>>

		Set tXData = ##class(%Dictionary.XDataDefinition).%OpenId(..%ClassName(1) _ "||PatientMinimal",, .tStatus)
		If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
		Set tJSON = tXData.Data.Read()
		&Html<<p>A "minimal" Patient resource:<br>
				<textarea id="mp" name="mp" rows="4" cols="50">#(tJSON)#</textarea></p>>

		Set tXData = ##class(%Dictionary.XDataDefinition).%OpenId(..%ClassName(1) _ "||PatientFull",, .tStatus)
		If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
		Set tJSON = tXData.Data.Read()
		&Html<<p>A "full" Patient resource:<br>
				<textarea id="mp" name="mp" rows="4" cols="50">#(tJSON)#</textarea></p>>
	}
	Catch tException {
		//Set tStatus = tException.AsStatus()
		#Dim tError As %String = tException.DisplayString()
		&Html<<p>#(tError)#</p>>
	}

	Return tStatus
}

XData PatientMinimal [ MimeType = application/json ]
{
{
	"resourceType": "Patient",
	"identifier":  [
		{
            "use": "official",
            "system": "urn:oid:1.2.246.21",
            "value": "010101-127N"
        }
    ],
	"name": [
        {
            "family": "Sairas",
            "given":  [
                "Veli"
            ]
        }
    ]
}
}

XData PatientFull [ MimeType = application/json ]
{
{
    "resourceType": "Patient",
    "extension":  [
        {
            "url": "http://hl7.fi/fhir/StructureDefinition/HomeMunicipalityExtension",
            "valueCoding": {
                "system": "urn:oid:1.2.246.537.6.21.2003",
                "code": "564",
                "display": "Oulu"
            }
        }
    ],
    "identifier":  [
        {
            "use": "official",
            "system": "urn:oid:1.2.246.21",
            "value": "010101-124N"
        },
        {
            "system": "urn:syl.fi",
            "value": "STU09001"
        }
    ],
    "name":  [
        {
            "family": "Sairas",
            "given":  [
                "Veli"
            ]
        }
    ],
    "telecom":  [
        {
           "system": "email",
           "use": "home",
            "value": "veli.sairas@veli.fi"
        },
        {
           "system": "phone",
           "use": "home",
            "value": "+3581234561"
        },
        {
           "system": "phone",
           "use": "mobile",
            "value": "+3581234562"
        },
        {
           "system": "phone",
           "use": "work",
            "value": "+3581234563"
        }
    ],
    "gender": "male",
    "birthDate": "1901-01-01",
    "deceasedDateTime": "2021-08-10T12:42:00+02:00",
    "address":  [
        {
            "use": "home",
            "line": [
                "Terveystie 1"
            ],
            "postalCode": "01100",
            "city": "Oulu"
        },
        {
            "use": "work",
            "line": [
                "c/o pa",
                "Rasitustie 1"
            ],
            "postalCode": "01200",
            "city": "Kempele"
        }
    ],
    "contact":  [
        {
            "relationship":  [
                {
                    "coding":  [
                        {
                            "system": "urn:oid:1.2.246.537.6.882",
                            "code": "1",
                            "display": "Huoltaja"
                        }
                    ]
                }
            ],
            "name": {
                "family": "Sairas",
                "given":  [
                    "Mamma"
                ]
            },
            "telecom":  [
                {
                    "system": "sms",
                    "value": "+3581234566"
                }
            ]
        }
    ],
    "communication":  [
        {
            "language": {
                "coding":  [
                    {
                        "system": "urn:oid:1.2.246.537.5.40175",
                        "code": "FI",
                        "display": "Suomi"
                    }
                ]
            }
        }
    ]
}
}

}
