/// This implementation uses FHIR class model in logic and transformations
Class FHIRToLabEx.Process.FHIRServiceRequestProcessor Extends (Ens.BusinessProcess, FHIRToLabEx.Util.FHIRClient, HS.HC.Util.Trace.Helper) [ ClassType = persistent, ProcedureBlock ]
{

/// Name of the business host to send HL7v2 messages to
Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "To_Laboratory" ];

Parameter SETTINGS = "TargetConfigName:Basic";

Method OnRequest(pRequest As HS.FHIRServer.Interop.Request, Output pResponse As HS.FHIRServer.Interop.Response) As %Status
{
	#Dim tStatus As %Status = $$$OK

	/* ********************************************************************************
	**	Filter out interactions not supported by this process
	**
	**	This is just an extra precaution as there shoud be a routing process
	**	doing the routing/filtering.
	*/

	#Dim tResourceType As %String = $Piece(pRequest.Request.RequestPath, "/", 1)
	If (tResourceType '= "ServiceRequest") {
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
	**	Get the ServiceRequest resource from incoming JSON stream
	*/

	#Dim tQuickStream As HS.SDA3.QuickStream = ##class(HS.SDA3.QuickStream).%OpenId(pRequest.QuickStreamId)
	#Dim tServiceRequest As %DynamicObject = {}.%FromJSON(tQuickStream)

	/* ********************************************************************************
	**	If POST:
	**	 - check that the identifier does not already exist
	*/
	If (tRequestMethod = "POST") {
		$$$LOGINFO("Checking that the ServiceRequest (the first identifier) does not already exist ...")
		If ((tServiceRequest.identifier '= "") && (tServiceRequest.identifier.%Get(0) '= "") && (tServiceRequest.identifier.%Get(0).value '= "")) {
			#Dim tIdentifier As %String = tServiceRequest.identifier.%Get(0).value
			#Dim tBundle As %DynamicObject = $$$NULLOREF
			Set tStatus = ..InvokeFHIR(..FHIRRequest("GET", "ServiceRequest", "identifier=" _ tIdentifier), .tBundle)
			If ($$$ISERR(tStatus)) Return tStatus

			If (tBundle.total > 0) {
				Set tStatus = ##class(FHIRToLabEx.Util.FHIRMessage).FHIRServerInteropResponseError(.pResponse, 400,, "ServiceRequest already exists", "A ServiceRequest resource with identifier " _ tIdentifier _ " already exists")
				Do ..HSTraceResponse(pResponse)
				Return tStatus
			}
		}
		Else {	
			Set tStatus = ##class(FHIRToLabEx.Util.FHIRMessage).FHIRServerInteropResponseError(.pResponse, 400,, "Identifier missing", "The ServiceRequest resource does not have any identifier")
			If ($$$ISOK(tStatus)) Do ..HSTraceResponse(pResponse)
			Return tStatus
		}
	}

	/* ********************************************************************************
	**	Get the Patient resource referred to in ServiceRequest
	*/
	$$$LOGINFO("Looking for the Patient referred to in ServiceRequest ...")
	#Dim tPatient As %DynamicObject = $$$NULLOREF
	If ((tServiceRequest.subject '= "") && (tServiceRequest.subject.reference '= "") && ($Find(tServiceRequest.subject.reference, "Patient/"))) {

		Set tStatus = ..InvokeFHIR(..FHIRRequest("GET", tServiceRequest.subject.reference), .tPatient)
		If ($$$ISERR(tStatus)) Return tStatus

		If ('$IsObject(tPatient)) {
			Set tStatus = $$$ERROR($$$GeneralError, "Patient '" _ tServiceRequest.subject.reference _ "' not known (not found in FHIR resource repository)")
			If ($$$ISOK(tStatus)) Do ..HSTraceResponse(pResponse)
			Return tStatus
		}
	}
	Else {
		Set tStatus = $$$ERROR($$$GeneralError, "No patient reference found (subject.reference is empty or does not exist)")
		If ($$$ISOK(tStatus)) Do ..HSTraceResponse(pResponse)
		Return tStatus
	}

	/* ********************************************************************************
	**	Get the Encounter resource referred to in ServiceRequest
	*/
	$$$LOGWARNING("NOT IMPLEMENTED: Looking for the Encounter referred to in ServiceRequest ...")

	/* ********************************************************************************
	**	Get the Practitioner resource referred to in ServiceRequest
	*/
	$$$LOGWARNING("NOT IMPLEMENTED: Looking for the Practitioner referred to in ServiceRequest ...")

	/* ********************************************************************************
	**	Create ORM O01 Message by applying (generic) transformations from:
	**	- context (MSH segment)
	**	- ServiceRequest resource
	**	- Patient resource (PID segment)
	*/

	$$$LOGINFO("Creating HL7 v2 message...")
	// Create the specific HL7v2 message: ORM O01
	#Dim tHL7Message As EnsLib.HL7.Message = ##class(EnsLib.HL7.Message).%New()
	Do tHL7Message.PokeDocType("2.3:ORM_O01")		// This is the document type for ORM O01 messages
	Do tHL7Message.SetValueAt("ORM", "MSH:9.1")
	Do tHL7Message.SetValueAt("O01", "MSH:9.2")

	// Context - some fields in message hearder
	Set tStatus = ##class(FHIRToLabEx.Transform.ToHL7v2.MSH).Transform(tHL7Message, .tHL7Message)
	If ($$$ISERR(tStatus)) Return tStatus

	// ServiceRequest resource - see https://www.hl7.org/fhir/encounter-mappings.html#v2
	Set tStatus = ##class(FHIRToLabEx.Transform.ToHL7v2.FromServiceRequest).Transform(tServiceRequest, .tHL7Message)
	If ($$$ISERR(tStatus)) Return tStatus

	// Patient resource to PID segment - see https://www.hl7.org/fhir/patient-mappings.html#v2
	If ($IsObject(tPatient)) {
		#Dim tHL7Segment As EnsLib.HL7.Segment
		Set tStatus = ##class(EskoI.FromCore.ToHL7v2.General.Transform.FromPatientToPIDSegment).Transform(tPatient, .tHL7Segment)
		If ($$$ISERR(tStatus)) Return tStatus

		Set tStatus = tHL7Message.SetSegmentAt(tHL7Segment, "PIDgrp.PID")
		If ($$$ISERR(tStatus)) Return tStatus
	}

	/* ********************************************************************************
	**	Send the request to FHIR repository
	*/
	$$$LOGINFO("Saving ServiceRequest in local FHIR repository ...")
	Set tStatus = ..InvokeFHIR(pRequest,, .pResponse)
	If ($$$ISERR(tStatus)) Return tStatus

	/* ********************************************************************************
	**	Send to HL7v2 message routing production
	*/
	$$$LOGINFO("Sending HL7 v2 message...")
	Set tStatus = ..SendRequestAsync(..TargetConfigName, tHL7Message, 0)
	If ($$$ISOK(tStatus)) Do ..HSTraceResponse(pResponse)

	Return tStatus
}

Method ProcessDELETE(pRequest As HS.FHIRServer.Interop.Request, Output pResponse As HS.FHIRServer.Interop.Response) As %Status
{
	#Dim tStatus As %Status = $$$OK

	#Dim tId As %String = $Piece(pRequest.Request.RequestPath, "/", 2)

	$$$LOGINFO("Checking that the ServiceRequest is not referred to ...")
	#Dim tBundle As %DynamicObject = $$$NULLOREF
	Set tStatus = ..InvokeFHIR(..FHIRRequest("GET", "DiagnosticReport", "based-on=ServiceRequest/" _ tId), .tBundle)
	If ($$$ISERR(tStatus)) Return tStatus

	If (tBundle.total > 0) {
		Set tStatus = ##class(FHIRToLabEx.Util.FHIRMessage).FHIRServerInteropResponseError(.pResponse, 400,, "ServiceRequest is referred to", "The ServiceRequest with id " _ tId _ " is referred to in DiagnosticReport resource(s)")
		If ($$$ISOK(tStatus)) Do ..HSTraceResponse(pResponse)
		Return tStatus
	}

	$$$LOGINFO("Deleting the ServiceRequest in local FHIR repository ...")
	Set tStatus = ..InvokeFHIR(pRequest,, .pResponse)
	If ($$$ISOK(tStatus)) Do ..HSTraceResponse(pResponse)

	Return tStatus
}

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

Storage Default
{
<Data name="FHIRServiceRequestProcessorDefaultData">
<Subscript>"FHIRServiceRequestProcessor"</Subscript>
<Value name="1">
<Value>TargetConfigName</Value>
</Value>
<Value name="2">
<Value>FHIRResourceRepository</Value>
</Value>
<Value name="3">
<Value>FHIRInteractionNotSupported</Value>
</Value>
<Value name="4">
<Value>FHIREndpointURL</Value>
</Value>
<Value name="5">
<Value>TraceOperations</Value>
</Value>
</Data>
<DefaultData>FHIRServiceRequestProcessorDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
