Class FHIRToLabEx.Transform.FromHL7v2.ToDiagnosticReport Extends Ens.DataTransform [ DependsOn = (HS.FHIR.DTL.vR4.Model.Resource.Encounter, EnsLib.HL7.Message) ]
{

ClassMethod Transform(pORUR01 As EnsLib.HL7.Message, ByRef pTarget As %RegisteredObject = {$$$NULLOREF}) As %Status
{
	#Dim tStatus As %Status = $$$OK

	#Dim tDiagnosticReport As %DynamicObject = pTarget
	If ('$IsObject(tDiagnosticReport)) {
		Set tDiagnosticReport = {
				"resourceType": "DiagnosticReport"
			}
	}

	#Dim tException As %Exception.AbstractException
	Try {
		// code of the diagnostic report
		Set tDiagnosticReport.code = { "coding": [ {} ] }
 //$$$LOGINFO("1: " _ tDiagnosticReport)
 //$$$LOGINFO("2: " _ tDiagnosticReport.code)
 //$$$LOGINFO("3: " _ tDiagnosticReport.code.coding)
 //$$$LOGINFO("4: " _ tDiagnosticReport.code.coding.%Get(0))
 //$$$LOGINFO("5: " _ tDiagnosticReport.code.coding.%Get(0).code)
 //$$$LOGINFO("6: " _ pORUR01)
 //$$$LOGINFO("7: " _ pORUR01.GetValueAt("PIDgrpgrp(1).ORCgrp(1).OBR:4.1"))
 //$$$LOGINFO("8")
		Set tDiagnosticReport.code.coding.%Get(0).code = pORUR01.GetValueAt("PIDgrpgrp(1).ORCgrp(1).OBR:4.1")
 //$$$LOGINFO("9")
		Set tDiagnosticReport.code.coding.%Get(0).display = pORUR01.GetValueAt("PIDgrpgrp(1).ORCgrp(1).OBR:4.2")
		Set tDiagnosticReport.code.coding.%Get(0).system = pORUR01.GetValueAt("PIDgrpgrp(1).ORCgrp(1).OBR:4.3")

		// status - should in OBR-25, but is it?
		Set tDiagnosticReport.status = "final"
	}
	Catch (tException) {
		Set tStatus = tException.AsStatus()
	}

	Set pTarget = tDiagnosticReport
	Return tStatus
}

/// Do ##class(FHIRToLabEx.Transform.FromHL7v2.ToDiagnosticReport).Test()
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
	Set tStatus = ##class(FHIRToLabEx.Transform.FromHL7v2.ToDiagnosticReport).Transform(tEncounter, .tHL7Message)
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
