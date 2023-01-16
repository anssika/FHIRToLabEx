Class FHIRToLabEx.Util.FHIRMessage
{

ClassMethod FHIRServerInteropResponseError(Output pResponse As HS.FHIRServer.Interop.Response, pHTTPStatusCode As %String, pSeverity As %String = "error", pCode As %String = "", pDetails As %String = "") As %Status
{
	#Dim tStatus As %Status = $$$OK

	Set pResponse = ##class(HS.FHIRServer.Interop.Response).%New()
	Set pResponse.Response = ##class(HS.FHIRServer.API.Data.Response).%New()
	Set pResponse.Response.Status = pHTTPStatusCode
	Set pResponse.Response.ResponseFormatCode = "JSON"
	Set pResponse.ContentType = "application/fhir+json"
	Set pResponse.CharSet = "UTF-8"

	#Dim tCode As %String = pCode
	If (tCode = "") {
		If (+pHTTPStatusCode = 404) Set tCode = "not-found"
		// ToDo
	}

	If ((pSeverity '= "") || (pCode '= "") || (pDetails '= "")) {
		#Dim tOperationOutcome As HS.FHIR.DTL.vR4.Model.Resource.OperationOutcome
		Set tOperationOutcome = ##class(HS.FHIR.DTL.vR4.Model.Resource.OperationOutcome).%New()
		Do tOperationOutcome.issue.Insert(##class(HS.FHIR.DTL.vR4.Model.Element.OperationOutcome.issue).%New())
		If (pSeverity '= "") {
			Set tOperationOutcome.issue.GetAt(1).severity = pSeverity
		}
		Set tOperationOutcome.issue.GetAt(1).code = tCode
		If (pDetails '= "") {
			Set tOperationOutcome.issue.GetAt(1).details = ##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()
			Set tOperationOutcome.issue.GetAt(1).details.text = pDetails
		}

		#Dim tQuickStream = ##class(HS.SDA3.QuickStream).%New()
		Do tQuickStream.CopyFrom(tOperationOutcome.ToJSON())
		Set pResponse.QuickStreamId = tQuickStream.%Id()
	}

	Return $$$OK
}

}
