Class FHIRToLabEx.TestEnv.LIS.Service Extends Ens.BusinessService
{

Parameter ADAPTER = "Ens.InboundAdapter";

/// Name of the LIS business process
Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "LIS" ];

Parameter SETTINGS = "TargetConfigName:Basic";

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	#Dim tStatus As %Status = $$$OK

	#Dim tRequest As FHIRToLabEx.TestEnv.LIS.Message.ProcessAnOrderRequest
	Set tRequest = ##class(FHIRToLabEx.TestEnv.LIS.Message.ProcessAnOrderRequest).%New()
	Set tStatus = ..SendRequestAsync(..TargetConfigName, tRequest, 0)

	Return tStatus
}

}
