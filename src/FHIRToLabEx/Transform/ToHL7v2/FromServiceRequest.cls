Class FHIRToLabEx.Transform.ToHL7v2.FromServiceRequest Extends Ens.DataTransform [ DependsOn = (HS.FHIR.DTL.vR4.Model.Resource.Encounter, EnsLib.HL7.Message) ]
{

ClassMethod Transform(pSource As %RegisteredObject, ByRef pHL7v2Message As EnsLib.HL7.Message) As %Status
{
	#Dim pServiceRequest As %DynamicObject = pSource

	#Dim tStatus As %Status = $$$OK

	#Dim tHL7v2DateTime As %String = ""

	#Dim tException As %Exception.AbstractException
	Try {
		// ORC
		Set tStatus = pHL7v2Message.SetValueAt(pServiceRequest.identifier.%Get(0).value,"ORCgrp(1).ORC:2.1")
		Set tStatus = pHL7v2Message.SetValueAt(pServiceRequest.status,"ORCgrp(1).ORC:5")
		If ((pServiceRequest.reasonCode '= "") && (pServiceRequest.reasonCode.%Get(0).coding '= "")) {
			Set tStatus = pHL7v2Message.SetValueAt(pServiceRequest.reasonCode.%Get(0).coding.%Get(0).code, "ORCgrp(1).ORC:16.1")
			Set tStatus = pHL7v2Message.SetValueAt(pServiceRequest.reasonCode.%Get(0).coding.%Get(0).display, "ORCgrp(1).ORC:16.2")
			Set tStatus = pHL7v2Message.SetValueAt(pServiceRequest.reasonCode.%Get(0).coding.%Get(0).system, "ORCgrp(1).ORC:16.3")
		}

		// OBR
		If ((pServiceRequest.code '= "")) {
			Set tStatus = pHL7v2Message.SetValueAt(pServiceRequest.code.text,"ORCgrp(1).OBRuniongrp.OBRunion.OBR:4.2")
			If ((pServiceRequest.code.coding '= "") && (pServiceRequest.code.coding.%Get(0).code '= "")) {
				Set tStatus = pHL7v2Message.SetValueAt(pServiceRequest.code.coding.%Get(0).code,"ORCgrp(1).OBRuniongrp.OBRunion.OBR:4.1")
				Set tStatus = pHL7v2Message.SetValueAt(pServiceRequest.code.coding.%Get(0).system,"ORCgrp(1).OBRuniongrp.OBRunion.OBR:4.3")
			}
		}
		If ((pServiceRequest.occurrenceDateTime '= "")) {
			// e.g. "2013-05-02T16:16:00-07:00" --> 201305021616
			Set tHL7v2DateTime = $Translate($Piece(pServiceRequest.occurrenceDateTime, ":", 1,2), "-T:")
			Set tStatus = pHL7v2Message.SetValueAt(tHL7v2DateTime, "ORCgrp(1).OBRuniongrp.OBRunion.OBR:7.1")
		}
	}
	Catch (tException) {
		Set tStatus = tException.AsStatus()
	}
	Return tStatus
}

/// Do ##class(FHIRToLabEx.Transform.ToHL7v2.FromServiceRequest).Test()
ClassMethod Test()
{
	#Dim tStatus As %Status = $$$OK

	// Get test Encounter

	Set tXData = ##class(%Dictionary.XDataDefinition).%OpenId(..%ClassName(1) _ "||TestServiceRequest",, .tStatus)
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	#Dim tEncounter As %DynamicObject = ##class(%DynamicObject).%FromJSON(tXData.Data)

	// Create HL7 message

	#Dim tHL7Message As EnsLib.HL7.Message = ##class(EnsLib.HL7.Message).%New()
	Do tHL7Message.PokeDocType("2.3:ORM_O01")		// This is the document type for ADT A04 messages
	Do tHL7Message.SetValueAt("ORM", "MSH:9.1")
	Do tHL7Message.SetValueAt("O01", "MSH:9.2")

	// Do transformations

	Set tStatus = ##class(FHIRToLabEx.Transform.ToHL7v2.MSH).Transform(tHL7Message, .tHL7Message)
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
	Set tStatus = ##class(FHIRToLabEx.Transform.ToHL7v2.FromServiceRequest).Transform(tEncounter, .tHL7Message)
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)

	// Display HL7 message

	Write $Replace(tHL7Message.OutputToString(), $Char(13), $Char(13,10))
}

XData TestServiceRequest [ MimeType = application/json ]
{
{
  "resourceType": "ServiceRequest",
  "id": "1",
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
      "value": "2345234234234"
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
  "occurrenceDateTime": "2013-05-02T16:16:00-07:00",
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
