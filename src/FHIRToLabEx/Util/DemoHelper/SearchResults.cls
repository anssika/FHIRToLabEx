Class FHIRToLabEx.Util.DemoHelper.SearchResults Extends FHIRToLabEx.Util.DemoHelper
{

ClassMethod OnBody() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	#Dim i As %Integer
	#Dim tKey As %String
	#Dim tCountResults As %Integer
	#Dim tResources As %ArrayOfObjects
	#Dim iResult As %Integer
	#Dim tResult As %DynamicObject
	#Dim tBundle As %DynamicObject
	#Dim tObject As %DynamicAbstractObject

	Try {

		&Html<<p><a href="FHIRToLabEx.Util.DemoHelper.cls">Home</a></p>>

		/*
		** DiagnosticResult
		*/

		Set tCountResults = ..GetResults(.tBundle, "_sort=-_lastUpdated")

		Set tResources = ##class(%ArrayOfObjects).%New()
		For iResult = 1:1:tCountResults {
			Set tResult = tBundle.entry.%Get(iResult-1).resource
			Do tResources.SetAt(tResult, $ZDateTimeH($Translate(tResult.meta.lastUpdated, "TZ", " "), 3))
		}

		&Html<<h2>DiagnosticResult resources - latest first</h2>>

		&Html<<p><table>>
		&Html<<tr><th>id</th><th>meta.lastUpdated</th><th>basedOn</th></tr>>
		Set tKey = tResources.Previous("")
		While (tKey '= "") {
			Set tResult = tResources.GetAt(tKey)

			If ('$IsObject(tResult)) {
				&Html<tBundle = #(tBundle)#<br>>
				&Html<tBundle.entry = #(tBundle.entry)#<br>>
				Return
			}
			&Html<<tr>>
			&Html<<td>#(tResult.id)#</td>>
			&Html<<td>#(tResult.meta.lastUpdated)#</td>>
			&Html<<td>>
			For i=0:1:99 {
				Set tObject = tResult.basedOn.%Get(i)
				If ('$IsObject(tObject)) Quit
				Write:i ", "
				&Html<#(tObject.reference)#>
			}
			&Html<</td>>
			&Html<</tr>>

			Set tKey = tResources.Previous(tKey)
		}
		&Html<</table></p>>

		/*
		** Examples
		*/

		&Html<<p>base URL = http://localhost:52775/fhirtolabex/fhir/r4/</p>>
		&Html<<p>DiagnosticReport?_lastUpdated=ge<strong>2022-09-13</strong>>
		&Html<<br>DiagnosticReport?based-on=<strong>ServiceRequest/3</strong>>
		&Html<<br>DiagnosticReport?based-on:ServiceRequest.subject=<strong>Patient/1</strong>>
		&Html<<br>DiagnosticReport?based-on:ServiceRequest.subject:Patient.identifier=<strong>010101-127N</strong>>
		&Html<<br>DiagnosticReport?based-on:ServiceRequest.subject:Patient.identifier=urn:oid:1.2.246.21|<strong>010101-127N</strong>>
		&Html<<br>DiagnosticReport?based-on:ServiceRequest.subject:Patient.identifier=urn:oid:1.2.246.21|<strong>010101-127N</strong>&_lastUpdated=<strong>ge2022-09-13</strong></p>>

		&Html<<p>You can even DELETE DiagnosticReport resources, but be aware that <strong>no checks are done & no business rules are applied</strong>>

		/*
		** ServiceRequest
		*/

		Do ..ListRequests()

		/*
		** Patient
		*/

		Do ..ListPatients()
	}
	Catch tException {
		//Set tStatus = tException.AsStatus()
		#Dim tError As %String = tException.DisplayString()
		&Html<<p>#(tError)#</p>>
	}

	Return tStatus
}

ClassMethod OnPageV2() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	Try {

		&Html<<p><a href="FHIRToLabEx.Util.DemoHelper.cls">Home</a></p>>

		&Html<<h2>DiagnosticResult resources - latest first(4)</h2>>

		#Dim tBundle As %DynamicObject
		#Dim tCountResults As %Integer = ..GetResults(.tBundle, "_sort=-_lastUpdated")
		//#Dim tCountResults As %Integer = ..GetResults(.tBundle, "_sort=_id")
		&Html<<p><table>>
		&Html<<tr><th>id</th><th>meta.lastUpdated</th></tr>>
		#Dim iResult As %Integer
		For iResult = 1:1:tCountResults {
			#Dim tResult As %DynamicObject = tBundle.entry.%Get(iResult-1).resource
			If ('$IsObject(tResult)) {
				&Html<tBundle = #(tBundle)#<br>>
				&Html<tBundle.entry = #(tBundle.entry)#<br>>
				Return
			}
			&Html<<tr>>
			&Html<<td>#(tResult.id)#</td>>
			&Html<<td>#(tResult.meta.lastUpdated)#</td>>
			&Html<</tr>>
		}
		&Html<</table></p>>
	}
	Catch tException {
		//Set tStatus = tException.AsStatus()
		#Dim tError As %String = tException.DisplayString()
		&Html<<p>#(tError)#</p>>
	}

	Return tStatus
}

ClassMethod OnPageV01() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	Try {

		&Html<<p><a href="FHIRToLabEx.Util.DemoHelper.cls">Home</a></p>>

		&Html<<h2>DiagnosticResult resources - latest first</h2>>

		#Dim tBundle As %DynamicObject
		//#Dim tCountResults As %Integer = ..GetResults(.tBundle, "_sort=_lastUpdated")
		#Dim tCountResults As %Integer = ..GetResults(.tBundle, "_sort=-_id")
		&Html<<p><table>>
		#Dim iResult As %Integer
		For iResult = 1:1:tCountResults {
			#Dim tResult As %DynamicObject = tBundle.entry.%Get(iResult-1).resource
			If ('$IsObject(tResult)) {
				&Html<tBundle = #(tBundle)#<br>>
				&Html<tBundle.entry = #(tBundle.entry)#<br>>
				Return
			}
			&Html<<tr>>
			&Html<<td>#(tResult.id)#</td>>
			&Html<<td>#(tResult.meta.lastUpdated)#</td>>
			&Html<<td>#(tResult.meta.lastUpdated)#</td>>
			&Html<</tr>>
		}
		&Html<</table></p>>
	}
	Catch tException {
		//Set tStatus = tException.AsStatus()
		#Dim tError As %String = tException.DisplayString()
		&Html<<p>#(tError)#</p>>
	}

	Return tStatus
}

}
