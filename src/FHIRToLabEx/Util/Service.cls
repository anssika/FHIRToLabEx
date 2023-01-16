/// Acute.Service.ClientService is a simple business service for sending interoperability messages in the production
Class FHIRToLabEx.Util.Service Extends Ens.BusinessService
{

Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "FHIRResourceRepository" ];

Parameter SETTINGS = "TargetConfigName:Basic";

/// Override this method to process incoming data. Do not call SendRequestSync/Async() from outside this method (e.g. in a SOAP Service or a CSP page).
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject, ByRef pHint As %String) As %Status
{
	#Dim tStatus As %Status = $$$OK

	Set tStatus = ..SendRequestSync(..TargetConfigName, pInput, .pOutput, 8)
	
	Return tStatus
}

}
