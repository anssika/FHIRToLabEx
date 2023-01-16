/// This implementation uses FHIR class model in logic and transformations
Class FHIRToLabEx.Process.HL7v2MessageProcessor Extends (Ens.BusinessProcess, FHIRToLabEx.Util.FHIRClient) [ ClassType = persistent, ProcedureBlock ]
{

Method OnRequest(pRequest As EnsLib.HL7.Message, Output pResponse As %Persistent) As %Status
{
	#Dim tStatus As %Status = $$$OK

	/* ********************************************************************************
	**	Filter out the types of messages not supported by this process
	*/

	// Only ORU R01 messages are accepted by this process
	If ((pRequest.GetValueAt("MSH:9.1") '= "ORU") || (pRequest.GetValueAt("MSH:9.2") '= "R01")) {
		Return $$$ERROR($$$GeneralError, "Unexpected message type: " _ pRequest.GetValueAt("MSH:9.1") _ " " _ pRequest.GetValueAt("MSH:9.2"))
	} 

	/* ********************************************************************************
	**	Extract the identifier of the service request
	*/

	#Dim tServiceRequestIdentifier As %String = pRequest.GetValueAt("PIDgrpgrp(1).ORCgrp(1).OBR:2(1).1")

	/* ********************************************************************************
	**	Find the ServiceRequest resource from local FHIR repository
	*/

	$$$LOGINFO("Looking for a ServiceRequest with Identifier = " _ tServiceRequestIdentifier)
	#Dim tBundle As %DynamicObject
	Set tStatus = ..InvokeFHIR(..FHIRRequest("GET", "ServiceRequest", "identifier=" _ tServiceRequestIdentifier), .tBundle)
	If ($$$ISERR(tStatus)) Return tStatus

	If (tBundle.total '= 1) {
		Return $$$ERROR($$$GeneralError, tBundle.total _ " resources found when expecting one ServiceRequest (identifier = " _ tServiceRequestIdentifier _ ")")
	}
	#Dim tServiceRequest As %DynamicObject = tBundle.entry.%Get(0).resource

	/* ********************************************************************************
	**	Check that the information matches (HL7 v2 message and ServiceRequest)
	*/
	$$$LOGWARNING("NOT IMPLEMENTED: check that the information in ORU R01 message matches the ServiceRequest")

	/* ********************************************************************************
	**	Create or update DiagnosticReport
	*/

	#Dim tDiagnosticReport As %DynamicObject

	$$$LOGINFO("Looking for a DiagnosticReport with Identifier = " _ tServiceRequestIdentifier)
	Set tStatus = ..InvokeFHIR(..FHIRRequest("GET", "DiagnosticReport", "based-on=ServiceRequest/" _ tServiceRequest.id), .tBundle)
	If ($$$ISERR(tStatus)) Return tStatus

	If (tBundle.total = 1) {
		Set tDiagnosticReport = tBundle.entry.%Get(0).resource
	}
	ElseIf (tBundle.total > 1) {
		Return $$$ERROR($$$GeneralError, tBundle.total _ " DiagnosticReport resources found when expecting just one (ServiceRequest = " _ tServiceRequestIdentifier _ ")")
	}
	// Else: there is no DiagnosticReport based on the ServiceRequest -> It will be created by the transformation

	// From ORU R01 message (create new DiagnosticReport or update an existing if given)
	Set tStatus = ##class(FHIRToLabEx.Transform.FromHL7v2.ToDiagnosticReport).Transform(pRequest, .tDiagnosticReport)
	If ($$$ISERR(tStatus)) Return tStatus

	// From ServiceRequest resource
	Set tDiagnosticReport.basedOn = [{ "reference": "" }]
	Set tDiagnosticReport.basedOn.%Get(0).reference = "ServiceRequest/" _ tServiceRequest.id

	// Create or Update DiagnosticReport
	If (tDiagnosticReport.id = "") {
		// Create
		Set tStatus = ..InvokeFHIR(..FHIRRequest("POST", "DiagnosticReport",, tDiagnosticReport))
	}
	Else {
		// Update
		Set tStatus = ..InvokeFHIR(..FHIRRequest("PUT", "DiagnosticReport/" _ tDiagnosticReport.id,, tDiagnosticReport))
	}
	If ($$$ISERR(tStatus)) Return tStatus

	/* ********************************************************************************
	**	Create or update Observation resources
	*/
	$$$LOGWARNING("NOT IMPLEMENTED: creating or updating Observations")

	Return tStatus
}

Storage Default
{
<Data name="HL7v2MessageProcessorDefaultData">
<Subscript>"HL7v2MessageProcessor"</Subscript>
<Value name="1">
<Value>FHIRResourceRepository</Value>
</Value>
<Value name="2">
<Value>FHIREndpointURL</Value>
</Value>
</Data>
<DefaultData>HL7v2MessageProcessorDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
