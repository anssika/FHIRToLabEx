Class FHIRToLabEx.Util.FHIRClient Extends (Ens.Host, Ens.Settings) [ ProcedureBlock ]
{

/// Name of the business host for local FHIR interactions
Property FHIRResourceRepository As Ens.DataType.ConfigName [ InitialExpression = "FHIRResourceRepository" ];

/// URL of the FHIR end point for local FHIR interactions, e.g. /fhirtolabex/fhir/r4
Property FHIREndpointURL As %String [ InitialExpression = "/fhirtolabex/fhir/r4" ];

Parameter SETTINGS = "FHIRResourceRepository:Basic,FHIREndpointURL:Basic";

Method FHIRRequest(pRequestMethod As %String, pRequestPath As %String, pQueryString As %String = "", pBody As %DynamicObject = {$$$NULLOREF}) As FHIRToLabEx.FHIRServer.Interop.Request
{
	#Dim tRequest As FHIRToLabEx.FHIRServer.Interop.Request = ##class(FHIRToLabEx.FHIRServer.Interop.Request).%New()
	Set tRequest.Request.SessionApplication = ..FHIREndpointURL
	Set tRequest.Request.RequestMethod = pRequestMethod
	Set tRequest.Request.RequestPath = pRequestPath
	Set tRequest.Request.QueryString = pQueryString
	Set tRequest.Request.RequestFormatCode = "JSON"
	Set tRequest.Request.ResponseFormatCode = "JSON"

	If ($IsObject(pBody)) {
		Do tRequest.Payload.Write(pBody.%ToJSON())
	}

	Return tRequest
}

Method InvokeFHIR(pRequest As FHIRToLabEx.FHIRServer.Interop.Request, Output pResponseBody As %DynamicObject = {$$$NULLOREF}, Output pResponse As FHIRToLabEx.FHIRServer.Interop.Response = {$$$NULLOREF}) As %Status
{
	#Dim tStatus As %Status = $$$OK

    Set tStatus = ..SendRequestSync(..FHIRResourceRepository, pRequest, .pResponse, 5)
	If ($$$ISERR(tStatus)) Return tStatus

	If ('$IsObject(pResponse)) {
		Return $$$ERROR($$$GeneralError, "Timeout when waiting for response from business host '" _ ..FHIRResourceRepository _ "' to request '" _ pRequest.Request.RequestPath _ "'")
	}

	If (pResponse.Payload.Size) {
		Set pResponseBody = {}.%FromJSON(pResponse.Payload)
	}

	Return tStatus
}

Storage Default
{
<Data name="FHIRClientDefaultData">
<Subscript>"FHIRClient"</Subscript>
<Value name="1">
<Value>FHIRResourceRepository</Value>
</Value>
<Value name="2">
<Value>FHIREndpointURL</Value>
</Value>
</Data>
<DefaultData>FHIRClientDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
