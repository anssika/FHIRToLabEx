/// This implementation uses FHIR class model in logic and transformations
Class FHIRToLabEx.Process.FHIRPatientProcessor Extends (Ens.BusinessProcess, FHIRToLabEx.Util.FHIRClient, HS.HC.Util.Trace.Helper) [ ClassType = persistent, ProcedureBlock ]
{

/// Code system of the Patient identifier
Parameter IDENTIFIERSYSTEM = "urn:oid:1.2.246.21";

Method OnRequest(pRequest As FHIRToLabEx.FHIRServer.Interop.Request, Output pResponse As FHIRToLabEx.FHIRServer.Interop.Response) As %Status
{
	#Dim tStatus As %Status = $$$OK

	/* ********************************************************************************
	**	Filter out interactions not supported by this process
	**
	**	This is just an extra precaution as there shoud be a routing process
	**	doing the routing/filtering.
	*/

	#Dim tResourceType As %String = $Piece(pRequest.Request.RequestPath, "/", 1)
	If (tResourceType '= "Patient") {
		Return $$$ERROR($$$GeneralError, "Resource type '" _ tResourceType _ "' not handled by this process")
	}

	#Dim tRequestMethod As %String = pRequest.Request.RequestMethod
	If ((tRequestMethod '= "POST") && (tRequestMethod '= "PUT") && (tRequestMethod '= "DELETE")) {
		Return $$$ERROR($$$GeneralError, "Request method '" _ tRequestMethod _ "' not handled by this process")
	}

	/* ********************************************************************************
	**	Processing DELETE is different from processing POST or PUT
	*/
	If (tRequestMethod = "DELETE") {
		Return ..ProcessDELETE(pRequest, .pResponse)
	}

	/* ********************************************************************************
	**
	**	Start processing POST or PUT
	**
	**	Get the Patient resource from incoming JSON stream & the identifier
	*/

	#Dim tPatient As %DynamicObject = {}.%FromJSON(pRequest.Payload)
	#Dim tPatientIdentifier As %String = ""
	#Dim i As %Integer = 0
	While (tPatient.identifier.%Get(i) '= "") {
		#Dim tIdentifier As %DynamicObject = tPatient.identifier.%Get(i)
		If (tIdentifier.system = ..#IDENTIFIERSYSTEM) {
			Set tPatientIdentifier = tIdentifier.value
		}
		Set i = i + 1
	}

	If (tPatientIdentifier = "") {
		// No patient identifier
		Set tStatus = ##class(FHIRToLabEx.Util.FHIRMessage).FHIRServerInteropResponseError(.pResponse, 400,, "Identifier missing", "The Patient resource does not have any identifier with code system " _ ..#IDENTIFIERSYSTEM)
		//If ($$$ISOK(tStatus)) Do ..HSTraceResponse(pResponse)
		Return tStatus
	}

	/* ********************************************************************************
	**	If POST, check that there is no patient with with the same identifier
	*/
	If (tRequestMethod = "POST") {
		$$$LOGINFO("Checking that the identifier does not already exist ...")
		If ('..CheckPOST(tPatientIdentifier, .pResponse, .tStatus)) Return tStatus
	}

	/* ********************************************************************************
	**	If PUT, check that the identifier does not change
	*/
	If (tRequestMethod = "PUT") {
		$$$LOGWARNING("NOT IMPLEMENTED: Checking that the identifier will not change ...")
	}

	/* ********************************************************************************
	**	Send the request to FHIR repository
	*/
	$$$LOGINFO("Saving Patient in local FHIR repository ...")
	Set tStatus = ..InvokeFHIR(pRequest,, .pResponse)
	//If ($$$ISOK(tStatus)) Do ..HSTraceResponse(pResponse)

	Return tStatus
}

Method ProcessDELETE(pRequest As FHIRToLabEx.FHIRServer.Interop.Request, Output pResponse As FHIRToLabEx.FHIRServer.Interop.Response) As %Status
{
	#Dim tStatus As %Status = $$$OK

	#Dim tId As %String = $Piece(pRequest.Request.RequestPath, "/", 2)

	$$$LOGINFO("Checking that the patient is not referred to ...")
	#Dim tBundle As %DynamicObject = $$$NULLOREF
	Set tStatus = ..InvokeFHIR(..FHIRRequest("GET", "ServiceRequest", "patient=Patient/" _ tId), .tBundle)
	If ($$$ISERR(tStatus)) Return tStatus

	If (tBundle.total > 0) {
		Set tStatus = ##class(FHIRToLabEx.Util.FHIRMessage).FHIRServerInteropResponseError(.pResponse, 400,, "Patient is referred to", "The Patient with id " _ tId _ " is referred to in ServiceRequest resource(s)")
		//If ($$$ISOK(tStatus)) Do ..HSTraceResponse(pResponse)
		Return tStatus
	}

	$$$LOGINFO("Deleting the Patient in local FHIR repository ...")
	Set tStatus = ..InvokeFHIR(pRequest,, .pResponse)
	//If ($$$ISOK(tStatus)) Do ..HSTraceResponse(pResponse)

	Return tStatus
}

/// Returns true, if the POST interaction is ok
Method CheckPOST(pIdentifier As %String, Output pResponse As FHIRToLabEx.FHIRServer.Interop.Response, Output pStatus As %Status = {$$$OK}) As %Boolean
{
	#Dim tBundle As %DynamicObject = $$$NULLOREF
	Set pStatus = ..InvokeFHIR(..FHIRRequest("GET", "Patient", "identifier=" _ pIdentifier), .tBundle)
	If ($$$ISERR(pStatus)) Return pStatus

	If (tBundle.total > 0) {
		Set pStatus = ##class(FHIRToLabEx.Util.FHIRMessage).FHIRServerInteropResponseError(.pResponse, 400,, "Patient already exists", "A Patient resource with identifier " _ pIdentifier _ " already exists")
		//Do ..HSTraceResponse(pResponse)
		Return 0
	}

	Return 1
}

/*
Method HSTraceResponse(pResponse As HS.FHIRServer.Interop.Response)
{
	If $$$HSTRACING {
		If pResponse.QuickStreamId'="" {
			Set quickStreamIn = ##class(HS.SDA3.QuickStream).%OpenId(pResponse.QuickStreamId)
			$$$HSTRACE("Response QuickStream", "quickStreamOut", pResponse, quickStreamIn)
		} Else {
			$$$HSTRACE("Response message", "pResponse", pResponse)
		}
	}
}
*/
Storage Default
{
<Data name="FHIRPatientProcessorDefaultData">
<Subscript>"FHIRPatientProcessor"</Subscript>
<Value name="1">
<Value>FHIRResourceRepository</Value>
</Value>
<Value name="2">
<Value>FHIREndpointURL</Value>
</Value>
<Value name="3">
<Value>FHIRInteractionNotSupported</Value>
</Value>
<Value name="4">
<Value>TargetConfigName</Value>
</Value>
<Value name="5">
<Value>TraceOperations</Value>
</Value>
</Data>
<DefaultData>FHIRPatientProcessorDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
