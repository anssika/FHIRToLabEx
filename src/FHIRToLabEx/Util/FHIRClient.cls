/// This implementation uses FHIR class model in logic and transformations
Class FHIRToLabEx.Util.FHIRClient Extends (Ens.Host, Ens.Settings) [ ProcedureBlock ]
{

/// Name of the business host for local FHIR interactions
Property FHIRResourceRepository As Ens.DataType.ConfigName [ InitialExpression = "FHIRResourceRepository" ];

/// URL of the FHIR end point for local FHIR interactions, e.g. /fhirtolabex/fhir/r4
Property FHIREndpointURL As %String [ InitialExpression = "/fhirtolabex/fhir/r4" ];

Parameter SETTINGS = "FHIRResourceRepository:Basic,FHIREndpointURL:Basic";

Method FHIRRequest(pRequestMethod As %String, pRequestPath As %String, pQueryString As %String = "", pBody As %DynamicObject = {$$$NULLOREF}) As HS.FHIRServer.Interop.Request
{
	#Dim tRequest As HS.FHIRServer.Interop.Request = ##class(HS.FHIRServer.Interop.Request).%New()
	Set tRequest.Request.SessionApplication = ..FHIREndpointURL
	Set tRequest.Request.RequestMethod = pRequestMethod
	Set tRequest.Request.RequestPath = pRequestPath
	Set tRequest.Request.QueryString = pQueryString
	Set tRequest.Request.RequestFormatCode = "JSON"
	Set tRequest.Request.ResponseFormatCode = "JSON"

	If ($IsObject(pBody)) {
		Set tQuickStream = ##class(HS.SDA3.QuickStream).%New()
		Do tQuickStream.Write(pBody.%ToJSON())
		Set tRequest.QuickStreamId = tQuickStream.%Id()
	}

	Return tRequest
}

Method InvokeFHIR(pRequest As HS.FHIRServer.Interop.Request, Output pResponseBody As %DynamicObject = {$$$NULLOREF}, Output pResponse As HS.FHIRServer.Interop.Response = {$$$NULLOREF}) As %Status
{
	#Dim tStatus As %Status = $$$OK

    Set tStatus = ..SendRequestSync(..FHIRResourceRepository, pRequest, .pResponse, 5)
	If ($$$ISERR(tStatus)) Return tStatus

	If ('$IsObject(pResponse)) {
		Return $$$ERROR($$$GeneralError, "Timeout when waiting for response from business host '" _ ..FHIRResourceRepository _ "' to request '" _ pRequest.Request.RequestPath _ "'")
	}

	If (pResponse.QuickStreamId '= "") {
		#Dim tQuickStream As HS.SDA3.QuickStream = ##class(HS.SDA3.QuickStream).%OpenId(pResponse.QuickStreamId)
		Set pResponseBody = {}.%FromJSON(tQuickStream)
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
